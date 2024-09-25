# Remove the scheduled task
Unregister-ScheduledTask -TaskName 'OM-LogonScript' -Confirm:$false

# Remove the downloaded script
$localPath = 'C:\ProgramData\OptimumMovement\OM-LogonScript.ps1'
Remove-Item -Path $localPath -Force -ErrorAction SilentlyContinue

# Remove the OptimumMovement directory if it's empty
$directoryPath = 'C:\ProgramData\OptimumMovement'
if (Test-Path $directoryPath) {
    $isEmpty = @(Get-ChildItem -Path $directoryPath -Force).Count -eq 0
    if ($isEmpty) {
        Remove-Item -Path $directoryPath -Force
    }
}

Write-Host 'OptimumMovement LogonScript has been uninstalled.'
