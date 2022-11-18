terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("sophia-node-credentials.json")

  project = "sophia-node"
  region  = "europe-west9"
  zone    = "europe-west9-a"
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west9"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "compute" {
  count        = var.compute.instance_count
  name         = "compute-${count.index + 1}"
  machine_type = "e2-standard-4"
  zone         = "europe-west9-a"
  tags         = ["ssh"]

  labels = { 
    ansible-group = "compute"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
      #image = "fedora-cloud/fedora-cloud-36"
    }
  }

  # Install busybox
  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq busybox"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}



resource "google_compute_instance" "switch" {
  count        = var.switch.instance_count
  name         = "switch-${count.index + 1}"
  machine_type = "e2-standard-4"
  zone         = "europe-west9-a"
  tags         = ["ssh", "switch"]

  labels = { 
    ansible-group = "switch"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  # Install busybox
  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq busybox"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}



resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}



resource "google_compute_firewall" "switch" {
  name    = "switch-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["switch"]
}

resource "google_compute_firewall" "icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.0.1.0/24"]
}

resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "all"
  }
  source_ranges = ["10.0.1.0/24"]
}

 resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tmpl",
    {
     ansible_group_compute = google_compute_instance.compute.*.labels.ansible-group,
     hostname_compute = google_compute_instance.compute.*.name,
     access_ip_compute = google_compute_instance.compute[*].network_interface.0.access_config.0.nat_ip

     ansible_group_switch = google_compute_instance.switch.*.labels.ansible-group,
     hostname_switch = google_compute_instance.switch.*.name,
     access_ip_switch = google_compute_instance.switch[*].network_interface.0.access_config.0.nat_ip
    }
  )
  filename = "inventory"
}