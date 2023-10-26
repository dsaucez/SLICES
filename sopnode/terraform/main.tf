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

module "ssh" {
    source = "./modules/ssh"
    cloud_provider = var.cloud_provider
    publickey = var.publickey
}

module "network" {
    source = "./modules/network"
    cloud_provider = var.cloud_provider
    whitelist = ["10.0.1.0/24", "172.22.10.0/24", "10.8.0.0/24", "10.0.10.0/24", "10.0.20.0/24"]
    rules = var.rules
}