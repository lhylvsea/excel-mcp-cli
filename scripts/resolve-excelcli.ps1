param(
    [string]$CliPath
)

$ErrorActionPreference = 'Stop'
$candidates = New-Object System.Collections.Generic.List[object]

function Add-Candidate {
    param(
        [string]$Path,
        [string]$Source
    )
    if ($Path -and (Test-Path -LiteralPath $Path -PathType Leaf)) {
        $candidates.Add([PSCustomObject]@{ Path = $Path; Source = $Source })
    }
}

if ($CliPath) {
    Add-Candidate -Path $CliPath -Source 'argument'
}
if ($env:EXCELMCP_CLI) {
    Add-Candidate -Path $env:EXCELMCP_CLI -Source 'EXCELMCP_CLI'
}

foreach ($commandName in @('excelcli.exe', 'excelcli')) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    if ($command -and $command.Source) {
        Add-Candidate -Path $command.Source -Source 'PATH'
    }
}

$knownFiles = @(
    'C:\Tools\ExcelMcp\excelcli.exe',
    'C:\Tools\ExcelMcp\cli\excelcli.exe'
)
foreach ($knownFile in $knownFiles) {
    Add-Candidate -Path $knownFile -Source 'known-path'
}

$searchRoots = @(
    (Join-Path $env:USERPROFILE 'Documents\Codex'),
    (Join-Path $env:USERPROFILE 'Documents\ExcelMcp')
)
foreach ($root in $searchRoots) {
    if (Test-Path -LiteralPath $root -PathType Container) {
        Get-ChildItem -LiteralPath $root -Filter 'excelcli.exe' -File -Recurse -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            ForEach-Object { Add-Candidate -Path $_.FullName -Source 'workspace-search' }
    }
}

$selected = $candidates |
    Where-Object { $_.Path } |
    Group-Object Path |
    ForEach-Object { $_.Group | Select-Object -First 1 } |
    Select-Object -First 1

if (-not $selected) {
    Write-Error 'excelcli.exe was not found. Set EXCELMCP_CLI or install the standalone ExcelMcp CLI.'
    exit 1
}

$item = Get-Item -LiteralPath $selected.Path
[ordered]@{
    success = $true
    path = $item.FullName
    source = $selected.Source
    productVersion = $item.VersionInfo.ProductVersion
    fileVersion = $item.VersionInfo.FileVersion
} | ConvertTo-Json -Compress
