Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

# Enable RDP
Set-ItemProperty `
  -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' `
  -Name "fDenyTSConnections" `
  -Value 0

# Enable NLA
Set-ItemProperty `
  -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' `
  -Name "UserAuthentication" `
  -Value 1

# Enable Firewall Rules
Enable-NetFirewallRule -Group '@FirewallAPI.dll,-28752' #"Remote Desktop"
