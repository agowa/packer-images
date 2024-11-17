Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

Set-ItemProperty `
  -Path $RegPath "AutoAdminLogon" `
  -Value "0" `
  -type String

Set-ItemProperty `
  -Path $RegPath "DefaultUsername" `
  -Value "" `
  -type String

Set-ItemProperty `
  -Path $RegPath "DefaultPassword" `
  -Value "" `
  -type String
