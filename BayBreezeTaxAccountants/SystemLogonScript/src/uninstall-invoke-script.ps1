# Remove the scheduled task
Unregister-ScheduledTask -TaskName 'SystemLogonScript' -Confirm:$false

# Remove the downloaded script
$localPath = 'C:\ProgramData\ITSolver\SystemLogonScript.ps1'
Remove-Item -Path $localPath -Force -ErrorAction SilentlyContinue

# Remove the ITSolver directory if it's empty
$directoryPath = 'C:\ProgramData\ITSolver'
if (Test-Path $directoryPath) {
    $isEmpty = @(Get-ChildItem -Path $directoryPath -Force).Count -eq 0
    if ($isEmpty) {
        Remove-Item -Path $directoryPath -Force
    }
}

Write-Host 'SystemLogonScript has been uninstalled.'
