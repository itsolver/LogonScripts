$githubScriptUrl = 'https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/OptimumMovement/OM-LogonScript.ps1'
$regKeyLocation = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$psCommand = "PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"& {Invoke-RestMethod '$githubScriptUrl' | Invoke-Expression}`""

if (-not(Test-Path -Path $regKeyLocation)) {
    New-Item -Path $regKeyLocation -Force | Out-Null
}

Set-ItemProperty -Path $regKeyLocation -Name 'OM-LogonScript' -Value $psCommand -Force

# Invoke the script immediately
Invoke-Expression -Command "& {Invoke-RestMethod '$githubScriptUrl' | Invoke-Expression}"