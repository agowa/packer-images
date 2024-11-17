Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

function Test-Attribute($Object, $Attribute) {
  return $Attribute -in $Object.PSobject.Properties.Name
}

function Remove-RegistryKey($Path, $Name) {
  if(Test-Attribute -object (Get-ItemProperty -Path $Path) -attribute $Name) {
    Remove-ItemProperty -Force -Path $Path -Name $Name -ErrorAction SilentlyContinue
  }
}

# Disable Windows Update Services
Set-Service -Name "wuauserv" -StartupType Disabled -PassThru | Stop-Service
Set-Service -Name "BITS" -StartupType Disabled -PassThru | Stop-Service
#Set-Service -Name "DoSvc" -StartupType Disabled -PassThru | Stop-Service
# This throws an access denied error, but when changing the registry key, it works
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc" -Name "Start" -Value 4; Stop-Service -Name "DoSvc" -Force

# Remove Windows Update Files and persistent identifiers
try { Get-ScheduledTask -TaskName packer* | Unregister-ScheduledTask -Confirm:$false } catch {}
if([Boolean](Test-Path -Path 'C:\Windows\SoftwareDistribution\Download' )) {
  try {
    Remove-Item -Recurse -Force -Path 'C:\Windows\SoftwareDistribution\Download'
  } catch [System.IO.DirectoryNotFoundException] {}
}
Remove-RegistryKey -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' -Name 'PingID'
Remove-RegistryKey -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' -Name 'AccountDomainSid'
Remove-RegistryKey -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' -Name 'SusClientId'
Remove-RegistryKey -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate' -Name 'SusClientIDValidation'

# Reenable windows update services but don't start them
Set-Service -Name "wuauserv" -StartupType Manual
Set-Service -Name "BITS" -StartupType Manual
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\DoSvc" -Name "Start" -Value 2
