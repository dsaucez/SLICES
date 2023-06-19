resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tmpl",
    {
     ansible_group_compute = google_compute_instance.compute.*.labels.ansible-group,
     hostname_compute = google_compute_instance.compute.*.name,
     access_ip_compute = google_compute_instance.compute[*].network_interface.0.access_config.0.nat_ip

     ansible_group_master = google_compute_instance.master.*.labels.ansible-group,
     hostname_master = google_compute_instance.master.*.name,
     access_ip_master = google_compute_instance.master[*].network_interface.0.access_config.0.nat_ip

     ansible_group_switch = google_compute_instance.switch.*.labels.ansible-group,
     hostname_switch = google_compute_instance.switch.*.name,
     access_ip_switch = google_compute_instance.switch[*].network_interface.0.access_config.0.nat_ip

     ansible_group_openvpn = google_compute_instance.openvpn.*.labels.ansible-group,
     hostname_openvpn = google_compute_instance.openvpn.*.name,
     access_ip_openvpn = google_compute_instance.openvpn[*].network_interface.0.access_config.0.nat_ip
    }
  )
  filename = "inventory"
}