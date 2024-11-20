#!/bin/sh

export vcsa_iso_datastore="esxi-dc04.local01"
export packer_vcsa_datacenter="BU-CloudInfra"
export packer_vcsa_datastore="esxi-dc04.local02"
export packer_vcsa_cluster="172.31.1.66"
export packer_vcsa_network="VLAN60"
#export packer_vcsa_username=""
#export packer_vcsa_password=""
export packer_vcsa_server="htzvcsa01.hetzner.lab"

packer init win_2019_standard_gui.pkr.hcl
packer init win_2022_standard_gui.pkr.hcl
packer init win_2025_standard_gui.pkr.hcl

packer build win_2019_standard_gui.pkr.hcl
packer build win_2022_standard_gui.pkr.hcl
packer build win_2025_standard_gui.pkr.hcl
