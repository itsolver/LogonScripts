# Intune Logon Script Deployment with Limited Licensing

This method allows deployment of logon scripts using a single Intune license, applying the configuration for all users on a computer.

## Deployment Instructions

1. Create two PowerShell scripts:
   a. `invoke-script.ps1`: This script will be deployed via Intune.
   b. `OM-LogonScript.ps1`: This is the main script that will run for all users at logon.

2. Store `OM-LogonScript.ps1` in a publicly accessible location (e.g., GitHub, Azure Blob Storage).

3. Modify `invoke-script.ps1` with the following content:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/OptimumMovement/OM-LogonScript.ps1"
$localPath = "C:\ProgramData\OptimumMovement\OM-LogonScript.ps1"

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path (Split-Path $localPath)

# Download the script
Invoke-WebRequest -Uri $scriptUrl -OutFile $localPath

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$localPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId "Users" -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "OM-LogonScript" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

# Run the script immediately
& $localPath
```

4. In Intune, create a new PowerShell script:
   - Upload `invoke-script.ps1`
   - Set to run in system context
   - Configure to run once per device

5. Deploy the Intune PowerShell script to your devices.

## How it works

1. The Intune-deployed `invoke-script.ps1`:
   - Downloads the main script (`OM-LogonScript.ps1`) to a local path
   - Creates a scheduled task to run the main script at each user logon
   - Runs the main script immediately

2. The scheduled task ensures `OM-LogonScript.ps1` runs for all users at logon.

3. You can update `OM-LogonScript.ps1` in your repository without needing to redeploy through Intune.

## Important Notes

- This method requires system-level privileges to set up the scheduled task.
- It works for all users on the computer, including local accounts.
- The scheduled task runs with standard user privileges, ensuring `OM-LogonScript.ps1` is secure.
- Regularly review and update `OM-LogonScript.ps1` to maintain security and functionality.
