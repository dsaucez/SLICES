# Logical interconnect

The above section discusses potential physical interconnection of elements in
the network. In this section, we propose a high level discussion on how the
interconnection can be implemented. We first consider the situation where legacy
network protocols are used to operate the network. We then discuss how SDN could
be used to operate the network.

## Legacy protocol approach

## SDN approach
Various definition of Software-Defined Networking (SDN) exist but the most
commonly agreed one is that SDN decouples network control and forwarding
functions in order to be directly programmable by a (logically) centralized unit
called the _controller_.

In this case, all the control logic is operated by one controller that has a
global knowledge of the infrastructure. It is worth noting that the controller
can be implemented in a distributed manner. For example, the
[ONOS](https://opennetworking.org/onos/) controller relies on Apache Kafka to
distribute its state over multiple instances and make network wide decision
coherently.