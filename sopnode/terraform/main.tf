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
  credentials = file("gcp/slices-384907-35eaf7521f45.json")

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
    whitelist = ["10.0.1.0/24", "172.22.10.0/24", "10.8.0.0/24", "10.0.10.0/24", "10.0.20.0/24"]
    rules = var.rules
    network = var.network
}

module "vm" {
    source         = "./modules/vm"
    cloud_provider = var.cloud_provider
    instances      = var.instances
}