# image= "rhel-cloud/rhel-9"
# image= "rhel-cloud/rhel-8"
# image = "rocky-linux-cloud/rocky-linux-9-v20230306"
# image = "ubuntu-os-cloud/ubuntu-2004-lts"
# image = "ubuntu-os-cloud/ubuntu-2204-lts"
# image = "debian-cloud/debian-10"
# image = "debian-cloud/debian-11"
# image = "fedora-cloud/fedora-cloud-36"
# image = "fedora-cloud/fedora-cloud-37"

variable "prefixes" {
  type    = list(string)
  default = ["172.22.10.0/24", "10.8.0.0/24", "10.0.10.0/24", "10.0.20.0/24"]
}

variable "publickey" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuamOAVQDpVDyIb5yhP8kvEFGuTv32YBV5sZJ8+5HkPte0qq0/kmA7vp/9L7Mgbq4vCA4jBkbAflJeTw25F+0yl8P/Jaz0wnLkoYxtYXbBwv9sdGjbcvp1To1uyXhj+JCkklGKAqJ+V+Ap98NQEwm61AbuztGNgtpWUCaeqc2xYMxSYqTWX08P0F6KRQdQwLH3myiueflQKDXOLH31KPqmYVIEch5R+3SEmqLxUFDPWKmJgZ4eQESTkM1TfkN8jnoyPqBSs/01k+qMXd/DBsAD/rINJPE6ht8vl1k4SkrIFl4Apc5hO7xAJp+d7hvScrVGa3gZdcpPpaReVs2N1AAqw1RHEZqADm3t3bUwjvcIu7vz9WeNdSE5UjSM9oydr3w1iVR73iPpybWdzRvxtywQ8qzwJjeb3DvbcDH/jtoRr0N30Dd7HO3sFK8RD2ZMTxOnU72oyYdk3BrlvsV/6AsZvtYM1eSc4x0iDjGSaJmfc+6OeNi+KYZb7MOBHM/FoHE= dsaucez@srv-diana"
}

variable "switch" {
  type = map
  default = {
      "instance_count" = 0
    }
}
variable "switch_image" {
  type = string
  default = "ubuntu-20.04-server" #"ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "compute_image" {
  type = string
  default = "ubuntu-20.04-server" #"ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "compute" {
  type = map
  default = {
      "instance_count" = 1
    }
}

variable "master_image" {
  type = string
  default = "ubuntu-20.04-server" #"ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "master" {
  type = map
  default = {
      "instance_count" = 1
    }
}

variable "openvpn_image" {
  type = string
  default = "ubuntu-20.04-server" #"ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "openvpn" {
  type = map
  default = {
      "instance_count" = 1
    }
}
