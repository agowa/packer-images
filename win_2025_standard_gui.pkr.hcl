variable "vm_name" {
  type    = string
  default = "win_2025_standard_gui_en-US_template_-_latest"
}

variable "vm_admin_password" {
  type    = string
  default = "nxGdErlR5NGVtTM6xPjO"
}

variable "vcsa_autounattend" {
  type    = string
  default = "./answer-files/vcsa/win_2025_standard_gui/Autounattend.xml"
}

variable "vcsa_cluster" {
  type    = string
  default = "${env("packer_vcsa_cluster")}"
}

variable "vcsa_datastore" {
  type    = string
  default = "${env("packer_vcsa_datastore")}"
}

variable "vcsa_guest_ip" {
  type    = string
  default = "192.168.178.44"
}

variable "vcsa_insecure" {
  type    = string
  default = "true"
}

variable "vcsa_iso_path" {
  type    = string
  #default = "[${env("vcsa_iso_datastore")}] /ISOs/SW_DVD9_Win_Server_STD_CORE_2019_1809.11_64Bit_English_DC_STD_MLF_X22-51041.ISO"
}

variable "vcsa_network" {
  type    = string
  default = "${env("packer_vcsa_network")}"
}

variable "vcsa_username" {
  type    = string
  default = "${env("packer_vcsa_username")}"
}

variable "vcsa_password" {
  type    = string
  default = "${env("packer_vcsa_password")}"
}

variable "vcsa_server" {
  type    = string
  default = "${env("packer_vcsa_server")}"
}

source "vsphere-iso" "vsphere-iso" {
  CPU_hot_plug    = true
  CPU_limit       = -1
  CPUs            = 4
  NestedHV        = true
  RAM             = 16384
  RAM_hot_plug    = false
  RAM_reserve_all = false
  boot_command    = ["<spacebar><spacebar><wait1><enter>"]
  boot_wait       = "2s"
  cluster         = "${var.vcsa_cluster}"
  communicator    = "ssh"
  configuration_parameters = {
    "ctkEnabled"                           = "TRUE"
    "isolation.tools.copy.disable"         = "FALSE"
    "isolation.tools.paste.disable"        = "FALSE"
    "isolation.tools.setGUIOptions.enable" = "TRUE"
    "softPowerOff"                         = "FALSE"
    "tools.guest.desktop.autolock"         = "TRUE"
  }
  convert_to_template   = true
  datastore             = "${var.vcsa_datastore}"
  disk__controller_type = ["pvscsi"]
  firmware              = "efi-secure"
  floppy_dirs           = ["./drivers"]
  floppy_files          = [
    "${var.vcsa_autounattend}",
    "./scripts/Set-IPAddress.ps1",
    "./scripts/Set-IPAddress_${var.vcsa_guest_ip}.ps1",
    "./scripts/Install-GuestTools.ps1",
    "./scripts/Enable-MicrosoftUpdates.ps1",
    "./scripts/Install-OpenSSH.ps1"
  ]
  folder                = "Templates"
  guest_os_type         = "windows9Server64Guest"
  insecure_connection   = "${var.vcsa_insecure}"
  ip_wait_timeout       = "2h"
  iso_paths             = ["${var.vcsa_iso_path}"]
  network_adapters {
    network      = "${var.vcsa_network}"
    network_card = "vmxnet3"
  }
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  storage {
    disk_size             = 81920
    disk_thin_provisioned = true
  }
  tools_sync_time      = false
  tools_upgrade_policy = true
  vcenter_server       = "${var.vcsa_server}"
  username             = "${var.vcsa_username}"
  password             = "${var.vcsa_password}"
  video_ram            = 16384
  vm_name              = "${var.vm_name}"
  vm_version           = 13
  winrm_insecure       = true
  winrm_username       = "Administrator"
  winrm_password       = "${var.vm_admin_password}"
  ssh_username         = "Administrator"
  ssh_password         = "${var.vm_admin_password}"
}

build {
  sources = ["source.vsphere-iso.vsphere-iso"]
  name    = "vcsa win 2025 standard gui en-US"

  provisioner "powershell" {
    execute_command = "powershell $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; . {{ .Vars }}; . {{ .Path }};"
    scripts = [
      "./scripts/Set-WinTimeZone.ps1",
      "./scripts/Install-7zip.ps1",
      "./scripts/Install-Notepad++.ps1",
      #"./scripts/Set-Windows2025ProductKey.ps1",
      "./scripts/Start-WindowsActivation.ps1",
      "./scripts/Enable-IEFileDownloads.ps1",
      "./scripts/Configure-WindowsDefender.ps1",
      "./scripts/Hide-WindowsUpdateNotification.ps1",
      "./scripts/Disable-InfoCenter.ps1",
      "./scripts/Enable-SmartScreen.ps1",
      "./scripts/Enable-RDP.ps1",
      "./scripts/Disable-AutoLogon.ps1",
      "./scripts/Enable-SpectreMeltdownMitigation.ps1",
      "./scripts/Set-NetConnectionProfileToHome.ps1",
      "./scripts/Enable-InsecureWinRM.ps1"
    ]
  }

  provisioner "windows-update" {
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "exclude:$_.Title -like '*Silverlight*'",
      "include:$_.Title -like '*Cumulative Update for .NET Framework*'",
      "include:$_.Title -like '*Cumulative Update for Windows*'",
      "include:$_.AutoSelectOnWebSites"
    ]
  }

  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'Hello World'}\""
    restart_timeout       = "2h"
  }

  provisioner "powershell" {
    execute_command = "powershell $ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; . {{ .Vars }}; . {{ .Path }};"
    scripts = [
      "./scripts/Enable-SecureWinRM.ps1",
      "./scripts/Configure-PackageProvider.ps1",
      "./scripts/Optimize-DotNetAssemblies.ps1",
      "./scripts/Start-CleanUp.ps1",
      "./scripts/Disable-MapsManager.ps1",
      "./scripts/schannel-hardening-perfectforwardsecrecy.ps1",
      "./scripts/Enable-ICMPEchoRequest.ps1",
      "./scripts/Install-CloudbaseInit.ps1"
    ]
  }
}

packer {
  required_plugins {
    windows-update = {
      version = "0.16.8"
      source  = "github.com/rgl/windows-update"
    }
  }
}
