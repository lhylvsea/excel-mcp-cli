$ErrorActionPreference = 'Stop'
$resolver = Join-Path $PSScriptRoot 'resolve-excelcli.ps1'
$resolved = (& $resolver | ConvertFrom-Json)
$cli = $resolved.path

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

    [ordered]@{
        exitCode = $process.ExitCode
        output = (($stdout, $stderr | Where-Object { $_ }) -join [Environment]::NewLine).Trim()
    }
}

$versionResult = Invoke-NativeCapture -FilePath $cli -Arguments @('--version')
$helpResult = Invoke-NativeCapture -FilePath $cli -Arguments @('--help')
$versionOutput = $versionResult.output
$versionExit = $versionResult.exitCode
$helpOutput = $helpResult.output
$helpExit = $helpResult.exitCode
$helpOk = $helpOutput -match 'session' -and $helpOutput -match 'range'

[ordered]@{
    success = ($versionExit -eq 0 -and $helpExit -eq 0 -and $helpOk)
    cliPath = $cli
    productVersion = $resolved.productVersion
    versionExitCode = $versionExit
    helpExitCode = $helpExit
    helpContainsSessionAndRange = $helpOk
    versionOutput = $versionOutput
} | ConvertTo-Json -Depth 5
