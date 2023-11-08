terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tmpl",
    {
     vms = var.vms
    }
  )
  filename = "inventory"
}