cloud_provider = "gcp"

publickey = {
    name  = "mykey"
    key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuamOAVQDpVDyIb5yhP8kvEFGuTv32YBV5sZJ8+5HkPte0qq0/kmA7vp/9L7Mgbq4vCA4jBkbAflJeTw25F+0yl8P/Jaz0wnLkoYxtYXbBwv9sdGjbcvp1To1uyXhj+JCkklGKAqJ+V+Ap98NQEwm61AbuztGNgtpWUCaeqc2xYMxSYqTWX08P0F6KRQdQwLH3myiueflQKDXOLH31KPqmYVIEch5R+3SEmqLxUFDPWKmJgZ4eQESTkM1TfkN8jnoyPqBSs/01k+qMXd/DBsAD/rINJPE6ht8vl1k4SkrIFl4Apc5hO7xAJp+d7hvScrVGa3gZdcpPpaReVs2N1AAqw1RHEZqADm3t3bUwjvcIu7vz9WeNdSE5UjSM9oydr3w1iVR73iPpybWdzRvxtywQ8qzwJjeb3DvbcDH/jtoRr0N30Dd7HO3sFK8RD2ZMTxOnU72oyYdk3BrlvsV/6AsZvtYM1eSc4x0iDjGSaJmfc+6OeNi+KYZb7MOBHM/FoHE= dsaucez@srv-diana"
}

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
    name                = "slices-network"
    subnet_name         = "slices-subnet"
    subnet              = "10.0.2.0/24"
    nameservers         = ["8.8.4.4"]
    external_network_id = "a2a9e3e7-c94f-4a8d-be15-5a043dbefcc4"
}

instances = {
    "compute" = {
        instance_count  = 1
        image           = "ubuntu-os-cloud/ubuntu-2004-lts"
        flavor          = "e2-medium"
        zone            = "europe-west8-a"
        publickey_name  = "mykey"
        network_name    = "slices-network"
        security_groups = ["firewall"]
        tags            = ["ssh"]
    }
    "master" = {
        instance_count  = 1
        image           = "ubuntu-os-cloud/ubuntu-2004-lts"
        flavor          = "e2-medium"
        zone            = "europe-west8-a"
        publickey_name  = "mykey"
        network_name    = "slices-network"
        security_groups = ["firewall"]
        tags            = ["ssh"]
    }
    "switch" = {
        instance_count  = 1
        image           = "ubuntu-os-cloud/ubuntu-2004-lts"
        flavor          = "e2-medium"
        zone            = "europe-west8-a"
        publickey_name  = "mykey"
        network_name    = "slices-network"
        security_groups = ["firewall"]
        tags            = ["ssh", "switch"]
    }
    "openvpn" = {
        instance_count  = 1
        image           = "ubuntu-os-cloud/ubuntu-2004-lts"
        flavor          = "e2-medium"
        zone            = "europe-west8-a"
        publickey_name  = "mykey"
        network_name    = "slices-network"
        security_groups = ["firewall"]
        tags            = ["ssh", "openvpn"]
    }
}