Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

function Install-VMwareGuestTools() {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  $latestVersionPage = Invoke-WebRequest -Uri 'https://packages.vmware.com/tools/releases/latest/windows/x64/index.html' -UseBasicParsing
  $newVersionURL = 'https://packages.vmware.com/tools/releases/latest/windows/x64/{0}' -f $latestVersionPage.Links.where{$_.outerHTML -like '*VMware-tools*x86_64.exe*'}.HREF
  $TempFile = Join-Path -Path $env:TEMP -ChildPath 'VMwareTools.exe'

  Invoke-WebRequest -Uri $newVersionURL -OutFile $TempFile -UseBasicParsing
  $package = (Get-Package -ProviderName msi).where{$_.Name -like 'VMware Tools' }
  if ([bool]$package) {
    $null = Get-Package -Name 'VMware Tools' -ProviderName msi | Uninstall-Package -Force -PackageManagementProvider msi
  }
  $Arguments = @(
    '/x'
  )
  Start-Process -FilePath $TempFile -ArgumentList $Arguments -Wait -NoNewWindow
  Start-Sleep -Seconds 2
  $Arguments = @(
    '/install'
    '/quiet'
    '/norestart'
  )
  $extractDir = (Resolve-Path -Path (Join-Path -Path $env:TEMP -ChildPath '*~setup')).Path
  $vcredistPath = Join-Path -Path $extractDir -ChildPath 'vcredist_x64.exe'
  Start-Process -FilePath $vcredistPath -ArgumentList $Arguments -Wait -NoNewWindow
  Start-Sleep -Seconds 2
  $Arguments = @(
    '/i'
    '"{0}\{1}"' -f $extractDir, 'VMware Tools64.msi'
    '/qn'
    '/quiet'
    '/norestart'
  )
  Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList $Arguments -Wait -NoNewWindow

  Start-Sleep -Seconds 5
  if (Test-Path -Path $TempFile) {
    Remove-Item -Path $TempFile -Force
  }
  if (Test-Path -Path $extractDir) {
    Remove-Item -Path $extractDir -Force -Recurse
  }
}

function Install-QEMUKVMGuestTools() {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

  $newVersionURL = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso'
  $TempFile = Join-Path -Path $env:TEMP -ChildPath 'virtio-win.iso'

  [System.Net.WebClient]::new().DownloadFile($newVersionURL, $TempFile)
  $package = (Get-Package -ProviderName msi).where{$_.Name -like 'Virtio-win-guest-tools' }
  if ([bool]$package) {
    $null = $package | Uninstall-Package -Force -PackageManagementProvider msi
  }
  Start-Sleep -Seconds 2
  $isoMount = Mount-DiskImage -ImagePath "$TempFile" -StorageType ISO
  $isoDriveLetter = ($isoMount | Get-Volume).DriveLetter
  $setupPath = "$($isoDriveLetter):\virtio-win-gt-x64.msi"
  $importedCerts = Import-Certificate -FilePath 'E:\amd64\2k19\vioscsi.cat' -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
  $importedCerts.Where{$_.Thumbprint -ne 'F01DAC89598C52D94FE8CA91187E1853947D115A'}.PSPath | Remove-Item
  $Arguments = @(
    '/i'
    "$setupPath"
    'ADDLOCAL=ALL'
    'REMOVE=FE_spice_Agent,FE_RHEV_Agent'
    '/qn'
    '/quiet'
    '/norestart'
  )
  Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList $Arguments -Wait -NoNewWindow

  Start-Sleep -Seconds 5
  if (Test-Path -Path $TempFile) {
    Remove-Item -Path $TempFile -Force
  }
}

[bool]$isVMwareGuest = (Get-CimInstance -ClassName Win32_BIOS).Manufacturer.Contains('VMware') -or (Get-CimInstance -ClassName Win32_BIOS).SerialNumber.Contains('VMware')
[bool]$isQEMUKVM = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer.Equals('QEMU')

if ($isVMwareGuest) {
  Install-VMwareGuestTools
} elseif ($isQEMUKVM) {
  Install-QEMUKVMGuestTools
}
