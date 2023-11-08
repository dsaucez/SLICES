terraform {
  required_version = ">= 0.14.0"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tmpl",
    {
     vms = var.vms
    }
  )
  filename = "inventory"
}