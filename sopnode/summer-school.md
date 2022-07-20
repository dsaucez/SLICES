# SophiaNode hand-on

## Objectives

Our objective with this lab is to understand the different steps needed to
operate an automated testebds such as SophiaNode. For the example, we will
deploy a network of P4 programmable switches operating
[SD-Fabric](https://opennetworking.org/sd-fabric/) and managed by
[ONOS](https://opennetworking.org/onos/).

Instead of working with

## SophiaNode background

The SophiaNode is a testbed that provides the ability to run experiments related
to 5G. It is composed of compute and radio resources interconnected via high
speed links. Resources are all deployed in Sophia Antipolis, France, and are
hosted either by Eurecom or by Inria. Part of the radio resources are hosted
in the R2LAB anechoic chamber [[R2LAB](https://r2lab.inria.fr)].

A particularity of the SophiaNode is that it involves two administratively
disjoined entities - Eurecom and Inria. If some assets are shared by the two
entities, some others are only owned and managed by a single entity.

The SophiaNode is shared between Eurecom and Inria premises on the SophiaTech
Campus. Since 2012, the SophiaTech campus gather together the main academic
actors of Sophia Antipolis (i.e., Université Côte d'Azur, EURECOM, Inria, CNRS,
and INRA) and startups. Putting together more than  3,500 people, among which
2,500 students.

Eurecom and Inria are two disjoined entities with their own administration and
policies. In the following we call them _administrative domains_.

The administrative domain of Eurecom is composed of _compute_ and
_radio_ clusters and so is the Inria administrative domain. As set of 6 
optical fibre links is shared between Eurecom and Inria and used to interconnect
the two domains. Except these optical links all other assets fall under only
one administrative domain, either Eurecom or Inria. However, pieces of equipment
are often lent between the two.

Nevertheless, the compute clusters are standardized from a networking point of
view. They are ultimately x86 clusters where compute processes (e.g.,
containers) can be deployed and orchestrated on the fly, for example with docker
[[docker](https://www.docker.com)] or crio-o [[cri-o](https://cri-o.io/)] and
kubernetes [[k8s](https://kubernetes.io)] or OpenShift
[[Open-Shift](https://www.redhat.com/en/technologies/cloud-computing/openshift)].

The radio clusters are specialized clusters built according to the specific
needs of the partner. For example, the radio cluster of Inria is integrated in
the R2LAB testbed [[R2LAB](https://r2lab.inria.fr)] to leverage its anechoic
chamber.

The network interconnection is granted by high speed programmable switches. To
ease reproducibility and allow replication of the infrastructure by other
parties, all the programmable switches follow the Facebook's Wedge 100 open
design with 32 100Gbps QSFP28 ports [[Wedge100](https://engineering.fb.com/2016/10/18/data-center-engineering/wedge-100-more-open-and-versatile-than-ever/)]
The SophiaNode uses Edge-Core Wedge100BF-32QS
[[Wedge100BF-32QS](https://www.edge-core.com/productsInfo.php?cls=1&cls2=5&cls3=181&id=770)]
and Wedge100BF-32X [[Wege100BF-32X](https://www.edge-core.com/productsInfo.php?id=335)]
switches that implement this design and that are P4 programmable
[[P4](https://opennetworking.org/p4/)], which allows to easily run custom data
plane implementations.

