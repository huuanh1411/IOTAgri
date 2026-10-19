param([ValidateSet('backend','frontend','analyze')][string]$Check)
$ErrorActionPreference='Continue'
$root='D:\Aerogreen\app_web_aerogreen\IOTAgri'
$outDir=Join-Path $root '.run/tests-only/20261013-151524'
Set-Location $root
$tool='dotnet'
switch($Check){
 'backend'{$arguments=@('test','backend/tests/IOTAgriBackend.Tests.csproj','--configuration','Release','--no-restore','--logger','trx;LogFileName=backend.trx','--results-directory',$outDir)}
 'frontend'{$tool=Join-Path $root '.runtime/flutter/bin/flutter.bat';Set-Location frontend;$arguments=@('test','--no-pub','--reporter','expanded','--file-reporter',"json:$(Join-Path $outDir 'frontend-events.jsonl')")}
 'analyze'{$tool=Join-Path $root '.runtime/flutter/bin/flutter.bat';Set-Location frontend;$arguments=@('analyze','--no-pub')}
}
$started=[DateTimeOffset]::UtcNow.ToOffset([TimeSpan]::FromHours(7)).ToString('o')
$cwd=(Get-Location).Path
$output=& $tool @arguments 2>&1
$nativeExit=$LASTEXITCODE
$body=($output|ForEach-Object{$_.ToString()}) -join "`n"
$body=$body.Replace($root,'[workspace]').Replace($root.Replace('\','/'),'[workspace]')
$body=$body -replace '(?i)C:[/\\]+Users[/\\]+[^/\\\s"<>]+','[user-home]'
$header="Started: $started`nWorking directory: $($cwd.Replace($root,'[workspace]'))`nCommand: $($tool.Replace($root,'[workspace]')) $($arguments -join ' ')`nExit code: $nativeExit`n"
[IO.File]::WriteAllText((Join-Path $outDir "$Check.log"),$header+$body,[Text.UTF8Encoding]::new($false))
Write-Output "Log: .run/tests-only/20261013-151524/$Check.log; exit=$nativeExit"
Write-Output (($body -split "`n" | Select-Object -Last 12) -join "`n")
exit $nativeExit
