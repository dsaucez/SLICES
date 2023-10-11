terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "secret"
  auth_url    = "http://172.16.36.136/identity"
  region      = "RegionOne"
}

resource "openstack_compute_keypair_v2" "my-cloud-key" {
  name       = "my-key-terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuamOAVQDpVDyIb5yhP8kvEFGuTv32YBV5sZJ8+5HkPte0qq0/kmA7vp/9L7Mgbq4vCA4jBkbAflJeTw25F+0yl8P/Jaz0wnLkoYxtYXbBwv9sdGjbcvp1To1uyXhj+JCkklGKAqJ+V+Ap98NQEwm61AbuztGNgtpWUCaeqc2xYMxSYqTWX08P0F6KRQdQwLH3myiueflQKDXOLH31KPqmYVIEch5R+3SEmqLxUFDPWKmJgZ4eQESTkM1TfkN8jnoyPqBSs/01k+qMXd/DBsAD/rINJPE6ht8vl1k4SkrIFl4Apc5hO7xAJp+d7hvScrVGa3gZdcpPpaReVs2N1AAqw1RHEZqADm3t3bUwjvcIu7vz9WeNdSE5UjSM9oydr3w1iVR73iPpybWdzRvxtywQ8qzwJjeb3DvbcDH/jtoRr0N30Dd7HO3sFK8RD2ZMTxOnU72oyYdk3BrlvsV/6AsZvtYM1eSc4x0iDjGSaJmfc+6OeNi+KYZb7MOBHM/FoHE= dsaucez@srv-diana"
}

resource "openstack_networking_network_v2" "default_network" {
  name           = "slices-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "default_network" {
  name            = "default-subnet"
  ip_version      = 4
  cidr            = "10.0.1.0/24"
  dns_nameservers = ["8.8.8.8"]
  network_id      = openstack_networking_network_v2.default_network.id
}


resource "openstack_networking_router_v2" "router_1" {
  name                = "my_router"
  external_network_id = "a2a9e3e7-c94f-4a8d-be15-5a043dbefcc4"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.router_1.id
  subnet_id = openstack_networking_subnet_v2.default_network.id
}

resource "openstack_compute_instance_v2" "compute" {
  count           = var.compute.instance_count
  name            = "compute-${count.index + 1}"
  image_name      = "ubuntu-20.04-server"
  flavor_name     = "m1.small"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = ["firewall"]

  network {
    name = "${openstack_networking_network_v2.default_network.name}"
  }
}

#resource "openstack_networking_floatingip_v2" "floatip_test_vm" {
#  pool = "public"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "fip_1" {
#  floating_ip = openstack_networking_floatingip_v2.floatip_test_vm.address
#  instance_id = openstack_compute_instance_v2.compute.id
#}


