output "master-ip" {
  value = zipmap(google_compute_instance.master[*].name, google_compute_instance.master[*].network_interface.0.access_config.0.nat_ip)
}

output "compute-ip" {
  value = zipmap(google_compute_instance.compute[*].name, google_compute_instance.compute[*].network_interface.0.access_config.0.nat_ip)
}


output "switch-ip" {
  value = zipmap(google_compute_instance.switch[*].name, google_compute_instance.switch[*].network_interface.0.access_config.0.nat_ip)
}

output "openvpn-ip" {
  value = zipmap(google_compute_instance.openvpn[*].name, google_compute_instance.openvpn[*].network_interface.0.access_config.0.nat_ip)
}