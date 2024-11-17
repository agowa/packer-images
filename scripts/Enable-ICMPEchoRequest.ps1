Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

(Get-NetFirewallRule -Group "@FirewallAPI.dll,-28502").Where{$_.Name -like "*ICMP*"} | Enable-NetFirewallRule
