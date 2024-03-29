# Physical interconnect

## Compute cluster architecture

Even though the exact compute nodes to deploy in the _compute_ clusters are not
standardized, we recommend the following network architecture to build each
cluster.

![_Compute_ cluster](figures/sophia_node-compute_cluster.svg)

The cluster is composed of two _aggregation switches_. The aggregation switches
are equally connected to the backbone. Optionally the two switches can be
directly connected with links used as _peer links_ for multi-chassis link
aggregation. Peers links are only used to manage multi-chassis link aggregation
and shall never carry other type of payload (e.g., compute flows or user control
flows). To ease operations, we strongly recommend the aggregation switches to be
identical (e.g., Edge-Core Wedge100BF-32QS). 

As the aggregation switches are true citizens of the experiments. Therefore,
they must be accessible by the experimenters, typically they should be
programmable. The methods used to allow experimenters to manage the switches is
out of the scope of this document.

Each compute node is equally connected to each aggregation switch. This means
that if a server has _n_ data ports, _n/2_ data ports must be connected to each
switch. Whenever possible, link aggregation must be used to bind these data
links with the two switches and it is strongly recommended to use hardware
assisted solutions to implement the aggregation in order to keep aggregation
performances independent of the compute load on the nodes.

The data network is connected to the backbone via _uplinks_. The uplink capacity
of each aggregation switch must be at least equal to the sum of the capacity of
connection with the compute nodes. In case of _m_ compute nodes with _n_ ports
running at _s_ Gbps, the total uplink capacity must be at least equal to
_m * n/2 * s_ Gbps. Depending on the option selected to build the uplink
interconnect, the total uplink capacity might be much higher than this value.
This capacity guarantees that a compute cluster is always able to receive and
transmit experimental data at its maximum network capacity, i.e., the connection
with the backbone is not a bottleneck.

The compute cluster can be composed of heterogeneous nodes. However,
they must all respect the same interconnection with the switches.

In case of large compute clusters composed of multiple racks, one can use
Top-of-Rack (ToR) or End-of-Row (EoR) switches. In this cases, compute
nodes of the rack would be connected to their ToR or EoR switches instead of
being connected to the two main switches of the cluster. Every ToR (resp. EoR)
is equally connected to each aggregation switch and the capacity between
a ToR (resp. EoR) and an aggregation switch must be at least equal to the
cumulated capacity of the ToR (resp. EoR) with its connected compute nodes. In
a similar way, the uplink of an aggregation switch must be at least equal to
the cumulated capacity the switch has with all the ToR (resp. EoR) switches
connected to it.

To support cluster size increase by maximizing density, breakout cables shall
be used to connect the server ports to the switch ports.

## Clusters interconnect

In the previous section we defined the standardized network architecture of 
compute clusters. In this section, we present different alternatives to 
interconnect the clusters composing the SophiaNode.

### Spine-and-leaf option

A trendy and scalable solution is to build the infrastructure following the 
_spine-and-leaf_ model.

With the spine-and-leaf architecture, the _spine_ switches compose the
backbone of the network and the _leaf_ switches connect the devices to the
network. Devices and leaf switches are grouped in _pods_. within our
terminology, a cluster corresponds to a pod and an aggregation switch
corresponds to a leaf switches. Every leaf switch is connected to all the
spine switches as illustrated in the figure below with two compute clusters,
two radio clusters, Internet connectivity, and two spine switches.

![Spine-and-leaf architecture](figures/sophia_node-spine-leaf.svg)

The spine-and-leaf is particularly suitable for situations with heavy data
traffic between pods. It also offers the advantage that traffic always crosses
the same number of switches to go from one device to another, with the
exception of devices connected to the same leaf. It is then particularly adapted
for situations where latency needs to be predictable.

To simplify operations, all the uplinks of a pod must be identical, e.g., all
links at 100Gbps. There is no direct data connection between spine switches or
between leaf switches. However, direct connection can be setup between the leaf
switches of a pod in order to carry control traffic such as multi-chassis link
aggregation (but no data traffic ever transit on these links).

The uplink capacity, i.e., the _(spine, leaf)_ connections, must be
carefully provisioned such that the entire traffic generated by a pod can be
sent to the backbone without causing congestion.

For example, a compute cluster of _m_ compute nodes with _n_ ports running at
_s_ Gbps must be connected to the backbone with a total uplink capacity at least
equal to _m * n * s_ Gbps. The capacity is spread equally between each
_(spine, leaf)_ pair of a pod.

Several physical links can be bundled to provide enough uplink capacity between
a leaf switch and a spine switch, should one link be insufficient.

