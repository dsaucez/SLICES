
variable "rules" {
  type = map(object({
    description       = string
    direction         = string
    protocol          = string
    port              = number
    remote_prefix  = string
  }))
  default = {
    "allow-ssh" = {
      description       = "allow-ssh"
      direction         = "ingress"
      protocol          = "tcp"
      port              = 22
      remote_prefix  = "0.0.0.0/0"
    }
    "openvpn" = {
      description       = "allow-openvpn"
      direction         = "ingress"
      protocol          = "udp"
      port              = 1194
      remote_prefix  = "0.0.0.0/0"
    }

    "switch" = {
      description       = "switch-firewall"
      direction         = "ingress"
      protocol          = "tcp"
      port              = 8080
      remote_prefix  = "0.0.0.0/0"
    }
    "icmp" = {
      description       = "allow-icmp"
      direction         = "ingress"
      protocol          = "icmp"
      port              = 0
      remote_prefix  = "10.0.1.0/24"
    }
  }
}