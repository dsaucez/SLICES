# Sharing a node between two partners


## Control and Data planes

Traffic can be separated in two main planes. The _data plane_ transports actual workload between functions, it is optimized for speed (high bandwidth, low latency...). The _control plane_ ensures that the data plane is setup properly.

As of now, the SophiaNode data plane uses dedicated fibers and high speed ports but not decisions has been taken on how to support control plane traffic.

A first option, shown below, is to keep the control planes of Inria and Eurecom independent. It is up to the user to setup a control plane in each part of the SophiaNode and to ensure that they manage the data plane correctly.

![_Independent](figures/sharing_node/independent.svg)

This situation is similar to having two independent nodes with a dedicated data link between them.

A second option, depicted below, is to establish a VPN between the Eurecom and Inria parts of the SophiaNode. A virtual link is established and the two control planes can be merged to form only one. It involves a third party to provide VPN support (e.g., IT departments or VPN provider). The VPN solution is likely to use Internet links or production networks and then control plan traffic would be multiplexed with other traffic.

![_VPN](figures/sharing_node/vpn.svg)


It is possible to avoid using an uncontrolled infrastructure (i.e., Internet) as shown below. In this case, control plane and data plane traffic are carried over the same dedicate network.

![_Inband](figures/sharing_node/inband.svg)

This gives full control on the traffic and does not involve third parties but the bootstrap is complex. Indeed, the data plane is setup by the control plane and in this scenario the control plane is carried by its own data plane.

Another solution is to dedicate link to interconnect the control planes, as presented below. This dedicated link is connected on both sides to switches that are not part of the dedicated data network. These switches are themselves taking part in the network used to carry control plane traffic.

![_Dedicated](figures/sharing_node/dedicated.svg)


