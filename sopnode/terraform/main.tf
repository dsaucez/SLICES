terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("slices-384907-35eaf7521f45.json") #"sophia-node-credentials.json")

  project = "slices-384907"
  region  = "europe-west8"
  zone    = "europe-west8-a"
}

resource "google_compute_network" "default_network" {
  name                    = "slices-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default_network" {
  name          = "default-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west8"
  network       = google_compute_network.default_network.id
}

resource "google_compute_instance" "compute" {
  count        = var.compute.instance_count
  can_ip_forward = true
  name         = "compute-${count.index + 1}"
  machine_type = "e2-standard-4"
  zone         = "europe-west8-a"
  tags         = ["ssh"]

  labels = { 
    ansible-group = "compute"
  }

  boot_disk {
    initialize_params {
      size = 50
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Install busybox
#  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq busybox"

  network_interface {
    subnetwork = google_compute_subnetwork.default_network.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_instance" "master" {
  count        = var.master.instance_count
  can_ip_forward = true
  name         = "master-${count.index + 1}"
  machine_type = "e2-standard-4"
  zone         = "europe-west8-a"
  tags         = ["ssh"]

  labels = { 
    ansible-group = "compute"
  }

  boot_disk {
    initialize_params {
      size = 50
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Install busybox
#  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq busybox"

  network_interface {
    subnetwork = google_compute_subnetwork.default_network.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_instance" "switch" {
  count        = var.switch.instance_count
  name         = "switch-${count.index + 1}"
  machine_type = "e2-standard-4"
  zone         = "europe-west8-a"
  tags         = ["ssh", "switch"]

  labels = { 
    ansible-group = "switch"
  }

  boot_disk {
    initialize_params {
      size = 50
      image = "debian-cloud/debian-10"
    }
  }

  # Install busybox
  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq busybox"

  network_interface {
    subnetwork = google_compute_subnetwork.default_network.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_instance" "openvpn" {
  count        = var.openvpn.instance_count
  name         = "openvpn-${count.index + 1}"
#  name         = "openvpn-1"
  can_ip_forward = true
  machine_type = "e2-standard-2"
  zone         = "europe-west8-a"
  tags         = ["ssh","openvpn"]

  labels = { 
    ansible-group = "openvpn"
  }

  boot_disk {
    initialize_params {
      size = 10
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  # Install busybox
  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq busybox"

  network_interface {
    subnetwork = google_compute_subnetwork.default_network.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}