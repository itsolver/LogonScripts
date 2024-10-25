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
Write-Host "Starting UserLogonScript v$scriptVersion..."
Start-Sleep -Seconds 2

# Enable OneDrive auto-start
Write-Host "`nAttempting to enable OneDrive auto-start..."
try {
    # Create/set registry key for OneDrive auto-start
    $registryPath = 'HKCU:\Software\Policies\Microsoft\OneDrive'
    
    # Test if we can access/create the registry path
    if (!(Test-Path $registryPath)) {
        try {
            New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null
            Write-Log 'Created OneDrive registry path successfully.'
        }
        catch {
            Write-Log "Failed to create registry path: $_" 'ERROR'
            throw
        }
    }

    # Try to set the registry value
    try {
        Set-ItemProperty -Path $registryPath -Name 'EnableAutoStart' -Value 1 -Type DWord -ErrorAction Stop
        Write-Log 'OneDrive auto-start successfully enabled.'
        Write-Host 'OneDrive auto-start configuration completed.' -ForegroundColor Green
    }
    catch [System.Security.SecurityException] {
        Write-Log 'Insufficient permissions to modify OneDrive registry. Attempting alternate method...' 'WARNING'
        # Alternative method using reg.exe which might have different permission context
        $result = Start-Process reg.exe -ArgumentList "add `"$($registryPath.Replace('HKCU:','HKEY_CURRENT_USER'))`" /v EnableAutoStart /t REG_DWORD /d 1 /f" -Wait -PassThru
        if ($result.ExitCode -eq 0) {
            Write-Log 'OneDrive auto-start enabled using alternate method.'
            Write-Host 'OneDrive auto-start configuration completed.' -ForegroundColor Green
        }
        else {
            Write-Log "Failed to set registry value using alternate method. Exit code: $($result.ExitCode)" 'ERROR'
            Write-Host 'Failed to configure OneDrive auto-start.' -ForegroundColor Red
            throw
        }
    }
}
catch {
    Write-Host 'Failed to configure OneDrive auto-start.' -ForegroundColor Red
    Write-Log "Error occurred while enabling OneDrive auto-start: $_" 'ERROR'
    Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
    Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
}
Write-Host 'Press any key to continue...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Right-click: Remove Windows 11 new context menu
Write-Host "`nModifying right-click context menu..."
Write-Verbose 'Modifying right-click context menu'
reg.exe add 'HKCU\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' /f /ve /reg:64 | Out-Host
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Right-click context menu modified successfully.' -ForegroundColor Green
}
else {
    Write-Host 'Failed to modify right-click context menu.' -ForegroundColor Red
    throw 'Failed to modify right-click context menu'
}
Write-Host 'Press any key to continue...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Remove Microsoft Outlook (New)
Write-Host "`nAttempting to remove Microsoft Outlook (New)..."
try {
    Get-AppxPackage -Name *OutlookForWindows* | Remove-AppxPackage -ErrorAction Stop
    Write-Log 'Microsoft Outlook (New) successfully removed.'
    Write-Host 'Microsoft Outlook (New) successfully removed.' -ForegroundColor Green
}
catch {
    Write-Host 'Failed to remove Microsoft Outlook (New).' -ForegroundColor Red
    Write-Log "Error occurred while removing Microsoft Outlook (New): $_" 'ERROR'
    Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
    Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
}
Write-Host 'Press any key to continue...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# End of script
Write-Log "UserLogonScript v$scriptVersion execution completed."
Write-Host "`nScript execution completed. Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
