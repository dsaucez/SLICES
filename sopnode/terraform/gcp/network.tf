resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.default_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "openvpn" {
  name = "allow-openvpn"
  allow {
    ports    = ["1194"]
    protocol = "udp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.default_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["openvpn"]
}

resource "google_compute_firewall" "switch" {
  name    = "switch-firewall"
  network = google_compute_network.default_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["switch"]
}

resource "google_compute_firewall" "icmp" {
  name    = "allow-icmp"
  network = google_compute_network.default_network.id

  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.1.0/24"]
}

resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.default_network.id

  allow {
    protocol = "all"
  }
  source_ranges = ["10.0.1.0/24"]
}

resource "google_compute_firewall" "open-bar" {
  name    = "open-bar"
  network = google_compute_network.default_network.id

  allow {
    protocol = "all"
  }
  source_ranges = ["172.22.10.0/24", "10.8.0.0/24", "10.0.10.0/24", "10.0.20.0/24"]
}

resource "google_compute_route" "vpn-network" {
  count = var.openvpn.instance_count > 0 ? 1:0
  name        = "vpn-network"
  dest_range  = "10.8.0.0/24"
  network     = google_compute_network.default_network.name
  next_hop_instance = "openvpn-1"
}

resource "google_compute_route" "client1-network" {
  count = var.openvpn.instance_count > 0 ? 1:0
  name        = "client1-network"
  dest_range  = "10.0.10.0/24"
  network     = google_compute_network.default_network.name
  next_hop_instance = "openvpn-1"
}

resource "google_compute_route" "client2-network" {
  count = var.openvpn.instance_count > 0 ? 1:0
  name        = "client2-network"
  dest_range  = "10.0.20.0/24"
  network     = google_compute_network.default_network.name
  next_hop_instance = "openvpn-1"
}

resource "google_compute_route" "ran-network" {
  count = var.openvpn.instance_count > 0 ? 1:0
  name        = "ran-network"
  dest_range  = "172.22.10.0/24"
  network     = google_compute_network.default_network.name
  next_hop_instance = "compute-1"
}