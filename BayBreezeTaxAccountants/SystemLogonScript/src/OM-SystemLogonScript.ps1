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

Write-Log "OM-SystemLogonScript version $scriptVersion completed."
