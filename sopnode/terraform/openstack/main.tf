terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

# == Configure the provider ========================================================
provider "openstack" {
#  token = "gAAAAABlN4NeztQ-HQNDqWy-BymDNlWGJDx4lOILM47liWcdAjh6YM0Gws-uAVigUIx8dw9f93Kc_8wwQYxEZ5MgqWk2jErX7IJQ33yrqzEClmVChhLHv6Wc2lUE9s3Wc9Ds8--G4pBtaRo-OMpektSa9qc6xfPG1rY1hKdtLcptD3worBBvXw4"
  user_name   = "admin"
  tenant_name = "admin"
  password    = "secret"
  auth_url    = "http://172.16.36.136/identity"
  region      = "RegionOne"
}

# == SSH ===========================================================================
resource "openstack_compute_keypair_v2" "ssh_key" {
  name       = "my-key-terraform"
  public_key = var.publickey
}

# == Create the network ============================================================
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

# Attach the network to the external network
resource "openstack_networking_router_v2" "default_network_router" {
  name                = "default_network_router"
  external_network_id = "a2a9e3e7-c94f-4a8d-be15-5a043dbefcc4"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.default_network_router.id
  subnet_id = openstack_networking_subnet_v2.default_network.id
}

# == Launch instances ===============================================================
resource "openstack_compute_instance_v2" "compute" {
  count           = var.compute.instance_count
  name            = "compute-${count.index + 1}"
  image_name      = var.compute_image
  flavor_name     = "ds1G"
  key_pair        = "${openstack_compute_keypair_v2.ssh_key.name}"
  security_groups = ["firewall"]

  network {
    name = "${openstack_networking_network_v2.default_network.name}"
  }
}

resource "openstack_compute_instance_v2" "master" {
  count           = var.master.instance_count
  name            = "master-${count.index + 1}"
  image_name      = var.master_image
  flavor_name     = "ds1G"
  key_pair        = "${openstack_compute_keypair_v2.ssh_key.name}"
  security_groups = ["firewall"]

  network {
    name = "${openstack_networking_network_v2.default_network.name}"
  }
}

resource "openstack_compute_instance_v2" "switch" {
  count           = var.switch.instance_count
  name            = "switch-${count.index + 1}"
  image_name      = var.switch_image
  flavor_name     = "ds1G"
  key_pair        = "${openstack_compute_keypair_v2.ssh_key.name}"
  security_groups = ["firewall"]

  network {
    name = "${openstack_networking_network_v2.default_network.name}"
  }
}

resource "openstack_compute_instance_v2" "openvpn" {
  count           = var.openvpn.instance_count
  name            = "openvpn-${count.index + 1}"
  image_name      = var.openvpn_image
  flavor_name     = "ds1G"
  key_pair        = "${openstack_compute_keypair_v2.ssh_key.name}"
  security_groups = ["firewall"]

  network {
    name = "shared"
  }
}


### ============== RAN ===============================================================
### == Create the network ============================================================
##resource "openstack_networking_network_v2" "ran_network" {
##  name           = "ran-network"
##  admin_state_up = "true"
##}
##
##resource "openstack_networking_subnet_v2" "ran_network" {
##  name            = "default-subnet"
##  ip_version      = 4
##  cidr            = "10.0.1.0/24"
##  dns_nameservers = ["8.8.8.8"]
##  network_id      = openstack_networking_network_v2.ran_network.id
##}
##
### Attach the network to the external network
##resource "openstack_networking_router_v2" "ran_network_router" {
##  name                = "ran_network_router"
##  external_network_id = "a2a9e3e7-c94f-4a8d-be15-5a043dbefcc4"
##}
##
##resource "openstack_networking_router_interface_v2" "router_interface_2" {
##  router_id = openstack_networking_router_v2.ran_network_router.id
##  subnet_id = openstack_networking_subnet_v2.ran_network.id
##}
##
### == Launch instances ===============================================================
##resource "openstack_compute_instance_v2" "ran_compute" {
##  count           = var.compute.instance_count
##  name            = "compute-${count.index + 1}"
##  image_name      = var.compute_image
##  flavor_name     = "ds1G"
##  key_pair        = "${openstack_compute_keypair_v2.ssh_key.name}"
##  security_groups = ["firewall"]
##
##  network {
##    name = "${openstack_networking_network_v2.ran_network.name}"
##  }
##}
##
##resource "openstack_compute_instance_v2" "ran_master" {
##  count           = var.master.instance_count
##  name            = "master-${count.index + 1}"
##  image_name      = var.master_image
##  flavor_name     = "ds1G"
##  key_pair        = "${openstack_compute_keypair_v2.ssh_key.name}"
##  security_groups = ["firewall"]
##
##  network {
##    name = "${openstack_networking_network_v2.ran_network.name}"
##  }
##}

