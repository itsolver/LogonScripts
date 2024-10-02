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

# Start of script
Write-Log 'Script execution started.'

# Hide Microsoft Edge public desktop shortcut
$publicDesktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')
$edgeShortcutPath = Join-Path $publicDesktopPath 'Microsoft Edge.lnk'

Write-Log "Checking for Edge shortcut at: $edgeShortcutPath"

if (Test-Path $edgeShortcutPath) {
    Write-Log "Edge shortcut found."
    try {
        $file = Get-Item $edgeShortcutPath -Force
        Write-Log "File attributes: $($file.Attributes)"
        
        if ($file.Attributes -band [System.IO.FileAttributes]::Hidden) {
            Write-Log "Microsoft Edge shortcut is already hidden on the public desktop."
        } else {
            Write-Log "Attempting to hide the Microsoft Edge shortcut."
            $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden
            Write-Log "Microsoft Edge shortcut has been hidden on the public desktop."
        }
    }
    catch {
        Write-Log "Failed to process Microsoft Edge shortcut: $_" 'ERROR'
        Write-Log "Exception details: $($_.Exception.GetType().FullName)" 'ERROR'
        Write-Log "Stack trace: $($_.ScriptStackTrace)" 'ERROR'
    }
} else {
    Write-Log "Microsoft Edge shortcut not found at the expected location."
}

# End of script
Write-Log 'Script execution completed.'
