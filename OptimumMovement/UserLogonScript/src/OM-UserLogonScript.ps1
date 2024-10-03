<#
.SYNOPSIS
    User logon script for OptimumMovement.
.DESCRIPTION
    This script runs at user logon and performs various tasks.
.NOTES
    Version: 1.1
    Author: IT Solver
    Last Modified: 03 Oct 2024
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

# Script content starts here
$scriptVersion = '1.1'
Write-Log "OM-UserLogonScript version $scriptVersion started."

Write-Log "OM-UserLogonScript version $scriptVersion completed."

