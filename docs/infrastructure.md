# SophiaNode Network Architecture

The SophiaNode is composed of 4 clusters:
 * 2 _compute_ clusters and
 * 2 _radio_ clusters.

1 cluster of each type is deployed in Inria premises and 1 cluster of each type
is deployed in Eurecom premises.

The compute clusters are standardized from a networking point of view. They are
x86 clusters where containers can be deployed and orchestrated, for example with
docker [[docker](https://www.docker.com)] and kubernetes
[[k8s](https://kubernetes.io)].

The radio clusters are specialized clusters built according to the specifc needs
of the partner. For example, the radio cluster of Inria is the so-called R2LAB
[[R2LAB](https://r2lab.inria.fr)]. 

This document describes the standardized architecture of _compute_ clusters and
proposes options to interconnect _compute_ and _radio_ clusters from separate in
the complex scenario of administratively separated premises.

## Components

The SophiaNode is composed of 3 types of switches, used to interconnect the
various components constituting the infrastructure.

We retained Wedge100BF-32QS [[Wedge100BF-32QS](https://www.edge-core.com/productsInfo.php?cls=1&cls2=5&cls3=181&id=770)],
Wedge100BF-32X [[Wege100BF-32X](https://www.edge-core.com/productsInfo.php?id=335)],
and N5860-48SC [[FSN5860-48SC](https://www.fs.com/de-en/products/110478.html)]
switches.

The Wedge100BF switches offer 32 100BgE QSFP28 ports. The N5860-48SC offers 8
100BgE QSFP28 ports for uplinks and 48 10G SFP+ ports for the edge.

The devices (e.g., k8s clusters, USRP...) populating the _compute_ clusters and
the _radio_ clusters are not described here.

Even though we show the management network in all our architecture porposals,
we do not describe it in this document as it is specific to each production
environement. Nevertheless, we strongly recommend to use a dedicated
independent network infrastructure for the management. It may be convininent to
provide public internet connectivity to the switches and devices via the
management infrastructure.


## _Compute_ cluster architecture

Even though the excat compute nodes to deploy in the _compute_ clusters are not
standardized, we recommand the following network architecure to build each
cluster.

![_Compute_ cluster](sophia_node-compute_cluster.svg)

The cluster is composed of two identical data switches that are equally
connected to the backbone. Optionally the two switches can be directly connected
with links used as peer links for multi-chassis link aggregation. These links
are only used for control data between chassis and shall never carry compute
payload.

Each compute node is equally connected to each switch. This means that if a
server has _n_ data ports, _n/2_ data ports must be connected to each switch.
Whenever possible, link aggregation must be used to bind compute node links
with the two switches.

The uplink capacity of each switch must be at least equal to the sum of the
capacity of connection with the compute nodes. In case of _m_ compute nodes with
_n/2_ ports running at _s_ Gbps, the total uplink capacity must be at least
equal to _m * n/2 * s_ Gbps. Depending on the option selected to interconnect
the switches, the total uplink capacity might be much higher than this value.

Switches are operated in an active-active mode, so are the links, i.e., no link
or switch is used as spare or backup.

To support cluster size increase by maximizing density, breakout cables shall
be used to connect the server ports to the switch ports.

The compute cluster can be composed of heterogeneous nodes. However,
they must all respect the same interconnection with the switches.

## Clusters interconnect

### _Spine-and-leaf_ option

A trendy and scalable solution is to build the infrastructure following the 
_spine-and-leaf_ model.

With the _spine-and-leaf_ architecture, the _spine_ switches compose the
backbone of the network and the _leaf_ switches connect the devices to the
network. Devices and _leaf_ siwtches are grouped in _pods_. In our terminology,
a cluster corresponds to a pod. Every _leaf_ switch is connected to all the
_spine_ switches as illustrated by the figure below with two compute clusters,
two radio clusters, Internet connectivity, and two spine switches.

![Spine-and-leaf architecture](sophia_node-spine-leaf.svg)

The _spine-and-leaf_ is particularly suitable for situations with heavy data
traffic between the devices. It offers that advantage that traffic always
crosses  the same number of switches to go from one device to another, with the
exception of devices connected to the same leaf. It is then particularly adapted
for situations where latency needs to be predictable.

In this architecture, every _leaf_ switch is connected to every _spine_ switch.
To simplify operations, all the uplinks of a pod must be identical, e.g., all
links at 100Gbps. There is no direct connection between _spine_ switches.

The uplink capacity, i.e., the (_spine_, _leaf_) connections, must be
carefully provisionned such that the entirer traffic generated by a pod can be
sent the backbone without causing congestion.

For example, a compute cluster of _m_ compute nodes with _n_ ports running at
_s_ Ggps must be connected to the backbone with a total uplink capacity at least
equal to _m * n * s_ Gbps. The capacity is spread equally between each
(_spine_,_leaf_) pair of a pod.

Physical links can be bundled to provide enough uplink capacity between a _leaf_
switch and a _spine_ switch.

In this architecture Internet connectivity is treated as any other pod composed
of the Internet facing routers and all the accounting and security appliances
(e.g., firewall, gateways). It also means that any device from a pod access
Internet by going first through a _spine_ switch.

### Relaxed _spine-and-leaf_ option

The clos-topology offered by the _spine-and-leaf_ architecture offers the
advantages presented above but it also comes at the cost of complex operational
management of cabling if pods are deployed in different locations or managed
by different administrative entities, which is the case of the SophiaNodes where
Eurecom and Inria independently manage parts of the pods
(i.e., compute and radio clusters) in their own premises.

In such a situation we suggest to keep the _spine-and-leaf_ architecture only
within one administrative entity (e.g., one for Eurecom and one for Inria) and
interconnect the two entities via only one pod, as shown bellow.

![Relaxed _spine-and-leaf_ architecture](sophia_node-relaxed-spine-leaf.svg)

In this case, each entity composing the SophiaNode builds a _spine-and-leaf_
infrastructure.  The example above shows only one _spine_ switch per entity, but
it does not preclude the use of more than one such switch if needed.

One pod is selected in each entity to be in charge of inter-connecting the
entities of the SophiaNode. Each _leaf_ switch of the former pod is conncted
to one _leaf_ switch of the latter pod.

### _Partial mesh_ option

The _spine-and-leaf_ and the relaxed _spine-and-leaf_ options proposed above
offer the advantage of being generic and symetrical, which simplifies
automation and scaling. However, one may argue that these architecture really
become usefeull at scale and they were right, particularly since the SophiaNode
does not need to provide high availability guarantees.

Another solution is to use a partial mesh as shown below.

![Partial mesh](sophia_node-partial-mesh.svg)

In the _partial mesh_, clusters are directly connected with every other cluster
of the same administrative entity and connectivty to the outside (e.g., another
entity or the Internet) goes through a dedicated egress siwtch.

Each switch of the cluster is connected to the egress switch and to one switch
of each other cluster of the administrative entity via uplink.

The uplink capacity is computed in the same way as for the _spine-and-leaf_
architecture in order that no congestion can occur between clusters of the same
entity. The capacity for the egress link is determined according to the needs.

The _partial mesh_ option is particularly adapted to the situation where
external connectivity is unknown at the time of the design or when it is
expected to have numerous peering links.

### _Hub-and-spoke_ option

In the _hub-and-spoke_ architecture, there is a central point to interconnects
all the clusters and external links as shown in the figure below.

![Hub and spoke](sophia_node-hub-and-poke.svg)

This solution is particularly adapted if one very high performance switch is
available and if there is no requirements in terms of resiliency of the
infrastructure.

The uplink capacity is computed in the same way as for the _spine-and-leaf_ 
architecture in order that no congestion can occur between clusters of the same
entity.