Set-StrictMode -Version 2
$DebugPreference="SilentlyContinue"
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"
$WarningPreference="Continue"

Set-MpPreference `
  -DisableCatchupFullScan:$false `
  -DisableCatchupQuickScan:$false `
  -DisableEmailScanning:$false `
  -DisableIntrusionPreventionSystem:$false `
  -DisableremovableDriveScanning:$false `
  -SubmitSamplesConsent:0 `
  -UILockdown:$true
