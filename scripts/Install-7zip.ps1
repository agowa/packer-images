Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$newVersionURL = 'https://www.7-zip.org/a/7z2408-x64.msi'
$TempFile = Join-Path -Path $env:TEMP -ChildPath '7z2408-x64.msi'
Invoke-WebRequest -Uri $newVersionURL -OutFile $TempFile -UseBasicParsing

$package = (Get-Package -ProviderName msi).where{$_.Name -like '7-Zip * (x64 edition)' }
if ([bool]$package) {
  $null = Get-Package -Name '7-Zip * (x64 edition)' -ProviderName msi | Uninstall-Package -Force -PackageManagementProvider msi
}
$MSIArguments = @(
  '/i'
  ('"{0}"' -f $TempFile)
  '/qn'
  '/norestart'
)
Start-Process -FilePath 'msiexec.exe' -ArgumentList $MSIArguments -Wait -NoNewWindow
if (Test-Path -Path $TempFile) {
  Remove-Item -Path $TempFile -Force
}
