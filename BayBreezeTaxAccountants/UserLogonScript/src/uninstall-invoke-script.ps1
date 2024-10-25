<#
.SYNOPSIS
    Uninstalls the logon script.
.DESCRIPTION
    This script removes the logon script and associated components.
.NOTES
    Version: 1.1
    Author: IT Solver
    Last Modified: 03 Oct 2024
#>
Write-Host 'uninstall-invoke-script started.'

# Remove the scheduled task
Unregister-ScheduledTask -TaskName 'UserLogonScript' -Confirm:$false

# Remove the downloaded script
$localPath = 'C:\ProgramData\ITSolver\OM-UserLogonScript.ps1'
Remove-Item -Path $localPath -Force -ErrorAction SilentlyContinue

# Remove the OptimumMovement directory if it's empty
$directoryPath = 'C:\ProgramData\ITSolver'
if (Test-Path $directoryPath) {
    $isEmpty = @(Get-ChildItem -Path $directoryPath -Force).Count -eq 0
    if ($isEmpty) {
        Remove-Item -Path $directoryPath -Force
    }
}

Write-Host "OM-uninstall-invoke-script version $scriptVersion completed."
