terraform {
  required_version = ">= 0.14.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

resource "google_compute_route" "instance-routes" {
  for_each    = { for u in var.instance_routes : u.name => u }
  name        = each.value.name
  dest_range  = each.value.destination_prefix
  network     = each.value.network_name
  next_hop_instance = each.value.next_hop_instance
}