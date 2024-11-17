Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

function Install-PowerShellCore {
  param()
  $pwshInstallFolderName = 'PowerShell'

  $pwshInstallPath = $env:ProgramFiles
  $pwshTempFile = Join-Path -Path $env:TEMP -ChildPath 'Pwsh.msi'
  $pwshInstallPath = Join-Path -Path $pwshInstallPath -ChildPath $pwshInstallFolderName
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $newVersionJson = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest' -UseBasicParsing).Content
  $newVersionURL = $newVersionJson.assets.where{$_.name -like 'PowerShell-*-win-x64.msi'}.browser_download_url

  Invoke-WebRequest -Uri $newVersionURL -OutFile $pwshTempFile -UseBasicParsing

  $package = (Get-Package -ProviderName msi).where{$_.Name -like 'PowerShell *' }
  if ([bool]$package) {
    $null = $package | Uninstall-Package -Force -PackageManagementProvider msi
  }
  $MSIArguments = @(
    '/i'
    ('"{0}"' -f $pwshTempFile)
    '/qn'
    '/norestart'
  )
  Start-Process -FilePath 'msiexec.exe' -ArgumentList $MSIArguments -Wait -NoNewWindow
  if (Test-Path -Path $pwshTempFile) {
    Remove-Item -Path $pwshTempFile -Force
  }
  $pwshInstallPath = (Get-ChildItem $pwshInstallPath)[0].FullName # Only one version of PowerShell core is installed. This script uninstalled all other versions (excluding Windows PowerShell).
  Push-Location -Path $pwshInstallPath
  $pwshArguments = @(
    '-NoLogo'
    '-NonInteractive'
    '-ExecutionPolicy'
    'RemoteSigned'
    '-NoProfile'
    '-File'
    ('"{0}\Install-PowerShellRemoting.ps1"' -f (Get-Location).Path)
  )
  Start-Process -FilePath '.\pwsh.exe' -ArgumentList $pwshArguments -Wait -NoNewWindow -WorkingDirectory $pwshInstallPath
  Pop-Location

  # Add PowerShell Core directory to path
  $path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -split ';'
  if ($path -notcontains $pwshInstallPath) {
    $path += $pwshInstallPath
  }
  [Environment]::SetEnvironmentVariable('Path', $path -join ';', [System.EnvironmentVariableTarget]::Machine)
}

function Install-OpenSSH {
  param(
    [Parameter(Mandatory)][string]$OpenSSHInstallPath
  )
  $OpenSSHInstallFolderName = 'OpenSSH-Win64' # Name of the folder inside of the downloaded zip file

  $OpenSSHTempFile = Join-Path -Path $env:TEMP -ChildPath 'openssh.zip'
  $OpenSSHInstallPath2 = Join-Path -Path $OpenSSHInstallPath -ChildPath $OpenSSHInstallFolderName
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $newVersionURL = (ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri 'https://api.github.com/repos/PowerShell/Win32-OpenSSH/releases/latest' -UseBasicParsing).Content).assets.where{$_.name -eq 'OpenSSH-Win64.zip'}.browser_download_url
  Invoke-WebRequest -Uri $newVersionURL -OutFile $OpenSSHTempFile -UseBasicParsing
  if (Test-Path -Path $OpenSSHInstallPath2) {
    Push-Location -Path $OpenSSHInstallPath2
    try {
      .\uninstall-sshd.ps1
    } catch {}
    Pop-Location
    Remove-Item -Path $OpenSSHInstallPath2 -Recurse -Force
  }
  Expand-Archive -Path $OpenSSHTempFile -DestinationPath $OpenSSHInstallPath -Force
  if (Test-Path -Path $OpenSSHTempFile) {
    Remove-Item -Path $OpenSSHTempFile -Force
  }
  Push-Location -Path $OpenSSHInstallPath2
  Import-Module "C:\Program Files\OpenSSH-Win64\OpenSSHUtils.psm1"
  .\install-sshd.ps1 -Confirm:$false
  .\FixHostFilePermissions.ps1 -Confirm:$false
  .\FixUserFilePermissions.ps1 -Confirm:$false
  Pop-Location
  New-Item -Path $env:ProgramData -Name 'ssh' -ItemType Directory -Force

  # Add SSH directory to path
  $path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine) -split ';'
  if ($path -notcontains $OpenSSHInstallPath2) {
    $path += $OpenSSHInstallPath2
  }
  [Environment]::SetEnvironmentVariable('Path', $path -join ';', [System.EnvironmentVariableTarget]::Machine)
}

function Write-SSHDConfig {
  param(
    [Parameter(Mandatory)][string]$Path,
    [String]$DefaultShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    [String]$DefaultShellCommandOption = $null
  )
  $configFile = @'
Port 22
AuthorizedKeysFile	.ssh/authorized_keys
PasswordAuthentication yes
PubkeyAuthentication yes
Subsystem	sftp	sftp-server.exe
'@
  if([bool](Get-Command -Name 'pwsh.exe' -ErrorAction SilentlyContinue)) {
    $configFile += "`r`nSubsystem	powershell	pwsh.exe -sshs -NoLogo -NoProfile"
  }
  Out-File -InputObject $configFile -FilePath $Path -Encoding utf8 -Force
  New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -ItemType Directory -Force
  if ([bool]$DefaultShell) {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $DefaultShell -PropertyType String -Force
  } else {
    if ([bool](Get-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name 'DefaultShell' -ErrorAction SilentlyContinue)) {
      Remove-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name 'DefaultShell'
    }
  }
  if ([bool]$DefaultShellCommandOption) {
    New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShellCommandOption -Value $DefaultShellCommandOption -PropertyType String -Force
  } else {
    if ([bool](Get-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name 'DefaultShellCommandOption' -ErrorAction SilentlyContinue)) {
      Remove-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name 'DefaultShellCommandOption'
    }
  }
}

function Set-SSHDFirewallPolicy() {
  param(
    [switch]$disable
  )
  if ([bool](Get-NetFirewallRule -Name sshd -ErrorAction SilentlyContinue)) {
    if ($disable) {
      Remove-NetFirewallRule -Name 'sshd'
    }
  } else {
    New-NetFirewallRule -Name 'sshd' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
  }
}

function Set-SSHDAutostart() {
  param(
    [switch]$disable
  )
  if ($disable) {
    Set-Service -Name 'sshd' -StartupType Manual
    Set-Service -Name 'ssh-agent' -StartupType Manual
  } else {
    Set-Service -Name 'sshd' -StartupType Automatic
    Set-Service -Name 'ssh-agent' -StartupType Automatic
  }
}

Install-PowerShellCore
Install-OpenSSH -OpenSSHInstallPath $env:ProgramFiles
Write-SSHDConfig -Path "$env:ProgramData/ssh/sshd_config" -DefaultShell ""
Set-SSHDFirewallPolicy
Set-SSHDAutostart
Start-Service -Name 'sshd'
Start-Service -Name 'ssh-agent'
