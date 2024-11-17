Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$newVersionJson = ConvertFrom-Json -InputObject (Invoke-WebRequest -Uri 'https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest' -UseBasicParsing).Content
$newVersionURL = $newVersionJson.assets.where{$_.name -like 'npp.*.Installer.x64.exe'}.browser_download_url

$TempFile = Join-Path -Path $env:TEMP -ChildPath 'npp.exe'
Invoke-WebRequest -Uri $newVersionURL -UseBasicParsing -OutFile $TempFile

$EXEArguments = @(
  '/S'
)
Start-Process -FilePath $TempFile -ArgumentList $EXEArguments -Wait -NoNewWindow
if (Test-Path -Path $TempFile) {
  Remove-Item -Path $TempFile -Force
}
