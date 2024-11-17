Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

Set-Location -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'

New-ItemProperty `
  -Path System `
  -Name EnableSmartScreen `
  -Value 1 `
  -PropertyType DWord `
  -Force

New-ItemProperty `
  -Path System `
  -Name ShellSmartScreenLevel `
  -Value 'Warn' `
  -PropertyType String `
  -Force
