Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

Set-Location -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'

New-Item `
  -Name 'Explorer' `
  -ItemType Container `
  -Force

Set-ItemProperty `
  -Path Explorer `
  -Name 'DisableNotificationCenter' `
  -Value 1 `
  -Type DWord
