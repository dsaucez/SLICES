terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

## Network
# Create the network
resource "openstack_networking_network_v2" "default_network" {
  name           = var.network.name
  admin_state_up = "true"
}

# Create the subnet
resource "openstack_networking_subnet_v2" "default_network" {
  name            = var.network.subnet_name
  ip_version      = 4
  cidr            = var.network.subnet
  dns_nameservers = var.network.nameservers
  network_id      = openstack_networking_network_v2.default_network.id
}

# Attach the network to the external network
resource "openstack_networking_router_v2" "default_network_router" {
  name                = "default_network_router"
  external_network_id = var.network.external_network_id
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = openstack_networking_router_v2.default_network_router.id
  subnet_id = openstack_networking_subnet_v2.default_network.id
}

## Firewall
# Create a security group
resource "openstack_networking_secgroup_v2" "firewall" {
  name        = "firewall"
  description = "a security group"
}

# Firewall rules
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

# Whitelist
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

output "network_id" {
  value = openstack_networking_network_v2.default_network.name
}