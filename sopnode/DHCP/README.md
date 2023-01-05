On a machine connected to VLAN 100 and VLAN 200:

Start the DHCP server as a docker container, assuming that the `dhcpd.conf` file is in `/root/dhcpd` directory.

```
docker run --detach --volume /root/dhcpd/:/data --network host --name dhcpd --restart unless-stopped networkboot/dhcpd
```

Inspired from http://www.freekb.net/Article?id=3354
