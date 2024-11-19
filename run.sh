#!/bin/sh

export vcsa_iso_datastore=""
export packer_vcsa_datacenter=""
export packer_vcsa_datastore=""
export packer_vcsa_cluster=""
export packer_vcsa_network=""
#export packer_vcsa_username=""
#export packer_vcsa_password=""
export packer_vcsa_server=""

packer init win_2019_standard_gui.pkr.hcl
packer init win_2022_standard_gui.pkr.hcl
packer init win_2025_standard_gui.pkr.hcl

packer build win_2019_standard_gui.pkr.hcl
packer build win_2022_standard_gui.pkr.hcl
packer build win_2025_standard_gui.pkr.hcl
