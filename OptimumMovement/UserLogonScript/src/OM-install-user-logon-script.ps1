# Delete deprecated scheduled task
Unregister-ScheduledTask -TaskName "OM-LogonScript" -Confirm:$false -ErrorAction SilentlyContinue

$scriptUrl = 'https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/OptimumMovement/UserLogonScript/src/OM-UserLogonScript.ps1'
$wrapperScriptPath = 'C:\ProgramData\OptimumMovement\OM-UserLogonWrapper.ps1'

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path (Split-Path $wrapperScriptPath)

# Create the wrapper script
$wrapperScriptContent = @"
`$scriptUrl = '$scriptUrl'
`$tempScriptPath = Join-Path `$env:TEMP 'OM-UserLogonScript.ps1'

# Download the latest script
try {
    Invoke-WebRequest -Uri `$scriptUrl -OutFile `$tempScriptPath -ErrorAction Stop
}
catch {
    Write-Error "Failed to download the latest script: `$($_)"
    exit 1
}

# Execute the script
try {
    & `$tempScriptPath
}
catch {
    Write-Error "Error executing the script: `$($_)"
}
finally {
    Remove-Item `$tempScriptPath -Force -ErrorAction SilentlyContinue
}
"@

Set-Content -Path $wrapperScriptPath -Value $wrapperScriptContent -Force

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass -File `"$wrapperScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -GroupId 'Users' -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName 'OM-UserLogonScript' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

# Run the wrapper script immediately
& $wrapperScriptPath

# Set file permissions to allow only administrators and the user access
$acl = Get-Acl $scriptDirectory
$administrators = [System.Security.Principal.NTAccount]"Administrators"
$user = [System.Security.Principal.NTAccount]([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)

$accessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule($administrators, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$accessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule($user, "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")

$acl.SetAccessRuleProtection($True, $False)
$acl.ResetAccessRule($accessRule1)
$acl.AddAccessRule($accessRule2)

Set-Acl -Path $scriptDirectory -AclObject $acl