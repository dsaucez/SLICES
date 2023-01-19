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
#ips = getData(server=server, port=port, api='/api/ipam/ip-addresses/', headers=headers)

aliases = []
for id, interface in interfaces.items():
    ifname = interface['name']
    mac = interface['mac_address']
    deviceid = interface['device']['id']
    name = devices[deviceid]['name']

    if mac is not None:
        aliases.append({'name': name, 'interface': {'ifname': ifname, 'mac': mac.lower() }})

print (yaml.dump(aliases))