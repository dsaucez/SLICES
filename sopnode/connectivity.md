# Connectivity between nodes at Sopnode

| Node A                                | Node B             | Techno               | Status  | S/N A        | S/N B        | IP A | IP B |
| :-------------------------------------|:-------------------|:---------------------|---------|--------------|--------------|------|------|
| 12 FO mono to EURECOM RG 097-036/1    | sopnode-sw2/01     | 100GB optical        | OK      | N/A          | FIB220516201 |      |      |
| 12 FO mono to EURECOM RG 097-036/2    | sopnode-sw2/02     | 100GB optical        | OK      | N/A          | FIB220516202 |      |      |
| 12 FO mono to EURECOM RG 097-036/3    | sopnode-sw2/03     | 100GB optical        | OK      | N/A          | FIB220516203 |      |      |
| 12 FO mono to EURECOM RG 097-036/4    | sopnode-sw2/04     | 100GB optical        | OK      | N/A          | FIB220516204 |      |      |
| 12 FO mono to EURECOM RG 097-036/5    | sopnode-sw1/05     | 100GB optical        | OK      | N/A          | FIB220516205 |      |      |
| 12 FO mono to EURECOM RG 097-036/6    | sopnode-sw2/06     | 100GB optical        | OK      | N/A          | FIB220516206 |      |      |
|                                       |                    |                      |         |              |              |      |      |
| 24 FO mono to Salle Anechoide BS12/13 | sopnode-sw3/13     | 100GB optical        | DOWN    | N/A          | C1904162937  |      |      |
| 24 FO mono to Salle Anechoide BS12/14 | sopnode-sw1/14     | 100GB optical        | OK      | N/A          | C1904163659  |  N/A | DHCP |
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
|                                       |                    |                      |         |              |              |      |      |
| sopnode-w2/1/1                        | sopnode-sw1/02/1   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/1/2                        | sopnode-sw1/02/2   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/2/1                        | sopnode-sw1/02/3   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
| sopnode-w2/2/2                        | sopnode-sw1/02/4   | 4X25G breakout cable | OK      | ?            | FIB220517219 | DHCP | L2   |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-w3/1/1                        | sopnode-sw1/03/1   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/1/2                        | sopnode-sw1/03/2   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/2/1                        | sopnode-sw1/03/3   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
| sopnode-w3/2/2                        | sopnode-sw1/03/4   | 4X25G breakout cable | OK      | ?            | FIB220517221 | DHCP | L2   |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-l1/1/1                        | sopnode-sw3/01/1   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/1/2                        | sopnode-sw3/01/2   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/2/1                        | sopnode-sw3/01/3   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
| sopnode-l1/2/2                        | sopnode-sw3/01/4   | 4X25G breakout cable | OK      | ?            | FIB220517220 | DHCP | L2   |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-sw1/21                        | sopnode-sw3/21     | 100GB optical        | OK      | FIB220516214 | FIB220516213 |      |      |
| sopnode-sw1/23                        | sopnode-sw3/23     | 100GB optical        | OK      | FIB220516216 | FIB220516215 |      |      |
| sopnode-sw1/29                        | sopnode-sw2/29     | 100GB optical        | OK      | FIB220516218 | FIB220516217 |      |      |
| sopnode-sw1/31                        | sopnode-sw2/31     | 100GB optical        | OK      | FIB220516212 | FIB220516211 |      |      |
|                                       |                    |                      |         |              |              |      |      |
| sopnode-sw3/25                        | sopnode-sw2/25     | 100GB optical        | OK      | FIB220516207 | FIB220516208 |      |      |
| sopnode-sw3/27                        | sopnode-sw2/27     | 100GB optical        | OK      | FIB220516209 | FIB220516210 |      |      |
|                                       |                    |                      |         |              |              |      |      |
| rru-jaguar/0                          | fs.com / 15        | 10GB optical         | OK      |              |              | DHCPfs:192.168.100.49/24 | L2 |
| rru-jaguar/1                          | fs.com / 16        | 10GB optical         | DOWN    |              |              |      |      |
|                                       |                    |                      |         |              |              |      |      |  
| rru-panther/0                         | fs.com / 5         | 10GB optical         | OK      |              |              | DHCPfs:192.168.100.50/24 | L2 |
| rru-panther/1                         | fs.com / 6         | 10GB optical         | DOWN    |              |              |      |       |
|                                       |                    |                      |         |              |              |      |       |  
| USRP-n300/sfp0                        | fs.com / 25        | 10GB optical         | OK      |              |              |      |       |
| USRP-n300/sfp1                        | fs.com / 26        | 10GB optical         | OK      |              |              | 192.168.100.44/24 | L2 |
|                                       |                    |                      |         |              |              |      |       |  
| USRP-n320/sfp0                        | fs.com / 37        | 10GB optical         | OK      |              |              |      |       |
| USRP-n320/sfp1                        | fs.com / 38        | 10GB optical         | OK      |              |              | 192.168.100.46/24 | L2 |


The DHCP network allocates addresses in the pool `{startip: 192.168.100.60/24, endip: 192.168.100.160/24}` from server `192.168.100.217/24` hosted in the cluster.

The `DHCPfs` network statically assigns adresses from witin `{startip: 192.168.100.10/24, endip: 192.168.100.59/24}` from the server hosted on the FS.com switch.
