# Intune System Logon Script Deployment

Version: 1.2
Last Updated: 25 Oct 2024

## Deployment Instructions

1. Ensure you have these PowerShell scripts in your repository:
   a. `install-system-logon-script.ps1`: Deployed via Intune.
   b. `SystemLogonScript.ps1`: Main script that runs at system startup.
   c. `uninstall-invoke-script.ps1`: For uninstallation.

2. `SystemLogonScript.ps1` should be stored in a publicly accessible GitHub location.

3. Create a Win32 app using IntuneWinAppUtil:
   - Download IntuneWinAppUtil from Microsoft's GitHub.
   - Place `install-system-logon-script.ps1` in a folder.
   - Run:
     ```
     IntuneWinAppUtil.exe -c C:\Users\itsol\Projects\itsolver\LogonScripts\BayBreezeTaxAccountants\SystemLogonScript\src -s install-system-logon-script.ps1 -o C:\Users\itsol\Projects\itsolver\LogonScripts\BayBreezeTaxAccountants\SystemLogonScript
     ```

4. Create a new Win32 app in Intune:
   - Upload the .intunewin file.
   - Configure:
     - Install command: `powershell.exe -executionpolicy bypass -file install-system-logon-script.ps1`
     - Uninstall command: `powershell.exe -executionpolicy bypass -file uninstall-invoke-script.ps1`
     - Install behavior: System
     - Device restart behavior: No specific action
   - Detection rules:
     - Rule Type: File
     - Path: C:\ProgramData\ITSolver\
     - File or folder: SystemLogonWrapper.ps1
     - Detection method: File or folder exists
     - Associated with a 32-bit app on 64-bit clients: No
   - Assign to your devices.

## How it works

1. Intune-deployed Win32 app runs `install-system-logon-script.ps1` in system context:
   - Creates `SystemLogonWrapper.ps1` locally
   - Creates a scheduled task for system startup
   - Attempts immediate script execution

2. Scheduled task runs `SystemLogonWrapper.ps1` at subsequent system startups, which downloads and executes the latest `SystemLogonScript.ps1`.

3. Update `SystemLogonScript.ps1` in your repository without Intune redeployment.

## Important Notes

- System context installation applies system-wide.
- Scheduled task runs with system privileges.
   - Regularly update `SystemLogonScript.ps1` for security and functionality.
- Win32 app allows granular control over installation, uninstallation, and detection.
- Updates to GitHub version of `SystemLogonScript.ps1` will automatically propagate on next system startup.
- Script may not execute immediately after installation. Runs on subsequent system startups via scheduled task.
- Consider informing IT staff about potential system restart requirements for script activation.

## Version History
- 1.2 - 25 Oct 2024: Repurpose OptimumMovement script for BayBreezeTaxAccountants
- 1.1 - 03 Oct 2024: Added versioning information and clarified wrapper script functionality
- 1.0 - [Initial Date]: Initial release

