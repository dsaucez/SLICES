terraform {
  required_version = ">= 0.14.0"
}

module "openstack" {
    source = "./openstack"
    count = "${var.cloud_provider == "openstack" ? 1 : 0}"
    instance_routes = var.instance_routes
}

module "gcp" {
    source = "./gcp"
    count = "${var.cloud_provider == "gcp" ? 1 : 0}"
    instance_routes = var.instance_routes
}