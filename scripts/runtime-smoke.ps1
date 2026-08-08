param(
    [Parameter(Mandatory = $true)]
    [string]$WorkbookPath
)

$ErrorActionPreference = 'Stop'
$resolver = Join-Path $PSScriptRoot 'resolve-excelcli.ps1'
$resolved = (& $resolver | ConvertFrom-Json)
$cli = $resolved.path
$sessionId = $null
$closed = $false
$success = $false
$errorMessage = $null
$readback = $null

function Invoke-NativeCapture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $FilePath
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.Arguments = (($Arguments | ForEach-Object { '"' + ($_ -replace '"', '\"') + '"' }) -join ' ')

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    [pscustomobject]@{
        ExitCode = $process.ExitCode
        Stdout = $stdout.Trim()
        Stderr = $stderr.Trim()
    }
}

function Invoke-ExcelCli {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $result = Invoke-NativeCapture -FilePath $cli -Arguments $Arguments
    if ($result.ExitCode -ne 0) {
        throw ("CLI failed with exit code {0}: {1} {2}" -f $result.ExitCode, $result.Stdout, $result.Stderr)
    }
    return $result
}

try {
    if (-not (Test-Path -LiteralPath $WorkbookPath -PathType Leaf)) {
        throw "Workbook not found: $WorkbookPath"
    }

    $existingExcel = @(Get-Process -Name EXCEL -ErrorAction SilentlyContinue)
    if ($existingExcel.Count -gt 0) {
        throw "Excel is already running; smoke test will not terminate or attach to a user-visible process."
    }

    $openResult = Invoke-ExcelCli -Arguments @('-q', 'session', 'open', $WorkbookPath)
    $open = $openResult.Stdout | ConvertFrom-Json
    $sessionId = [string]$open.sessionId
    if ([string]::IsNullOrWhiteSpace($sessionId)) {
        throw "CLI did not return a sessionId."
    }

    $valuesResult = Invoke-ExcelCli -Arguments @('-q', 'range', 'get-values', '--session', $sessionId, '--sheet', 'Sheet1', '--range', 'A1:D5')
    $readback = $valuesResult.Stdout | ConvertFrom-Json
    $closeResult = Invoke-ExcelCli -Arguments @('-q', 'session', 'close', '--session', $sessionId)
    $closed = ($closeResult.ExitCode -eq 0)
    $success = $closed
}
catch {
    $errorMessage = $_.Exception.Message
}
finally {
    if ($sessionId -and -not $closed) {
        $cleanup = Invoke-NativeCapture -FilePath $cli -Arguments @('-q', 'session', 'close', '--session', $sessionId)
        $closed = ($cleanup.ExitCode -eq 0)
    }
}

$remainingExcel = @(Get-Process -Name EXCEL -ErrorAction SilentlyContinue)
$report = [ordered]@{
    success = ($success -and $closed -and [string]::IsNullOrWhiteSpace($errorMessage) -and $remainingExcel.Count -eq 0)
    cliPath = $cli
    productVersion = $resolved.productVersion
    workbookPath = (Resolve-Path -LiteralPath $WorkbookPath).Path
    sessionOpened = (-not [string]::IsNullOrWhiteSpace($sessionId))
    sessionClosed = $closed
    readback = $readback
    remainingExcelProcessCount = $remainingExcel.Count
    error = $errorMessage
}

$report | ConvertTo-Json -Depth 8
if (-not $report.success) {
    exit 1
}
