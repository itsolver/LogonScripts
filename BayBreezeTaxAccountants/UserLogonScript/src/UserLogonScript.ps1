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

# Script version
$scriptVersion = '1.2'

# Define the log file path
$logFilePath = 'C:\ProgramData\ITSolver\UserLogonScript.log'

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
Write-Log "UserLogonScript v$scriptVersion execution started."
# Enable OneDrive auto-start
try {
    # Create/set registry key for OneDrive auto-start
    $registryPath = 'HKCU:\Software\Policies\Microsoft\OneDrive'
    if (!(Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    Set-ItemProperty -Path $registryPath -Name 'EnableAutoStart' -Value 1 -Type DWord
    Write-Log 'OneDrive auto-start successfully enabled.'
}
catch {
    Write-Log "Error occurred while enabling OneDrive auto-start: $_" 'ERROR'
    Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
    Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
}

# Right-click: Remove Windows 11 new context menu
Write-Verbose 'Modifying right-click context menu'
reg.exe add 'HKCU\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' /f /ve /reg:64 | Out-Host
if ($LASTEXITCODE -ne 0) { throw 'Failed to modify right-click context menu' }
Write-Verbose 'Right-click context menu modified successfully'

# Remove Microsoft Outlook (New)
try {
    Get-AppxPackage -Name *OutlookForWindows* | Remove-AppxPackage -ErrorAction Stop
    Write-Log 'Microsoft Outlook (New) successfully removed.'
}
catch {
    Write-Log "Error occurred while removing Microsoft Outlook (New): $_" 'ERROR'
    Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
    Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
}

# End of script
Write-Log "UserLogonScript v$scriptVersion execution completed."
