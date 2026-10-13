$ErrorActionPreference = 'Continue'
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskPreviousPythonPath = $env:PYTHONPATH
$taskPreviousEncoding = $env:PYTHONIOENCODING
Push-Location $taskRoot
try {
    $env:PYTHONPATH = Join-Path $taskRoot '.run/graphify-tools'
    $env:PYTHONIOENCODING = 'utf-8'
    & python -m graphify update . *> testing/reports/summary/graphify-update.log
    $taskExit = $LASTEXITCODE
    $taskExit | Set-Content testing/reports/summary/graphify-update.exitcode
    Get-Content testing/reports/summary/graphify-update.log
    exit $taskExit
}
finally {
    $env:PYTHONPATH = $taskPreviousPythonPath
    $env:PYTHONIOENCODING = $taskPreviousEncoding
    Pop-Location
}
