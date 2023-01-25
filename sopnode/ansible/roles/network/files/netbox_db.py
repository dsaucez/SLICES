import argparse
import yaml
from ipaddress import ip_network
import re
import pynetbox

# parse user parameters
parser = argparse.ArgumentParser()
parser.add_argument('--server', help='Netbox server', required=True)
parser.add_argument('--port', help='Netbox port', required=True)
parser.add_argument('--token', help='Netbox authentication token', required=True)
args = parser.parse_args()

server = args.server
port = args.port
token = args.token

nb = pynetbox.api('http://{}:{}'.format(server, port), token=token)

# Get all interfaces
interfaces = {}
for interface in nb.dcim.interfaces.all():
  mac = interface.mac_address
  interfaces.setdefault(interface.id, {'id': interface.id, 'ifname': interface.name, 'mac': mac.lower() if mac is not None else mac, 'ip_addresses': []})

# Link IP addresses to interfaces
for ip in nb.ipam.ip_addresses.all():
  ifid = ip.assigned_object_id
  if ifid is not None:
    interface = nb.dcim.interfaces.get(ifid)
    iface = interfaces[interface.id]
    iface['ip_addresses'].append(ip.address)

# Link interfaces to devices
devices = {}
for interface in nb.dcim.interfaces.all():
  deviceid = interface.device.id
  device = nb.dcim.devices.get(deviceid)
  device_db = devices.setdefault(deviceid, {'id': deviceid, 'name': device.name, 'interfaces': []})
  interface_db = interfaces[interface.id]
  interface_db['device_name'] = interface.device.name

  device_db['interfaces'].append(interface_db)

# Determine all the IP prefixes and their IP range
dhcp_prefixes = []

for prefix in nb.ipam.prefixes.all():
  prefix_db = {
                'prefix': prefix.prefix,
                'is_pool': prefix.is_pool,
                'ranges': []
              }
  net = ip_network(prefix.prefix)

  for ip_range in nb.ipam.ip_ranges.all():
    start = ip_network(ip_range.start_address, strict=False)
    end =   ip_network(ip_range.end_address, strict=False)

    if start == end == net:
      s = re.sub('\/\d+', '', ip_range.start_address)
      e = re.sub('\/\d+', '', ip_range.end_address)
      prefix_db['ranges'].append({'start_address': s, 'end_address':e})

  dhcp_prefixes.append(prefix_db)

db = {
  'prefixes': dhcp_prefixes,
  'devices': { device['name']: device for device in devices.values()}
  }

# Dump the database in YAML
print(yaml.dump(db))