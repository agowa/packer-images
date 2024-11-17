Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

$HKCU = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
$HKLM = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
Set-ItemProperty -Path $HKCU -Name '1803' -Value 0
Set-ItemProperty -Path $HKLM -Name '1803' -Value 0
