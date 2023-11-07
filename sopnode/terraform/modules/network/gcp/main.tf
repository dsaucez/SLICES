terraform {
  required_version = ">= 0.14.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

## Network
# Create the network
resource "google_compute_network" "default_network" {
  name                    = "slices-network"
  auto_create_subnetworks = false
}

# Create the subnet
resource "google_compute_subnetwork" "default_network" {
  name          = "default-subnet"
  ip_cidr_range = var.network.subnet
  region        = "europe-west8"
  network       = google_compute_network.default_network.id
}

## Firewall
# Firewall rules
### TODO: find a cleaner way to skip port number while ICMP
resource "google_compute_firewall" "firewall-rules" {
  for_each  = {for k, rule in var.rules : k => rule if rule.protocol != "icmp" }

  name = each.value["description"]

  allow {
    ports    = [each.value.port]
    protocol = each.value.protocol
  }

  direction     = upper(each.value.direction)
  network       = google_compute_network.default_network.id
  priority      = 1000
  source_ranges = [each.value.remote_prefix]
#  target_tags   = each.value.tags
}

resource "google_compute_firewall" "firewall-rules-icmp" {
  for_each  = {for k, rule in var.rules : k => rule if rule.protocol == "icmp" }

  name = each.value.description

  allow {
    protocol = each.value.protocol
  }

  direction     = upper(each.value.direction)
  network       = google_compute_network.default_network.id
  priority      = 1000
  source_ranges = [each.value.remote_prefix]
#  target_tags   = each.value.tags
}

# Whitelist
resource "google_compute_firewall" "open-bar" {
  name          = "open-bar"

  allow {
    protocol    = "all"
  }
  network       = google_compute_network.default_network.id
  source_ranges = var.whitelist
}

output "network_id" {
  value = google_compute_subnetwork.default_network.id
}