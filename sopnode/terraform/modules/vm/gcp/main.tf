terraform {
  required_version = ">= 0.14.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

# Compute
resource "google_compute_instance" "compute" {
  count        = var.instances.compute.instance_count
  can_ip_forward = true
  name         = "compute-${count.index + 1}"
  machine_type = var.instances.compute.flavor
  zone         = var.instances.compute.zone
  tags         = var.instances.compute.tags
  allow_stopping_for_update = true

  labels = { 
    ansible-group = "compute"
  }

  boot_disk {
    initialize_params {
      size = var.instances.compute.disk_size
      image = var.instances.compute.image
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
    }
  }
}

# Master
resource "google_compute_instance" "master" {
  count        = var.instances.master.instance_count
  can_ip_forward = true
  name         = "master-${count.index + 1}"
  machine_type = var.instances.master.flavor
  zone         = var.instances.master.zone
  tags         = var.instances.master.tags
  allow_stopping_for_update = true

  labels = { 
    ansible-group = "master"
  }

  boot_disk {
    initialize_params {
      size = var.instances.master.disk_size
      image = var.instances.master.image
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
    }
  }
}

# Switch
resource "google_compute_instance" "switch" {
  count        = var.instances.switch.instance_count
  can_ip_forward = true
  name         = "switch-${count.index + 1}"
  machine_type = var.instances.switch.flavor
  zone         = var.instances.switch.zone
  tags         = var.instances.switch.tags
  allow_stopping_for_update = true

  labels = { 
    ansible-group = "switch"
  }

  boot_disk {
    initialize_params {
      size = var.instances.switch.disk_size
      image = var.instances.switch.image
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
    }
  }
}

# OpenVpn
resource "google_compute_instance" "openvpn" {
  count        = var.instances.openvpn.instance_count
  can_ip_forward = true
  name         = "openvpn-${count.index + 1}"
  machine_type = var.instances.openvpn.flavor
  zone         = var.instances.openvpn.zone
  tags         = var.instances.openvpn.tags
  allow_stopping_for_update = true

  labels = { 
    ansible-group = "openvpn"
  }

  boot_disk {
    initialize_params {
      size = var.instances.openvpn.disk_size
      image = var.instances.openvpn.image
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    access_config {
    }
  }
}

output "vms" {
  value = {
    "compute": {
      "hostname":    google_compute_instance.compute.*.name,
      "access_ip":   google_compute_instance.compute[*].network_interface.0.access_config.0.nat_ip,
      "internal_ip": google_compute_instance.compute[*].network_interface.0.network_ip
    },
    "master": {
      "hostname":    google_compute_instance.master.*.name,
      "access_ip":   google_compute_instance.master[*].network_interface.0.access_config.0.nat_ip,
      "internal_ip": google_compute_instance.master[*].network_interface.0.network_ip
    },
    "switch": {
      "hostname":    google_compute_instance.switch.*.name,
      "access_ip":   google_compute_instance.switch[*].network_interface.0.access_config.0.nat_ip,
      "internal_ip": google_compute_instance.switch[*].network_interface.0.network_ip
    }
    "openvpn": {
      "hostname":    google_compute_instance.openvpn.*.name,
      "access_ip":   google_compute_instance.openvpn[*].network_interface.0.access_config.0.nat_ip,
      "internal_ip": google_compute_instance.openvpn[*].network_interface.0.network_ip
    }
  }
}