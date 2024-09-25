$githubScriptUrl = 'https://raw.githubusercontent.com/itsolver/LogonScripts/refs/heads/main/Remove-OutlookNew.ps1'
$regKeyLocation = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$psCommand = "PowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"& {Invoke-RestMethod '$githubScriptUrl' | Invoke-Expression}`""

if (-not(Test-Path -Path $regKeyLocation)) {
    New-Item -Path $regKeyLocation -Force | Out-Null
}

Set-ItemProperty -Path $regKeyLocation -Name 'Remove-OutlookNew' -Value $psCommand -Force

# Invoke the script immediately
Invoke-Expression -Command "& {Invoke-RestMethod '$githubScriptUrl' | Invoke-Expression}"