> :warning: **THIS FILE IS DEPRECATED. PLEASE REFER TO NETBOX FOR ANY INVENTORY**

# Connectivity between nodes at Sopnode

| Node A                                | Node B             | Techno               | Status  | S/N A        | S/N B        | IP A | IP B |
| :-------------------------------------|:-------------------|:---------------------|---------|--------------|--------------|------|------|
| 12 FO mono to EURECOM RG 097-036/1    | sopnode-sw2/01     | 100G optical         | OK      | N/A          | FIB220516201 |      |      |
| 12 FO mono to EURECOM RG 097-036/2    | sopnode-sw2/02     | 100G optical         | OK      | N/A          | FIB220516202 |      |      |
| 12 FO mono to EURECOM RG 097-036/3    | sopnode-sw2/03     | 100G optical         | OK      | N/A          | FIB220516203 |      |      |
| 12 FO mono to EURECOM RG 097-036/4    | sopnode-sw2/04     | 100G optical         | OK      | N/A          | FIB220516204 |      |      |
| 12 FO mono to EURECOM RG 097-036/5    | sopnode-sw1/05     | 100G optical         | OK      | N/A          | FIB220516205 |      |      |
| 12 FO mono to EURECOM RG 097-036/6    | sopnode-sw2/06     | 100G optical         | OK      | N/A          | FIB220516206 |      |      |
|                                       |                    |                      |         |              |              |      |      |
| 24 FO mono to Salle Anechoide BS12/13 | sopnode-switch-management/56     | 100G optical         | OK    | N/A          | C1904162937  |      |      |
| 24 FO mono to Salle Anechoide BS12/14 | sopnode-sw1/14     | 100G optical         | OK      | N/A          | C1904163659  |  N/A | DHCP |
| 24 FO mono to Salle Anechoide BS12/15 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/16 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/17 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/18 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/19 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/20 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/21 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/22 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/23 | -                  |                      |         | N/A          |              |      |      |
| 24 FO mono to Salle Anechoide BS12/24 | -                  |                      |         | N/A          |              |      |      |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-w1/1/1                        | sopnode-sw1/01/1   | 4X25G breakout cable | OK      | ?            | FIB220517218 | DHCP | L2   |
| sopnode-w1/1/2                        | sopnode-sw1/01/2   | 4X25G breakout cable | OK      | ?            | FIB220517218 | DHCP | L2   |
| sopnode-w1/2/1                        | sopnode-sw1/01/3   | 4X25G breakout cable | OK      | ?            | FIB220517218 | DHCP | L2   |
| sopnode-w1/2/2                        | sopnode-sw1/01/4   | 4X25G breakout cable | OK      | ?            | FIB220517218 | DHCP | L2   |
| sopnode-w1/eth1                       | switch-mgmt/0/49:2 | 4x25G breakout cable | OK      | ?            | ?            | 192.168.200.92/24 | L2 |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-w2/1/1                        | sopnode-sw1/02/1   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/1/2                        | sopnode-sw1/02/2   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/2/1                        | sopnode-sw1/02/3   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/2/2                        | sopnode-sw1/02/4   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/eth1                       | switch-mgmt/0/49:3 | 4x25G breakout cable | OK      | ?            | ?            | 192.168.200.93/24 | L2 |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-w3/1/1                        | sopnode-sw1/03/1   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/1/2                        | sopnode-sw1/03/2   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/2/1                        | sopnode-sw1/03/3   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/2/2                        | sopnode-sw1/03/4   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/eth1                       | switch-mgmt/0/49:4 | 4x25G breakout cable | OK      | ?            | ?            | 192.168.200.94/24 | L2 |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-l1/1/1                        | sopnode-sw3/01/1   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/1/2                        | sopnode-sw3/01/2   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/2/1                        | sopnode-sw3/01/3   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/2/2                        | sopnode-sw3/01/4   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/eth1                       | switch-mgmt/0/49:1 | 10G copper           | OK      | ?            | ?            | 192.168.200.91/24 | L2 |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-z1/3                          | sopnode-sw3/02/1   | 4X10G breakout cable | OK      | ?            |              | DHCP | L2   |
| sopnode-z1/4                          | sopnode-sw3/02/2   | 4X10G breakout cable | OK      | ?            |              | DHCP | L2   |
| sopnode-z1/6                          | sopnode-sw3/02/3   | 4X10G breakout cable | OK      | ?            |              | DHCP | L2   |
| sopnode-z1/7                          | sopnode-sw3/02/4   | 4X10G breakout cable | OK      | ?            |              | DHCP | L2   |
| sopnode-z1/eth1                       | switch-mgmt/0/1    | 10G copper           | OK      | ?            | ?            | 192.168.200.95/24 | L2 |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-sw1/21                        | sopnode-sw3/21     | 100G optical         | OK      | FIB220516214 | FIB220516213 |      |      |
| sopnode-sw1/23                        | sopnode-sw3/23     | 100G optical         | OK      | FIB220516216 | FIB220516215 |      |      |
| sopnode-sw1/29                        | sopnode-sw2/29     | 100G optical         | OK      | FIB220516218 | FIB220516217 |      |      |
| sopnode-sw1/31                        | sopnode-sw2/31     | 100G optical         | OK      | FIB220516212 | FIB220516211 |      |      |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-sw3/25                        | sopnode-sw2/25     | 100G optical         | OK      | FIB220516207 | FIB220516208 |      |      |
| sopnode-sw3/27                        | sopnode-sw2/27     | 100G optical         | OK      | FIB220516209 | FIB220516210 |      |      |
|                                       |                    |                      |         |              |              |      |      |
| rru-panther/eth1                      | switch-radio/5     | 10G optical          | DOWN    |              |              | STATICfs:192.168.100.50/24 | L2 
| rru-panther/eth2                      | switch-radio/6     | 10G optical          | OK      |              |              | STATICfs:192.168.100.51/24 | L2                                       |                                       |                    |                      |         |              |              |      |       |  
| rru-jaguar/eth1                       | switch-radio/15    | 10G optical          | OK      |              |              | STATICfs:192.168.100.48/24 | L2 
| rru-jaguar/eth2                       | switch-radio/16    | 10G optical          | DOWN    |              |              |      |      |
|                                       |                    |                      |         |              |              |      |      |  
| USRP-n300/sfp0                        | switch-radio/25    | 10G optical          | OK      |              |              | STATICfs:192.168.10.129/26 | L2 
| USRP-n300/sfp1                        | switch-radio/26    | 10G optical          | OK      |              |              | STATICfs:192.168.20.129/26 | L2
|                                       |                    |                      |         |              |              |      |       |  
| USRP-n320/sfp0                        | switch-radio/37    | 10G optical          | OK      |              |              | STATICfs:192.168.10.130/26 | L2
| USRP-n320/sfp1                        | switch-radio/38    | 10G optical          | OK      |              |              | STATICfs:192.168.20.130/26 | L2
|                                       |                    |                      |         |              |              |      |       |  
| external-laptop                       | switch-radio/43    | 10G copper           | OK      |              | G2220106023  | DHCPfs | L2
|                                       |                    |                      |         |              |              |      |       |  
| switch-radio/vlan/100                 | N/A                | N/A                  | OK      | N/A          | N/A          | STATIC:192.168.100.150/24 | N/A
| switch-radio/vlan/100/secondary0      | N/A                | N/A                  | OK      | N/A          | N/A          | STATIC:192.168.10.190/26 | N/A
| switch-radio/vlan/100/secondary1      | N/A                | N/A                  | OK      | N/A          | N/A          | STATIC:192.168.20.190/26 | N/A

The DHCP network allocates addresses in the pool `{startip: 192.168.100.60/24, endip: 192.168.100.160/24}` from server `192.168.100.217/24` hosted in the cluster.

The `DHCPfs` network assigns addresses from witin `{startip: 192.168.100.10/24, endip: 192.168.100.58/24}` from the server hosted on the FS.com switch. 

The `STATICfs` network assigns addresses on a per MAC basis.

Multus networks assigns addresses from within `{startip: 192.168.100.162/24, endip: 192.168.100.192/24}`
