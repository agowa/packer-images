# http://support.microsoft.com/kb/2570538
# http://robrelyea.wordpress.com/2007/07/13/may-be-helpful-ngen-exe-executequeueditems/

Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

$ngenPaths = @(
    "$env:windir\microsoft.net\framework\v4.0.30319\ngen.exe"
    "$env:windir\microsoft.net\framework64\v4.0.30319\ngen.exe"
)

function Optimize-DotnetAssemblies {
  param(
    [String]$ngenPath
  )
  $Arguments = @(
    'update',
    '/force',
    '/queue'
  )
  Start-Process -FilePath $ngenPath -ArgumentList $Arguments -Wait -NoNewWindow
  $Arguments = @(
    'executequeueditems'
  )
  Start-Process -FilePath $ngenPath -ArgumentList $Arguments -Wait -NoNewWindow
}

$ngenPaths.where{Test-Path -Path $_}.foreach{Optimize-DotnetAssemblies -ngenPath $_}
