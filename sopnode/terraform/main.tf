terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "secret"
  auth_url    = "http://172.16.36.136/identity"
  region      = "RegionOne"
}

module "generic" {
    source = "./modules/ssh"
    cloud_provider = var.cloud_provider
    publickey = var.publickey
}

module "network" {
    source = "./modules/network"
    cloud_provider = var.cloud_provider
}