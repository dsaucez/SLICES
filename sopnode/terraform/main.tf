terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
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

provider "google" {
  credentials = file("${var.credentials_file}")

  project = "slices-384907"
  region  = "europe-west8"
  zone    = "europe-west8-a"
}

module "key" {
    source = "./modules/key"
    cloud_provider = var.cloud_provider
    publickey = var.publickey
}

module "network" {
    source = "./modules/network"
    cloud_provider = var.cloud_provider
    whitelist = var.whitelist
    rules = var.rules
    network = var.network
}

module "vm" {
    source         = "./modules/vm"
    cloud_provider = var.cloud_provider
    instances      = var.instances
    subnetwork     = module.network.network_id
}

module "routes" {
    source          = "./modules/routes"
    cloud_provider  = var.cloud_provider
    instance_routes = var.instance_routes
    depends_on      = [module.vm.vms]
}

module "ansible" {
    source         = "./modules/ansible"
    cloud_provider = var.cloud_provider
    vms            = module.vm.vms
}