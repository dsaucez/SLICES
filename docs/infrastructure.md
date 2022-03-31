# SophiaNode Network Architecture

## Introduction

The SophiaNode is a testbed that provides the ability to run experiments related
to 5G. It is composed of compute and radio resources interconnected via high
speed links. Resources are all deployed in Sophia Antipolis, France, and are
hosted either by Eurecom or by Inria. Part of the radio resources are hosted
in the R2LAB anechoic chamber [[R2LAB](https://r2lab.inria.fr)].

A particularity of the SophiaNode is that it involves two administratively
disjoined entities - Eurecom and Inria. If some assets are shared by the two
entities, some others are only owned and managed by a single entity.

In previous generations of testbeds, radio and compute resources were the only
resources of interest for the experimenters and the interconnection
infrastructure was then hidden. However, when it comes to 5G, the
interconnection itself (e.g., optical fibre links and switches) plays take place
in the treatment of the workload and they shall be exposed to the testbed users.

In this note, we omit to discuss the compute and radio resources and focus on
the network architecture used to interconnect all components of the SophiaNode.
The peculiarities of the SophiaNode make it a perfect case study to understand
how to inter-connect equipment from both a logical and a physical point of view.

Since every testbed can be different, we do not only present the SophiaNode
architecture but also explore several potential architectures that could have
been used and discuss their advantages and drawbacks.

## Background

The SophiaNode is shared between Eurecom and Inria premises on the Sophia
Antipolis campus. In this context, Eurecom and Inria are two disjoined entities
with their own administration and policies. In the following we call them
_administrative domains_.

The administrative domain of Eurecom is composed of one _compute_ cluster and
one _radio cluster_ and so is the Inria administrative domain. As set of **X** 
optical fibre links is shared between Eurecom and Inria and used to interconnect
the two domains. Except these optical links all other assets fall under only
one administrative domain, either Eurecom or Inria.

Nevertheless, the compute clusters are standardised from a networking point of
view. They are ultimately x86 clusters where compute processes (e.g.,
containers) can be deployed and orchestrated on the fly, for example with docker
[[docker](https://www.docker.com)] and kubernetes
[[k8s](https://kubernetes.io)].

The radio clusters are specialised clusters built according to the specific needs
of the partner. For example, the radio cluster of Inria is integrated in the
R2LAB testbed [[R2LAB](https://r2lab.inria.fr)] to leverage its anechoic
chamber.

The network interconnection is granted by high speed programmable switches. To
ease reproducibility and allow replication of the infrastructure by other
parties, all the programmable switches follow the Facebook's Wedge 100 open
design with 32 100BgE QSFP28 ports [[Wedge100](https://engineering.fb.com/2016/10/18/data-center-engineering/wedge-100-more-open-and-versatile-than-ever/)]
The SophiaNode uses the Edge-Core Wedge100BF-32QS
[[Wedge100BF-32QS](https://www.edge-core.com/productsInfo.php?cls=1&cls2=5&cls3=181&id=770)]
and Wedge100BF-32X [[Wege100BF-32X](https://www.edge-core.com/productsInfo.php?id=335)]
switches that implement this design and that are P4 programmable
[[P4](https://opennetworking.org/p4/)], which allows to easily run custom data
plane implementations.

In this memo we use the term _data port_ to designate network ports that are
used to carry actual experimental data. The interconnection of these ports forms
the _data network_. In a similar manner, we use the term _control port_ to
designate network or serial ports that are used to control the experiment and
the equipment. The interconnection of these ports forms the _control network_.
In other words, the data network carries traffic that would be observed in an
actual deployment while the control network carries all the traffic that is
linked to the fact that the operations are performed in a tested instead of on
an actual environment.

We do not describe the control network in this document as it is very specific
to each production environment. Nevertheless, we strongly recommend to
use a dedicated independent network infrastructure for it. It may be convenient
to provide public internet connectivity to the switches and devices via this
infrastructure.

The devices (e.g., k8s clusters, USRP...) populating the _compute_ and _radio_
clusters are not described here.

> BACKGROUND ON FABRIC AND EVPN TO BE ADDED HERE

## Physical interconnect

### Compute cluster architecture

Even though the exact compute nodes to deploy in the _compute_ clusters are not
standardised, we recommend the following network architecture to build each
cluster.

![_Compute_ cluster](sophia_node-compute_cluster.svg)

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

To support cluster size increase by maximising density, breakout cables shall
be used to connect the server ports to the switch ports.

### Clusters interconnect

In the previous section we defined the standardised network architecture of 
compute clusters. In this section, we present different alternatives to 
interconnect the clusters composing the SophiaNode.

#### Spine-and-leaf option

A trendy and scalable solution is to build the infrastructure following the 
_spine-and-leaf_ model.

With the spine-and-leaf architecture, the _spine_ switches compose the
backbone of the network and the _leaf_ switches connect the devices to the
network. Devices and leaf switches are grouped in _pods_. within our
terminology, a cluster corresponds to a pod and an aggregation switch
corresponds to a leaf switches. Every leaf switch is connected to all the
spine switches as illustrated in the figure below with two compute clusters,
two radio clusters, Internet connectivity, and two spine switches.

![Spine-and-leaf architecture](sophia_node-spine-leaf.svg)

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
carefully provisioned such that the entier traffic generated by a pod can be
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

#### Relaxed spine-and-leaf option

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

![Relaxed _spine-and-leaf_ architecture](sophia_node-relaxed-spine-leaf.svg)

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

#### Partial mesh option

The spine-and-leaf and the relaxed spine-and-leaf options proposed above are
generic and symetrical, which simplifies automation and scaling. These solutions
shine at scale and when availability is a key point. In the following we explore
simpler architectures, such as the _partial mesh_ illustrated bellow.

![Partial mesh](sophia_node-partial-mesh.svg)

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

#### Hub-and-spoke option

In the _hub-and-spoke_ architecture, there is a central point to interconnect
all the clusters and external links as shown in the figure below.

![Hub and spoke](sophia_node-hub-and-poke.svg)

This solution is particularly adapted if one very high performance switch is
available and if there is no requirements in terms of resiliency of the
infrastructure.

The uplink capacity is computed in the same way as for the spine-and-leaf
architecture such that no congestion can occur between clusters of the same
administrative domain.

## Logical interconnect

The above section discusses potential physical interconnection of elements in the network. In this section, we propose a high level discussion on how the interconnection can be implemented. We first consider the situation where legacy network protocols are used to operate the network. We then discuss how SDN could be used to operate the network.

### Legacy protocol approach

### SDN approach
Various definition of Software-Defined Networking (SDN) exist but the most commonly agreed one is that SDN decouples network control and forwarding functions in order to be directly programmable by a (logically) centralized unit called the _controller_.

In this case, all the control logic is operated by one controller that has a global knowledge of the infrastructure. It is worth noting that the controller can be implemented in a distributed manner. For example, the [ONOS](https://opennetworking.org/onos/) controller relies on Apache Kafka to distribute its state over multiple instances and make network wide decision coherently.
