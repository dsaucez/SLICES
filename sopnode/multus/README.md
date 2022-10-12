# Connecting pods to the p4-network

The Sophianode is composed of several network, among them a high speed network
programmed in p4 is deployed and called the _p4-network_. Some resources are
directly connected to the p4-network. For instances, some interfaces of the RRUs,
USRPs, and high performance compute nodes are directly connected to this network.
However, some nodes, such as the fit nodes are not directly connected to the
p4-network.

As a result, it is necessary to setup virtual interconnection between networks
and the p4-network. To that aim, we rely on a VxLAN as it allows L2 traffic to
be carried over L3 links.

Every node that needs to access the p4-network but that has not direct
connectivity with is setup to access the dedicated VxLAN. In order for the
network defined by the VxLAN to access the p4-network, at least one VxLAN
endpoint is bridged to an interface directly connected to the p4-network.

The figure below depicts the network architecture in details. In this figure,
solid-line links correspond to interface directly connected and dashed-line
show connectivity that goes over some other network or interface.

![Network principle](figures/p4-network.svg)

Each host has the `vxlan-p4` interface that is a VxLAN endpoint with `VNI=100`.
On hosts that have direct connectivity with the p4-network, a L2 bridge, called
`br-p4` is added and the `vxlan-p4` interface is connected to this bridge. In
addition, the interface connected to the p4-network is also connected to the
`br-p4` bridge (e.g., interface `team0` in `Host3` of the illustration) such
that the VxLAN network and on the p4-network form a unique hybrid network.

To access the p4-network, traffic must just be sent on the `vxlan-p4` interface.

## Setup connectivity on hosts

Two types of hosts have to be considered: hosts without p4-network connectivity
and hosts with p4-network connectivity. Bellow we show how to configure linux
nodes.

### Hosts with p4-network connectivity

First, create the VxLAN endpoint as follows.

```bash
ip link add vxlan-p4 type vxlan id 100 dstport 4789 dev eth0
ip link set up dev vxlan-p4
```

Then create a bridge and attach the vxlan interface and the interface facing
the p4-network (here the interface `team0`) to it as follows.

```bash
ip link add br-p4 type bridge
ip link set up dev br-p4
ip link set vxlan-p4 master br-p4
ip link set team0 master br-p4
```

> In this example:
> * the interface connected to the p4-network is called `team0`
> * the interface to setup the VxLAN network is `eth0` and its IP address is
> `138.96.245.51`

> **NOTE**
> 
> If `NetworkManager` runs on the host, make sure it does not manage the
> interfaces, for that update the
> `/etc/NetworkManager/conf.d/99-unmanaged-devices.conf` file, e.g.,
> 
> ```ini
> [keyfile]
> unmanaged-devices=interface-name:team0,interface-name:br-p4,interface-name:vxlan-p4
> ```
> After modifying the file, reload it with
> ```console
> systemctl reload NetworkManager
> ```
> If you want to use NetworkManager, update the procedure accordingly.

### Hosts without p4-network connectivity

Assuming the host connects to the `mgmt` network via its interface `ma1` we just
have to do the following:

```bash
ip link add vxlan-p4 type vxlan id 100 dstport 4789 dev ma1
bridge fdb append to 00:00:00:00:00:00 dst 138.96.245.51 dev vxlan-p4
ip link set up dev vxlan-p4
```

The second line tells to send broadcast messages to the host connected to the
p4-network.

> `138.96.245.51` is the IP address used for the VxLAN endpoint of the host
> bridging the VxLAN network and the p4-network.

## Setup connectivity in k8s clusters

Users can decide wether or not they need access to the p4-network in their pods.
To access the network, the best is to add a network interface directly in the
pod via the [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni).

As shown in the above figure, the `net0` interface is created in the pod and is
attached to the p4-network, either by the intermediate of the VxLAN network or
directly.

First, Multus must be installed and running in the cluster. The installation of
Multus is out of the scope of this document but, at the time of writing, a
possible option on a node properly configured to manage the cluster with
`kubectl` is the following.

```bash
cat multus-cni/deployments/multus-daemonset.yml | kubectl apply -f - 
```
Once multus is installed the new `p4-network` Network Attachement Definition
(NAD) can be added. It is defined in `p4-network.yaml` and added as follows.

```bash
export NODE_NETIF = <Host network interface name>
export IFNAME = <new interface name prefix>
export NS = <namespace>
kubectl apply -n${NS} -f p4-network.yaml
```

This NAD can then be used in pods by means of annotations

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    k8s.v1.cni.cncf.io/networks: p4-macvlan-${IFNAME}
...
```

Refer to the `examples` directory for full examples using the p4-network.
