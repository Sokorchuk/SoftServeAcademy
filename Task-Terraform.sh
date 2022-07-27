#! /bin/bash

# Author: Ihor Sokorchuk, ihor.sokorchuk@nure.ua

work_dir="$HOME/softserve-terraform"

trap 'echo "$BASH_COMMAND";echo -n "# ";read' DEBUG

sudo apt update && sudo apt upgrade

sudo apt install virtualbox

mkdir -p ${work_dir} || exit
pushd ${work_dir}
pwd

lsb_release -cs
if false; then
    wget -O- https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
else
    wget -c https://releases.hashicorp.com/terraform/1.2.6/terraform_1.2.6_linux_amd64.zip && {
        unzip terraform_1.2.6_linux_amd64.zip
        chmod +x terraform
        ldd terraform
        mv -i terraform ~/bin/
        echo $PATH
    }
fi

terraform --version

true && {
    git clone https://github.com/shekeriev/terraform-provider-virtualbox.git
    pushd terraform-provider-virtualbox
    go build
    ls -l
    popd
}

ifconfig

[ -n ./variables.tf ] && cat >./variables.tf <<'VARIABLE_TF'
variable "network_adapter_type" {
    default = "bridged"
}

variable "host_interface" {
    default = "wlan0"
}

variable "image_url" {
    default = "https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20190507.0.0/providers/virtualbox.box"
}
VARIABLE_TF
cat ./variables.tf

[ -n ./main.tf ] && cat >./main.tf <<'MAIN_TF'
terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "node" {
    count = 2
    name = "${format("softserve-node-%02d", count.index+1)}"
    image = var.image_url
    cpus = 1
    memory = "512 mib"

     network_adapter {
       type = var.network_adapter_type
       host_interface=var.host_interface
    }
}
MAIN_TF
cat ./main.tf

terraform init
ls -l

terraform plan

terraform apply

read -p 'Destroy VMs [y/N]: '
[ "$REPLY" = 'y' ] && terraform destroy

popd

# EOF