In this architecture Internet connectivity is treated as any other pod composed
of the Internet facing routers and all the accounting and security appliances
(e.g., firewall, gateways). It also means that any device from a pod accesses
Internet by going first through a spine switch.

### Relaxed spine-and-leaf option

The clos-topology offered by the spine-and-leaf architecture offers the
advantages presented above but it also comes at the cost of complex operational
management of cabling if pods are deployed in different locations or managed
by different administrative domains, which is the case of the SophiaNodes where
Eurecom and Inria independently manage parts of the pods (i.e., compute and
radio clusters) in their own premises.

In such a situation we suggest to keep the spine-and-leaf architecture only
within the administrative domain (e.g., one for Eurecom and one for Inria)
instead of having one spine-and-leaf network covering two administrative
domains. The joint between the separated administrative domains is shown in the
figure below.

![Relaxed _spine-and-leaf_ architecture](figures/sophia_node-relaxed-spine-leaf.svg)

In this case, each administrative domain builds a spine-and-leaf infrastructure.
For clarity reasons the example above shows only one spine switch per entity,
but nothing prevents the networks to be as large as needed (e.g., 2 spine
switches, 4 pods...).

One pod is selected in each administrative domain to be in charge of
inter-connecting the administrative domain to the other administrative domains.
Each leaf switch of the selected pod of an administrative domain must be
connected to at least one leaf switch of the selected pod of each other
administrative domains. This link is called _peering link_ and its capacity must
be at least equal to the aggregated capacity of the uplink and data links of
the leaf switch. If one link is not sufficient to fulfil that requirements,
multiple links can be used and bound together with link aggregation techniques.

The relaxed spine-and-leaf architecture proposed here is a tradeoff between
speed, delay, and operational simplicity. In terms of operations, the concept of
peering link allows to apply specify policies that can be shared with the other
administrative domains without impairing the local policies. Forcing all the
peering links to be within the same pod and on all leaf switches ensures
predictability of delays as the peering location is the same for all the traffic
and is known in advance. Finally, if all the leaf switches of a pod are equal -
as recommended above - imposing that every leaf switch of the pod used for
peering with the other administrative domains is peering with the other pods at
its maximum capacity ensures that delay and bandwidth is independent of the
selected peering link since no congestion can ever occur while peering
(though congestion may happen while getting to the selected pod of the
administrative domain or when leaving the leaf switches of the selected pod of
the remote administrative domain).

### Partial mesh option

The spine-and-leaf and the relaxed spine-and-leaf options proposed above are
generic and symmetrical, which simplifies automation and scaling. These solutions
shine at scale and when availability is a key point. In the following we explore
simpler architectures, such as the _partial mesh_ illustrated bellow.

![Partial mesh](figures/sophia_node-partial-mesh.svg)

In the partial mesh, clusters are directly connected with every other clusters
of the same administrative domain and connectivity to the outside (e.g., another
administrative domain or the Internet) goes through a dedicated egress switch.

Each local switch of the cluster is connected to one local switch of each other
cluster of the administrative domain via uplink. The uplink capacity is computed
in the same way as for the spine-and-leaf architecture such that no congestion
can occur between clusters of the same administrative domain. For example, a
compute cluster of _m_ compute nodes with _n_ ports running at _s_ Gbps must be
connected to the backbone with a total uplink capacity at least equal to
_m * n * s_ Gbps. The capacity is spread equally over the uplinks of the
cluster. Several physical links can be bundled to provide enough uplink
capacity, should one link be insufficient.

Each local switch of the cluster is connected to the egress switch of the
cluster via an _egress link_. Several physical links can be bundled to provide
enough egress link capacity, should one link be insufficient. The capacity for
the egress link is determined according to the needs.

The egress switch is connected to the egress switch of the other administrative
domain via a link called _peering link_. The capacity of the peering link must
be at least equal to the aggregated capacity of the egress links connected to
it. If one link is not sufficient to fulfil that requirements, multiple links
can be used and bound together with link aggregation techniques.

The partial mesh option is particularly adapted to the situation where
external connectivity is unknown at the time of the design or when it is
expected to have numerous peering links.

### Hub-and-spoke option

In the _hub-and-spoke_ architecture, there is a central point to interconnect
all the clusters and external links as shown in the figure below.

![Hub and spoke](figures/sophia_node-hub-and-poke.svg)

This solution is particularly adapted if one very high performance switch is
available and if there is no requirements in terms of resiliency of the
infrastructure.

The uplink capacity is computed in the same way as for the spine-and-leaf
architecture such that no congestion can occur between clusters of the same
administrative domain.