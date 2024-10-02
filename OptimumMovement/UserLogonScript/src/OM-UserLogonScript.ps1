<#
Version: 1.0
Author: 
- Jeroen Burgerhout (burgerhout.org)
Script: Remove-OutlookNew
Description: Script removes the new Microsoft Outlook app on Windows 11 23H2.
Hint: This is a community script. There is no guarantee for this. Please check thoroughly before running.
Version 1.0: Init
Run this script using the logged-on credentials: Yes
Enforce script signature check: No
Run script in 64-bit PowerShell: Yes
#> 

# Define the log file path
$logFilePath = 'C:\Logs\OM-UserLogonScript.log'

# Ensure the log directory exists
New-Item -ItemType Directory -Force -Path (Split-Path $logFilePath) | Out-Null

# Function to log messages
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "$timestamp [$Level] $Message"
    Add-Content -Path $logFilePath -Value $entry
}

# Start of script
Write-Log 'Script execution started.'

# Remove Microsoft Outlook (New)
try {
    Get-AppxPackage -Name *OutlookForWindows* | Remove-AppxPackage -ErrorAction Stop
    Write-Log 'Microsoft Outlook (New) successfully removed.'
}
catch {
    Write-Log "Error removing Microsoft Outlook (New): $_" 'ERROR'
}

# End of script
Write-Log 'Script execution completed.'

