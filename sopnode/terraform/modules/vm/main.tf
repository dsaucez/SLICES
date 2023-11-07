terraform {
  required_version = ">= 0.14.0"
}

module "openstack" {
    source         = "./openstack"
    count          = "${var.cloud_provider == "openstack" ? 1 : 0}"
    instances      = var.instances
}

module "gcp" {
    source         = "./gcp"
    count          = "${var.cloud_provider == "gcp" ? 1 : 0}"
    instances      = var.instances
    subnetwork     = var.subnetwork
}