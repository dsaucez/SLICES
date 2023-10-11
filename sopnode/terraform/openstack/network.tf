resource "openstack_networking_secgroup_v2" "firewall" {
  name        = "firewall"
  description = "a security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  description       = "allow-ssh"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

resource "openstack_networking_secgroup_rule_v2" "openvpn" {
  description       = "allow-openvpn"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1194
  port_range_max    = 1194
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

resource "openstack_networking_secgroup_rule_v2" "switch" {
  description       = "switch-firewall"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  description       = "allow-icmp"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "10.0.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

resource "openstack_networking_secgroup_rule_v2" "internal" {
  description       = "allow-internal"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "10.0.1.0/24"
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

resource "openstack_networking_secgroup_rule_v2" "open-bar" {
  count             = "${length(var.prefixes)}"
  description       = "open-bar-${count.index + 1}"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "${element(var.prefixes, count.index)}"
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

#resource "openstack_networking_floatingip_v2" "floatip_test_vm" {
#  pool = "public"
#}
#
#resource "openstack_compute_floatingip_associate_v2" "fip_1" {
#  floating_ip = openstack_networking_floatingip_v2.floatip_test_vm.address
#  instance_id = openstack_compute_instance_v2.compute.id
#}
