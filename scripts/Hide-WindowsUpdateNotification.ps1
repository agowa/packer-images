Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

$HKLM = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'
Set-ItemProperty -Path $HKLM -Name 'UpdatesAvailableForDownloadLogon' -Value 0
Set-ItemProperty -Path $HKLM -Name 'UpdatesAvailableForInstallLogon' -Value 0
