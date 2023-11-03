whitelist = ["10.0.1.0/24", "172.22.10.0/24", "10.8.0.0/24", "10.0.10.0/24", "10.0.20.0/24"]

rules = {
    "allow-ssh" = {
        description       = "allow-ssh"
        direction         = "ingress"
        protocol          = "tcp"
        port              = 22
        remote_prefix     = "0.0.0.0/0"
        tags              = ["ssh"]
    }
    "openvpn" = {
        description       = "allow-openvpn"
        direction         = "ingress"
        protocol          = "udp"
        port              = 1194
        remote_prefix     = "0.0.0.0/0"
        tags              = ["openvpn"]
    }

    "switch" = {
        description       = "switch-firewall"
        direction         = "ingress"
        protocol          = "tcp"
        port              = 8080
        remote_prefix     = "0.0.0.0/0"
        tags              = ["switch"]
    }
    "icmp" = {
        description       = "allow-icmp"
        direction         = "ingress"
        protocol          = "icmp"
        port              = 0
        remote_prefix     = "10.0.1.0/24"
    }
}

network = {
    subnet = "10.0.2.0/24"
    nameservers = ["8.8.4.4"]
}