$scriptUrl = 'https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/OptimumMovement/SystemLogonScript/src/OM-SystemLogonScript.ps1'
$wrapperScriptPath = 'C:\ProgramData\OptimumMovement\OM-SystemLogonWrapper.ps1'
$scriptDirectory = Split-Path $wrapperScriptPath

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $scriptDirectory

# Create the wrapper script
$wrapperScriptContent = @"
`$scriptUrl = '$scriptUrl'
`$tempScriptPath = Join-Path `$env:TEMP 'OM-SystemLogonScript.ps1'

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

Set-Content -Path $wrapperScriptPath -Value $wrapperScriptContent -Force -Encoding UTF8

# Set strict file permissions
$acl = Get-Acl $scriptDirectory
$administrators = [System.Security.Principal.NTAccount]"Administrators"
$system = [System.Security.Principal.NTAccount]"SYSTEM"

$accessRule1 = New-Object System.Security.AccessControl.FileSystemAccessRule($administrators, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$accessRule2 = New-Object System.Security.AccessControl.FileSystemAccessRule($system, "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")

$acl.SetAccessRuleProtection($True, $False) # Disable inheritance
$acl.ResetAccessRule($accessRule1)
$acl.AddAccessRule($accessRule2)

Set-Acl -Path $scriptDirectory -AclObject $acl

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass -File `"$wrapperScriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName 'OM-SystemLogonScript' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

# Run the wrapper script immediately
& $wrapperScriptPath