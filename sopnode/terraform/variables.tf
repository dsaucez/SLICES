variable "switch" {
  type = map
  default = {
      "instance_count" = 0
    }
}

output "switch-ip" {
  value = zipmap(google_compute_instance.switch[*].name, google_compute_instance.switch[*].network_interface.0.access_config.0.nat_ip)
}

variable "compute" {
  type = map
  default = {
      "instance_count" = 3
    }
}

output "compute-ip" {
  value = zipmap(google_compute_instance.compute[*].name, google_compute_instance.compute[*].network_interface.0.access_config.0.nat_ip)
}