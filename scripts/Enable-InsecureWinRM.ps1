Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

winrm quickconfig -q
winrm quickconfig -transport:http
Set-Item -Path WSMan:\localhost\MaxTimeoutms -Value 1800000
((Get-ChildItem -Path WSMan:\localhost\Listener).Where{(Get-ChildItem "$($_.PSPath)\Transport").Value.Equals("HTTP")}).foreach{Set-Item -Path "$($_.PSPath)\Port" -Value 5985 -Force}
Set-Item -Path WSMan:\localhost\Client\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
Set-Item -Path WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 800
Get-NetFirewallRule -Group "@FirewallAPI.dll,-30267" | Enable-NetFirewallRule # "Windows Remote Management"
Stop-Service -Name WinRM -Force
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM
