terraform {
  required_version = ">= 0.14.0"
}

module "openstack" {
    source = "./openstack"
    count = "${var.cloud_provider == "openstack" ? 1 : 0}"
}