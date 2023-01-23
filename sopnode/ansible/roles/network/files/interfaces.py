import argparse
import requests
import yaml

parser = argparse.ArgumentParser()
parser.add_argument('--server', help='Netbox server', required=True)
parser.add_argument('--port', help='Netbox port', required=True)
parser.add_argument('--token', help='Netbox authentication token', required=True)
args = parser.parse_args()

server = args.server
port = args.port
token = args.token

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

devices = getData(server=server, port=port, api='/api/dcim/devices/', headers=headers)
interfaces = getData(server=server, port=port, api='/api/dcim/interfaces/', headers=headers)
ips = getData(server=server, port=port, api='/api/ipam/ip-addresses/', headers=headers)

for key, ip in ips.items():
    try:
      ifid = ip['assigned_object_id']
      interface = interfaces[ifid]
      addresses = interfaces[ifid].get('x-addresses', [])
      addresses.append(ip['address'])
      interfaces[ifid]['x-addresses'] = addresses
    except:
      pass

aliases = []
for id, interface in interfaces.items():
    ifname = interface['name']
    mac = interface['mac_address']
    deviceid = interface['device']['id']
    name = devices[deviceid]['name']
    addresses = interface.get('x-addresses', [])

    if mac is not None:
        aliases.append({'name': name, 'interface': {'ifname': ifname, 'mac': mac.lower(), 'addresses': addresses }})

print (yaml.dump(aliases))