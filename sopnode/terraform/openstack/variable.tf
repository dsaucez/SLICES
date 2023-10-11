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
      "instance_count" = 2
    }
}

variable "master_image" {
  type = string
  default = "ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "master" {
  type = map
  default = {
      "instance_count" = 2
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
