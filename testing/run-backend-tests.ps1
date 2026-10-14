param([string]$RunName = ('run-' + (Get-Date -Format 'yyyyMMdd-HHmmss')))
$ErrorActionPreference = 'Stop'
if ($RunName -notmatch '^[A-Za-z0-9_-]+$') { throw 'RunName must contain only letters, numbers, underscores, or hyphens.' }
$taskRoot = Split-Path $PSScriptRoot -Parent
Push-Location $taskRoot
try {
    $taskResults = Join-Path 'testing/reports/coverage' $RunName
    $taskLog = Join-Path 'testing/reports/summary' ($RunName + '-test.log')
    New-Item -ItemType Directory -Path $taskResults,'testing/reports/summary' -Force | Out-Null
    # NuGetAudit=false is a command-local restore setting for isolated test execution;
    # it does not edit application files. Security advisory availability is separate.
    & dotnet restore backend/tests/IOTAgriBackend.Tests.csproj -p:NuGetAudit=false *> ($taskLog + '.restore')
    $taskRestoreExit = $LASTEXITCODE
    if ($taskRestoreExit -ne 0) {
        Get-Content ($taskLog + '.restore')
        exit $taskRestoreExit
    }
    # Windows PowerShell 5.1 turns native stderr into ErrorRecords. Continue so a
    # legitimate failing test is captured rather than terminating before its exit code.
    $ErrorActionPreference = 'Continue'
    & dotnet test backend/tests/IOTAgriBackend.Tests.csproj --configuration Release --no-restore -p:UseSharedCompilation=false --settings testing/coverage.runsettings --collect 'XPlat Code Coverage' --logger 'trx;LogFileName=backend-tests.trx' --results-directory $taskResults *> $taskLog
    $taskExit = $LASTEXITCODE
    $taskExit | Set-Content ($taskLog + '.exitcode')
    Get-Content $taskLog
    exit $taskExit
}
finally { Pop-Location }
