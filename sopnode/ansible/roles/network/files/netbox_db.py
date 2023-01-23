import argparse
import requests
import yaml
from ipaddress import ip_network
from ipaddress import ip_address
import re

# parse user parameters
parser = argparse.ArgumentParser()
parser.add_argument('--server', help='Netbox server', required=True)
parser.add_argument('--port', help='Netbox port', required=True)
parser.add_argument('--token', help='Netbox authentication token', required=True)
args = parser.parse_args()

server = args.server
port = args.port
token = args.token

# Interact with Netbox API 
payload={}
headers = {
  'Accept': 'application/json',
  'Authorization': 'Token {}'.format(token),
}

def getData(server, port, api, headers={}, payload={}):
    url = 'http://{}:{}/{}'.format(server, port, api)

    response = requests.request("GET", url, headers=headers, data=payload)
    data = response.json()
    values = {value["id"]: value for value in data['results']}

    return values

# Load information on devices
devices = getData(server=server, port=port, api='/api/dcim/devices/', headers=headers)
# Load information on interfaces
interfaces = getData(server=server, port=port, api='/api/dcim/interfaces/', headers=headers)
# Load information on IP addresses
ips = getData(server=server, port=port, api='/api/ipam/ip-addresses/', headers=headers)

# Link IP addresses to interfaces
for key, ip in ips.items():
    try:
      ifid = ip['assigned_object_id']
      interface = interfaces[ifid]
      addresses = interfaces[ifid].get('x-addresses', [])
      addresses.append(ip['address'])
      interfaces[ifid]['x-addresses'] = addresses
    except:
      pass

# Give the interfaces, their MAC address, and their addresses to each device
aliases = []
for id, interface in interfaces.items():
    ifname = interface['name']
    mac = interface['mac_address']
    deviceid = interface['device']['id']
    name = devices[deviceid]['name']
    addresses = interface.get('x-addresses', [])

    if mac is not None:
        aliases.append({'name': name, 'interface': {'ifname': ifname, 'mac': mac.lower(), 'addresses': addresses }})

# Load information on IP ranges
ip_ranges = getData(server=server, port=port, api='/api/ipam/ip-ranges/', headers=headers)
# Load information on IP prefixes
prefixes = getData(server=server, port=port, api='/api/ipam/prefixes/', headers=headers)

# Determine all the IP prefixes and their IP range
dhcp_prefixes = []
for prefix in prefixes.values():
  net = ip_network(prefix['prefix'])
  for ip_range in ip_ranges.values():
    start = ip_network(ip_range['start_address'], strict=False)
    end =   ip_network(ip_range['end_address'], strict=False)

    if start == end == net:
      s = re.sub('\/\d+', '', ip_range['start_address'])
      e = re.sub('\/\d+', '', ip_range['end_address'])

      ranges = prefix.get('ranges', [])
      ranges.append({'start_address': s, 'end_address':e})
      prefix['ranges'] = ranges
  dhcp_prefixes.append(prefix)

db = {
  'interfaces': aliases,
  'prefixes': dhcp_prefixes
  }

# Dump the database in YAML
print(yaml.dump(db))