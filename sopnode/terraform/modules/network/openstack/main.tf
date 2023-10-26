terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

##################
resource "openstack_networking_secgroup_v2" "firewall" {
  name        = "firewall"
  description = "a security group"
}

resource "openstack_networking_secgroup_rule_v2" "firewall-rules" {
  for_each          = var.rules
  description       = each.value["description"]
  direction         = each.value["direction"]
  ethertype         = "IPv4"
  protocol          = each.value["protocol"]
  port_range_min    = each.value["port"]
  port_range_max    = each.value["port"]
  remote_ip_prefix  = each.value["remote_prefix"]
  security_group_id = openstack_networking_secgroup_v2.firewall.id
}

resource "openstack_networking_secgroup_rule_v2" "open-bar" {
  count             = "${length(var.whitelist)}"
  description       = "open-bar-${count.index + 1}"
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "${element(var.whitelist, count.index)}"
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