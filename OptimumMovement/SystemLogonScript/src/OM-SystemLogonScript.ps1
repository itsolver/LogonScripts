# Define the log file path
$logFilePath = 'C:\Logs\OM-SystemLogonScript.log'

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

$scriptVersion = '1.2'
Write-Log "OM-SystemLogonScript version $scriptVersion started."

# Copy Google Drive shortcut to Public Desktop and Public Startup folder
$sourcePath = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Google Drive.lnk'
$publicDesktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
$publicStartupPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"

if (Test-Path $sourcePath) {
    try {
        Copy-Item -Path $sourcePath -Destination $publicDesktopPath -Force
        Write-Host 'Google Drive shortcut successfully copied to Public Desktop.'
        
        Copy-Item -Path $sourcePath -Destination $publicStartupPath -Force
        Write-Host 'Google Drive shortcut successfully copied to Public Startup folder.'
    }
    catch {
        Write-Host "Error copying Google Drive shortcut: $_"
    }
}
else {
    Write-Host "Google Drive shortcut not found at '$sourcePath'."
}


# Prevent unwanted Chrome extensions from being pre-installed
Write-Log 'Removing Chrome extension subkeys from registry.'
$registryPath = 'HKLM:\Software\Wow6432Node\Google\Chrome\Extensions'

try {
    if (Test-Path $registryPath) {
        $subkeys = Get-ChildItem -Path $registryPath -ErrorAction Stop
        
        if ($subkeys.Count -gt 0) {
            foreach ($subkey in $subkeys) {
                $subkeyName = $subkey.PSChildName
                Write-Log "Removing subkey: $subkeyName"
                Remove-Item -Path "$registryPath\$subkeyName" -Recurse -Force -ErrorAction Stop
            }
            Write-Log 'All Chrome extension subkeys have been removed.'
        }
        else {
            Write-Log 'No Chrome extension subkeys found to remove.'
        }
    }
    else {
        Write-Log 'Chrome Extensions registry path not found. No action needed.'
    }
}
catch {
    Write-Log "Error occurred while removing Chrome extension subkeys: $_" 'ERROR'
    Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
    Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
}

# Hide Microsoft Edge public desktop shortcut
$publicDesktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')
$edgeShortcutPath = Join-Path $publicDesktopPath 'Microsoft Edge.lnk'

Write-Log "Checking for Edge shortcut at: $edgeShortcutPath"

if (Test-Path $edgeShortcutPath) {
    Write-Log 'Edge shortcut found.'
    try {
        $file = Get-Item $edgeShortcutPath -Force
        Write-Log "File attributes: $($file.Attributes)"
        
        if ($file.Attributes -band [System.IO.FileAttributes]::Hidden) {
            Write-Log 'Microsoft Edge shortcut is already hidden on the public desktop.'
        }
        else {
            Write-Log 'Attempting to hide the Microsoft Edge shortcut.'
            $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden
            Write-Log 'Microsoft Edge shortcut has been hidden on the public desktop.'
        }
    }
    catch {
        Write-Log "Failed to process Microsoft Edge shortcut: $_" 'ERROR'
        Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
        Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
    }
}
else {
    Write-Log 'Microsoft Edge shortcut not found at the expected location.'
}

Write-Log "OM-SystemLogonScript version $scriptVersion completed."


Write-Log "OM-SystemLogonScript version $scriptVersion completed."
