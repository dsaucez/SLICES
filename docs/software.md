# Inria domain
## Initial version

The Inria domain is composed of three whitebox switches. Two Edge-Core
Wedge100BF-32QS
[[Wedge100BF-32QS](https://www.edge-core.com/productsInfo.php?cls=1&cls2=5&cls3=181&id=770)]
switches, called `sw1` and `sw3` and one Wedge100BF-32X
[[Wege100BF-32X](https://www.edge-core.com/productsInfo.php?id=335)], called
`sw2`.

Each switch runs Open Network Linux
[[ONL](https://github.com/opencomputeproject/OpenNetworkLinux)] as their
operating system. On top of which we run Stratum
[[stratum](https://opennetworking.org/stratum/)] that serves as an abstraction
layer to interface physical and logical units. The network is controlled with
the ONOS SDN controller [[ONOS](https://opennetworking.org/onos/)].

The switches are programmable with P4 [[P4](https://opennetworking.org/p4/)] and
we use them to implement 5G User Plane Function (UPF) with SD-FABRIC
[[SD-fabric](https://opennetworking.org/sd-fabric/)].

The switches are grouped together within a kubernetes cluster
[[k8s](https://kubernetes.io)] that also integrates computes nodes.

Software automation and documentation are available in [/sopnode](/sopnode/).