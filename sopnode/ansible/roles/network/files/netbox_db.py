import argparse
import yaml
#from ipaddress import ip_network
from netbox import netbox

def parseParameters():
  """
  Parse user parameters

  :returns: tuple. (str Netbox server name, port: int Netbox port, str Authentication token to connect to Netbox API)
  """
  parser = argparse.ArgumentParser()
  parser.add_argument('--server', help='Netbox server', required=True)
  parser.add_argument('--port', help='Netbox port', required=True)
  parser.add_argument('--token', help='Netbox authentication token', required=True)
  args = parser.parse_args()

  server = args.server
  port = args.port
  token = args.token

  return server, port, token

if __name__ == "__main__":
  server, port, token = parseParameters()

  db = netbox.get_netbox_db(netbox = {'server': server, 'port': port, 'token': token})

  # Dump the database in YAML
  print(yaml.dump(db))