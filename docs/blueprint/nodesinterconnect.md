# Nodes and sites interconnection

In the general case the Core and the RAN are not deployed on the same network, as shown in the figure below.

<img src="./images/vpn.svg">

The RAN network (i.e., network in green) must have routes to the cluster Dedicated network (i.e., network in blue):
```
172.22.10.0/24 via 10.8.0.1
``` 

The cluster Dedicated network (i.e., network in blue) must have routes to the RAN network (i.e., network in green):
```
10.8.0.0/24 via 172.22.10.1
``` 

That way the traffic tunneled by the gNBs can be sent to the AMF and/or the UPF and the AMF and/or UPF generated traffic can be tunneled to the gNBs.

In most scenarios, direct physical connectivity does not exist between the core and the RAN and a VPN service is required. When possible dedicated solutions should be considered. However, we also provide a software solution based on OpenVPN. It does not aim to be used in production environment.

To deploy a VPN server you have to add it in the Ansible inventory file inventories/blueprint/hosts:
```
all:
  children:
    openvpn:
      hosts:
        192.0.2.4:
          xx-name: openvpn-1
``` 

For obvious security and performances reasons this machine should be isolated (e.g., a VM or a dedicated physical machine), in this example, the machine is the host Gateway from the figure.

Then modify the roles/openvpn/vars/main.yaml file to reflect your needs:
```
openvpn:
  clients:
    - name: client1
      routes:
        - network: 10.0.10.0
          subnet: 255.255.255.0
    - name: client2
      routes:
        - network: 10.0.20.0
          subnet: 255.255.255.0
  server:
    public_ip: 192.0.2.4
    server:
      network: "10.8.0.0"
      subnet: "255.255.255.0"
    routes:
      - network: 172.22.10.0
        subnet: 255.255.255.0
``` 

In this case, the public IP address to access the VPN server is 192.0.2.4. The machine is directly connected to the Dedicated network of IP prefix 172.22.10.0/24. The addresses that the server gives to clients are in the network 10.8.0.0/24 as defined by the openvpn.server.server.network and openvpn.server.server.subnet variables.

We create two clients, client1 and client2. Each of the clients have an network attached to it (10.0.10.0/24 and 10.0.20.0/24, respectively).

To launch the VPN server and generate the configurations, run the following command:
```
ansible-playbook  -i inventories/blueprint/ openvpn.yaml --extra-vars "@params.blueprint.yaml"
``` 

Once done, the OpenVPN server runs on the machine (i.e., Gateway) and client configuration files are created in the home directory of the VPN server in the file clientN/clientN.ovpn where clientN is the name provided in the above configuration file.

On the RAN site, at the machine that must interconnect with the core, install an OpenVPN client and start it with the ovpn file.

As a result, the machine will obtain an IP address in the 10.8.0.0/24 subnet and will be able to reach the 172.22.10.0/24 prefix via the VPN server. Conversely, the core is able to reach the 10.8.0.0/24 address of the RAN machine as well as the prefixes associated to the OpenVPN client used to connect to the VPN service.