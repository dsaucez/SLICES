terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

# Compute 
resource "openstack_compute_instance_v2" "compute" {
  count           = var.instances.compute.instance_count
  name            = "compute-${count.index + 1}"
  image_name      = var.instances.compute.image
  flavor_name     = var.instances.compute.flavor
  key_pair        = var.instances.compute.publickey_name
  security_groups = var.instances.compute.security_groups

  network {
    name = var.instances.compute.network_name == null ? var.subnetwork : var.instances.compute.network_name
  }
}

# Master 
resource "openstack_compute_instance_v2" "master" {
  count           = var.instances.master.instance_count
  name            = "master-${count.index + 1}"
  image_name      = var.instances.master.image
  flavor_name     = var.instances.master.flavor
  key_pair        = var.instances.master.publickey_name
  security_groups = var.instances.master.security_groups

  network {
    name = var.instances.master.network_name == null ? var.subnetwork : var.instances.master.network_name
  }
}

# Switch 
resource "openstack_compute_instance_v2" "switch" {
  count           = var.instances.switch.instance_count
  name            = "switch-${count.index + 1}"
  image_name      = var.instances.switch.image
  flavor_name     = var.instances.switch.flavor
  key_pair        = var.instances.switch.publickey_name
  security_groups = var.instances.switch.security_groups

  network {
    name = var.instances.switch.network_name == null ? var.subnetwork : var.instances.switch.network_name
  }
}

# OpenVpn 
resource "openstack_compute_instance_v2" "openvpn" {
  count           = var.instances.openvpn.instance_count
  name            = "openvpn-${count.index + 1}"
  image_name      = var.instances.openvpn.image
  flavor_name     = var.instances.openvpn.flavor
  key_pair        = var.instances.openvpn.publickey_name
  security_groups = var.instances.openvpn.security_groups

  network {
    name = var.instances.openvpn.network_name == null ? var.subnetwork : var.instances.openvpn.network_name
  }
}