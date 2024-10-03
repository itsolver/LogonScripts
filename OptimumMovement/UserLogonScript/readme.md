# Intune Logon Script Deployment with Limited Licensing

Version: 1.1
Last Updated: 03 Oct 2024

## Deployment Instructions

1. Ensure you have these PowerShell scripts in your repository:
   a. `OM-install-user-logon-script.ps1`: Deployed via Intune.
   b. `OM-UserLogonScript.ps1`: Main script that runs for all users at logon.

2. `OM-UserLogonScript.ps1` is stored in a publicly accessible GitHub location.

3. Locate `OM-install-user-logon-script.ps1` at:
   `C:\Users\itsol\Projects\itsolver\LogonScripts\OptimumMovement\UserLogonScript\src\OM-install-user-logon-script.ps1`

4. Create a Win32 app using IntuneWinAppUtil:
   - Download IntuneWinAppUtil from Microsoft's GitHub.
   - Place `OM-install-user-logon-script.ps1` in a folder.
   - Run:
     ```
     IntuneWinAppUtil.exe -c C:\Users\itsol\Projects\itsolver\LogonScripts\OptimumMovement\UserLogonScript\src -s OM-install-user-logon-script.ps1 -o C:\Users\itsol\Projects\itsolver\LogonScripts\OptimumMovement\UserLogonScript
     ```

5. Create a new Win32 app in Intune:
   - Upload the .intunewin file.
   - Configure:
     - Install command: `powershell.exe -executionpolicy bypass -file OM-install-user-logon-script.ps1`
     - Uninstall command: `powershell.exe -executionpolicy bypass -file OM-uninstall-invoke-script.ps1`
     - Install behavior: System
     - Device restart behavior: No specific action
   - Detection rules:
     - Rule Type: File
     - Path: C:\ProgramData\OptimumMovement\
     - File or folder: OM-LogonScript.ps1
     - Detection method: File or folder exists
     - Associated with a 32-bit app on 64-bit clients: No
   - Assign to your devices.

## How it works

1. Intune-deployed Win32 app runs `OM-install-user-logon-script.ps1` in system context:
   - Downloads `OM-LogonScript.ps1` locally
   - Creates a scheduled task for user logon
   - Attempts immediate script execution

2. Scheduled task runs `OM-LogonScript.ps1` for all users at subsequent logons.

3. Update `OM-LogonScript.ps1` in your repository without Intune redeployment.

## Important Notes

- System context installation applies to all users, including local accounts.
- Scheduled task runs with standard user privileges for security.
- Regularly update `OM-LogonScript.ps1` for security and functionality.
- Win32 app allows granular control over installation, uninstallation, and detection.
- Updates to GitHub version won't automatically propagate. Implement an update mechanism or redeploy for changes.
- Script doesn't execute on first logon after installation. Runs on subsequent logons via scheduled task.
- Immediate execution during installation may not work as intended (system vs. user context).
- Users may need to log out and back in after initial installation for the script to take effect.
- Consider informing users or IT staff about the necessary logout/login cycle.

## Version History

- 1.1 - 03 Oct 2024: Added versioning information
- 1.0 - [Initial Date]: Initial release
