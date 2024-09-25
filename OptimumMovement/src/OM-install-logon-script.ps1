$scriptUrl = 'https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/OptimumMovement/OM-LogonScript.ps1'
$localPath = 'C:\ProgramData\OptimumMovement\OM-LogonScript.ps1'

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path (Split-Path $localPath)

# Download the script
Invoke-WebRequest -Uri $scriptUrl -OutFile $localPath

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass -File `"$localPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId 'Users' -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName 'OM-LogonScript' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

# Run the script immediately
& $localPath