<#
.SYNOPSIS
    Uninstalls the OptimumMovement logon script.
.DESCRIPTION
    This script removes the OptimumMovement logon script and associated components.
.NOTES
    Version: 1.1
    Author: IT Solver
    Last Modified: 03 Oct 2024
#>

$scriptVersion = '1.1'
Write-Host "OM-uninstall-invoke-script version $scriptVersion started."

# Remove the scheduled task
Unregister-ScheduledTask -TaskName 'OM-UserLogonScript' -Confirm:$false

# Remove the downloaded script
$localPath = 'C:\ProgramData\OptimumMovement\OM-UserLogonScript.ps1'
Remove-Item -Path $localPath -Force -ErrorAction SilentlyContinue

# Remove the OptimumMovement directory if it's empty
$directoryPath = 'C:\ProgramData\OptimumMovement'
if (Test-Path $directoryPath) {
    $isEmpty = @(Get-ChildItem -Path $directoryPath -Force).Count -eq 0
    if ($isEmpty) {
        Remove-Item -Path $directoryPath -Force
    }
}

Write-Host "OM-uninstall-invoke-script version $scriptVersion completed."
