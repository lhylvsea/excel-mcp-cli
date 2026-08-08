param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $SourcePath -ErrorAction Stop).Path
$extension = [System.IO.Path]::GetExtension($source).ToLowerInvariant()
if ($extension -notin @('.xlsx', '.xlsm')) {
    throw "Only .xlsx and .xlsm are supported: $source"
}

$outputFull = [System.IO.Path]::GetFullPath($OutputPath)
if ($source -ieq $outputFull) {
    throw 'OutputPath must differ from SourcePath'
}
if ((Test-Path -LiteralPath $outputFull) -and -not $Force) {
    throw "Output already exists. Choose another path or pass -Force: $outputFull"
}

$parent = Split-Path -Parent $outputFull
New-Item -ItemType Directory -Force -Path $parent | Out-Null
Copy-Item -LiteralPath $source -Destination $outputFull -Force:$Force

$copied = Get-Item -LiteralPath $outputFull
[ordered]@{
    success = $true
    source = $source
    output = $copied.FullName
    extension = $extension
    bytes = $copied.Length
} | ConvertTo-Json -Compress
