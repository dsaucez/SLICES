# image= "rhel-cloud/rhel-9"
# image= "rhel-cloud/rhel-8"
# image = "rocky-linux-cloud/rocky-linux-9-v20230306"
# image = "ubuntu-os-cloud/ubuntu-2004-lts"
# image = "ubuntu-os-cloud/ubuntu-2204-lts"
# image = "debian-cloud/debian-10"
# image = "debian-cloud/debian-11"
# image = "fedora-cloud/fedora-cloud-36"
# image = "fedora-cloud/fedora-cloud-37"

variable "switch_image" {
  type = string
  default = "debian-cloud/debian-10"
}
variable "switch" {
  type = map
  default = {
      "instance_count" = 0
    }
}

variable "compute_image" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "compute" {
  type = map
  default = {
      "instance_count" = 1
    }
}

variable "master_image" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "master" {
  type = map
  default = {
      "instance_count" = 1
    }
}

variable "openvpn_image" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "openvpn" {
  type = map
  default = {
      "instance_count" = 1
    }
}