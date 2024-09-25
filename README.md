# Intune Logon Script Deployment

This repository contains a client-side script deployed with Intune which triggers the main script during logon. The main script is not stored locally, making it easy to customize without needing updates or changes on the client side.

## Deployment

In Intune, we deploy the client-side script via PowerShell Scripts. The only thing we need to change is the URL to the main script on the GitHub repo.

## Important Notes

* We decided to use the HKCU registry because scheduled tasks cannot be deployed in the user context (local admin rights are required).
* We're using a GitHub "raw" script as the primary method. This approach allows for easier management and version control.

## Client-side Script

The client-side script consists of:

1. Creating a registry run entry in the HKCU hive to execute the main script from GitHub on each user logon.
2. Invoking the main script initially (otherwise we would have to wait until the next user logon for the network drives to become available).

After adjusting the script, deploy it with Intune to an Azure AD group containing your users. Remember to run the script using the logged-on credentials.

```powershell
$githubScriptUrl = "https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/Remove-OutlookNew.ps1"
$regKeyLocation = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$psCommand = "PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"& {Invoke-RestMethod '$githubScriptUrl' | Invoke-Expression}`""

if (-not(Test-Path -Path $regKeyLocation)) {
    New-Item -Path $regKeyLocation -Force | Out-Null
}

Set-ItemProperty -Path $regKeyLocation -Name "PowerShellDriveMapping" -Value $psCommand -Force

# Invoke the script immediately
Invoke-Expression -Command "& {$(Invoke-RestMethod $githubScriptUrl) | Invoke-Expression}"
```

## Alternative Approach: Azure Blob Storage

You can also use Azure blob storage instead of GitHub. Here's an example of how to set up the command for Azure blob storage:

```powershell
$azDriveMappingScriptUrl = "https://ntintune.blob.core.windows.net/intune-scripts/DriveMappingScript.ps1"
$psCommand = "PowerShell.exe -ExecutionPolicy Bypass -Windowstyle hidden -command $([char]34)& {(Invoke-RestMethod '$azDriveMappingScriptUrl').Replace('ï','').Replace('»','').Replace('¿','') | Invoke-Expression}$([char]34)"
```

When using Azure blob storage, you may need to handle potential encoding issues, as shown in the `Replace` methods above.

You can also use `Invoke-RestMethod` to directly execute a script from Azure blob storage or GitHub. For example:

```powershell
Invoke-RestMethod "https://raw.githubusercontent.com/nicolonsky/Techblog/master/IntuneNetworkDrives/DriveMappingScript.ps1" | Invoke-Expression
```

## Acknowledgements

Thanks to [Nicolonsky's original blog post](https://tech.nicolonsky.ch/intune-execute-powershell-script-on-each-user-logon/) for the initial scripts and Azure blob storage method. This README has been adapted to use GitHub raw storage as the primary method, with Azure blob storage as an alternative approach.
