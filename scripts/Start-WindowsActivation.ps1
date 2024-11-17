Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

$EXEArguments = @(
  'C:\Windows\System32\slmgr.vbs',
  '/ato'
)

Start-Process `
  -FilePath 'C:\Windows\System32\cscript.exe' `
  -ArgumentList $EXEArguments `
  -Wait `
  -NoNewWindow
