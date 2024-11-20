Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

try {
  Set-Service -Name MapsBroker -StartupType Disabled
} catch {
  Write-Host "MapsBroker service not found, disabling was skipped."
}
