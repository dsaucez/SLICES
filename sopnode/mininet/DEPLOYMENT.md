
| Host| IP addr       | Hw addr             | Switch port      |
|-----|---------------|---------------------|----------------- |
| h1a | 172.16.1.1/24 | `00:00:00:00:00:1A` | `device:leaf1/2` |
| h1b | 172.16.1.2/24 | `00:00:00:00:00:1B` | `device:leaf1/3` |

Deploy the topology with

```bash
make start-v4
```

## Manipulate the switches with the P4Runtime shell

Connect to mininet shell with

```bash
make mn-cli
```

From mininet shell, execute the following commands to popular ARP tables

```bash
h1a ip neigh add 172.16.1.2 lladdr 00:00:00:00:00:1B dev h1a-eth0
h1b ip neigh add 172.16.1.1 lladdr 00:00:00:00:00:1A dev h1b-eth0
```

Leave mininet shell and build the P4Runtime environment with

```bash
make p4-build
```

then connect to `leaf1` P4Runtime shell with 

```bash
./util/p4rt-sh --grpc-addr localhost:50001 --config p4src/build/p4info.txt,p4src/build/bmv2.json --election-id 0,1
```

and then execute the following commands to populate L2 switching table.

```bash
te = table_entry["IngressPipeImpl.l2_exact_table"](action="IngressPipeImpl.set_egress_port")
te.match["hdr.ethernet.dst_addr"] = ("00:00:00:00:00:1B")
te.action["port_num"] = ("3")
te.insert()

te = table_entry["IngressPipeImpl.l2_exact_table"](action="IngressPipeImpl.set_egress_port")
te.match["hdr.ethernet.dst_addr"] = ("00:00:00:00:00:1A")
te.action["port_num"] = ("2")
te.insert()
```

## Manipulate the switches with ONOS

Connect to ONOS cli with the following command

```bash
make onos-cli
```

The username is `onos` and the password is `rocks`.

In the cli, first activate BMv2 drivers (and optionally host discovery and link discovery) with the command

```bash
app activate drivers.bmv2
app activate hostprovider
app activate lldpprovider
```

 Leave the ONOS cli then build the ONOS app and load it to ONOS with the
 respective following commands.

 ```bash
 make app-build
 make app-reload
 ```


 Compile P4 pipeline with
 ```bash
 make p4-build
 ```

 Test that everything is ok with

 ```bash
 make p4-test
 ```

Network configuration can now be sent to ONOS with the following command.

```bash
make netcfg
```


## Playing with the network

Access the mininet shell with the following command.

```bash
make mn-cli
```

To make `h1a` ping `h1b`, run `h1a ping h12` in mininet cli.

Access ONOS cli with the following command.

```bash
make onos-cli
```

ONOS GUI is reachable via `http://localhost:8181/onos/ui/`.