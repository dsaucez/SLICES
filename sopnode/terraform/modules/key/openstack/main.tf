terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

resource "openstack_compute_keypair_v2" "ssh_key" {
  name       = var.publickey.name
  public_key = var.publickey.key
}