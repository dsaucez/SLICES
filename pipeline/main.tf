# Edit /etc/libvirt/qemu.conf to set `security_driver = "none"`
# Then restart libvirtd `sudo systemctl restart libvirtd`
# 
# Set your provider URI, examples:
#  export LIBVIRT_DEFAULT_URI="qemu+ssh://ubuntu@localhost/system"
#  export LIBVIRT_DEFAULT_URI="qemu:///system"
#
# export TF_VAR_instances='["leftclient","rightclient","leftswitch"]' 
#
# terraform init
# terraform validate
# terraform plan
# terraform apply
# terraform refresh && terraform output ips
# terraform destroy

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

terraform {
  required_version = ">= 1.6.6"
}

provider "libvirt" {
  // uri = "qemu:///system"
}

// variables 
variable "memory" { default = 4 * 1024 } // memory in MB
variable "cpu" { default = 2 } // number of cores
variable "disk" { default = 4 * 1024 * 1024 * 1024 } // disk size in Bytes
variable "image_source" { default = "https://cloud-images.ubuntu.com/releases/jammy/release/ubuntu-22.04-server-cloudimg-amd64.img" } // cloud-init qcow2 image
variable "pool" { default = "blueprint" }
variable "pool_path" { default = "/tmp/pools" }
variable "public_key" { default = "~/.ssh/id_rsa.pub" }
variable "cloud_init_file" { default = "cloud_init.cfg" }
variable "network_config_file" { default = "network_config.cfg" }


variable "instances" { type    = list(string) }

resource "libvirt_pool" "blueprint" {
  name = "blueprint"
  type = "dir"
  path = "${var.pool_path}/${var.pool}"
}

// fetch base image
resource "libvirt_volume" "base_image" {
 name = "base-image.qcow2"
 pool   = libvirt_pool.blueprint.name
 source = var.image_source
 format = "qcow2"
}

resource "libvirt_volume" "domain_volume" {
  count          = length(var.instances)
  name           = "${var.instances[count.index]}_volume"
  base_volume_id = libvirt_volume.base_image.id
  pool           = libvirt_pool.blueprint.name
  size           = var.disk
}


// Use CloudInit ISO to add ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.instances)
  name = "${var.instances[count.index]}-commoninit.iso"
  pool = libvirt_pool.blueprint.name
  user_data      = data.template_cloudinit_config.config[count.index].rendered
  network_config = data.template_file.network_config.rendered
}

data "template_file" "user_data" {
  count = length(var.instances)
  template = file(var.cloud_init_file)
  vars = {
    hostname = var.instances[count.index]
    public_key = file(var.public_key)
  }
}

data "template_cloudinit_config" "config" {
  count = length(var.instances)
  gzip = false
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.user_data[count.index].rendered}"
  }
}

data "template_file" "network_config" {
  template = file(var.network_config_file)
}

// Create the machine
resource "libvirt_domain" "domain" {
  count = length(var.instances)
  name = var.instances[count.index]
  memory = var.memory
  vcpu = 2

  disk {
    volume_id = libvirt_volume.domain_volume[count.index].id
  }

  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

output "instances" {
  value = var.instances
}

output "instance_ips" {
  value = libvirt_domain.domain.*.network_interface.0.addresses
}
