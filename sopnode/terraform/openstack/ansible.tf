resource "local_file" "ansible_inventory" {
  content = templatefile("templates/inventory.tmpl",
    {
     ansible_group_compute = ["compute"]
     hostname_compute = openstack_compute_instance_v2.compute.*.name,
     access_ip_compute = openstack_compute_instance_v2.compute[*].access_ip_v4
     internal_ip_compute = openstack_compute_instance_v2.compute[*].access_ip_v4

     ansible_group_master = ["master"]
     hostname_master = openstack_compute_instance_v2.master.*.name,
     access_ip_master = openstack_compute_instance_v2.master[*].access_ip_v4
     internal_ip_master = openstack_compute_instance_v2.master[*].access_ip_v4

     ansible_group_switch = ["switch"]
     hostname_switch = openstack_compute_instance_v2.switch.*.name,
     access_ip_switch = openstack_compute_instance_v2.switch[*].access_ip_v4
     internal_ip_switch = openstack_compute_instance_v2.switch[*].access_ip_v4

     ansible_group_openvpn = ["openvpn"]
     hostname_openvpn = openstack_compute_instance_v2.openvpn.*.name,
     access_ip_openvpn = openstack_compute_instance_v2.openvpn[*].access_ip_v4
     internal_ip_openvpn = openstack_compute_instance_v2.openvpn[*].access_ip_v4
    }
  )
  filename = "inventory"
}
