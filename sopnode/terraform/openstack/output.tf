output "master-ip" {
  value = zipmap(openstack_compute_instance_v2.master[*].name, openstack_compute_instance_v2.master[*].access_ip_v4)
}

output "compute-ip" {
  value = zipmap(openstack_compute_instance_v2.compute[*].name, openstack_compute_instance_v2.compute[*].access_ip_v4)
}


output "switch-ip" {
  value = zipmap(openstack_compute_instance_v2.switch[*].name, openstack_compute_instance_v2.switch[*].access_ip_v4)
}

output "openvpn-ip" {
  value = zipmap(openstack_compute_instance_v2.openvpn[*].name, openstack_compute_instance_v2.openvpn[*].access_ip_v4)
}
