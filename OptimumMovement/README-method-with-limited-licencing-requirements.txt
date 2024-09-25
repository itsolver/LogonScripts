# Intune Logon Script Deployment with Limited Licensing

This method allows deployment of logon scripts using a single Intune license, applying the configuration for all users on a computer.

## Deployment Instructions

1. Create two PowerShell scripts:
   a. `OM-install-logon-script.ps1`: This script will be deployed via Intune.
   b. `OM-LogonScript.ps1`: This is the main script that will run for all users at logon.

2. Store `OM-LogonScript.ps1` in a publicly accessible location (e.g., GitHub, Azure Blob Storage).

3. Modify `OM-install-logon-script.ps1` with the following content:

```powershell
$scriptUrl = "https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/OptimumMovement/src/OM-LogonScript.ps1"
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

4. Use IntuneWinAppUtil to create a Win32 app:
   - Download and extract IntuneWinAppUtil from the Microsoft GitHub repository.
   - Place `OM-install-logon-script.ps1` in a folder.
   - Open a command prompt and navigate to the IntuneWinAppUtil folder.
   - Run the following command:
     ```
     IntuneWinAppUtil.exe -c C:\Users\itsol\Projects\itsolver\LogonScripts\OptimumMovement\src -s OM-install-logon-script.ps1 -o C:\Users\itsol\Projects\itsolver\LogonScripts\OptimumMovement
     ```
   This will create an .intunewin file.

5. In Intune, create a new Win32 app:
   - Go to Intune > Apps > Windows apps > Add.
   - Select "Windows app (Win32)" as the app type.
   - Upload the .intunewin file created in step 4.
   - Set the following configurations:
     - Install command: `powershell.exe -executionpolicy bypass -file OM-install-logon-script.ps1`
     - Uninstall command: `powershell.exe -executionpolicy bypass -file OM-uninstall-logon-script.ps1`
     - Install behavior: System
     - Device restart behavior: No specific action
   - Set up detection rules as needed (e.g., presence of the scheduled task).
   - Configure assignments to deploy the app to your devices.

## How it works

1. The Intune-deployed Win32 app runs `OM-install-logon-script.ps1` in system context:
   - Downloads the main script (`OM-LogonScript.ps1`) to a local path
   - Creates a scheduled task to run the main script at each user logon
   - Runs the main script immediately

2. The scheduled task ensures `OM-LogonScript.ps1` runs for all users at logon.

3. You can update `OM-LogonScript.ps1` in your repository without needing to redeploy through Intune.

## Important Notes

- This method uses system context to install the app and set up the scheduled task.
- It works for all users on the computer, including local accounts.
- The scheduled task runs with standard user privileges, ensuring `OM-LogonScript.ps1` is secure.
- Regularly review and update `OM-LogonScript.ps1` to maintain security and functionality.
- The Win32 app approach allows for more granular control over installation, uninstallation, and detection methods.
- Note that this method loses the ability to centrally manage the logon script in GitHub after the initial installation. The script is downloaded only once during the Win32 app installation, so any updates to the GitHub version won't automatically propagate to installed instances. To update the script on deployed machines, you would need to redeploy the Win32 app or implement an additional update mechanism.
