
## Setup automation environment

We use Ansible to deploy the different services on the SophiaNode
infrastructure. The playbooks require Ansible 2.5 or higher (we tested then on
`Ansible 2.9.6` and `Ansible 2.12.7`). The present section presents instructions
on how to setup the environment on GNU/Linux Ubuntu 20.04.

To interact with the infrastructure rely on `ansible.posix`,
`community.kubernetes`, `cloud.common`, `kubernetes.core`, `community.crypto`,
`community.general`, and  `community.docker` collection that can be installed
with `ansible-galaxy`:

```bash
ansible-galaxy collection install ansible.posix community.kubernetes cloud.common kubernetes.core community.crypto community.general community.docker
```

To allow non-interactive ssh password authentication we rely on `sshpass` that
can be installed as follows.

```
sudo apt install sshpass
```

## Deploy the services on SophiaNode

Ansible uses inventories to determine on which hosts to execute its tasks. Our
inventories are provided in the `inventories` directory.

The inventories are composed of the following groups:

* `controllers`: group all the hosts that will run the SDN controller.
* `fabric_switches`: group all the switches managed by the k8s cluster.
* `masters`: group all the hosts that will play the role of k8s master.
* `switches`: group all the hosts that will run stratum.

These groups are defined in the `hosts` file of your inventory and extra
connection parameters such as usernames or passwords are defined in the
`group_vars`. More details on how to build Ansible inventories at
[https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

We provide two inventories:
* `sopnode_emu`: example inventory for the SophiaNode emulator
[https://github.com/sopnode/](https://github.com/sopnode/)sopnode_emu/.
* `sopnode_tofino`: inventory for the SophiaNode physical infrastructure.

A file `params.<inventory_name>.yaml` is used to specify the service parameters
to use for the deployment, where `<inventory_name>` corresponds to the name of
the inventory, e.g., `params.sopnode_tofino.yaml` for the
`sopnode_tofino` inventory. Parameters are described below when
needed.

Our deployment is composed of the following 5 services, each one being defined
in its own playbook and relying on roles defined in the `roles` directory.

* __k8s-master__: setting up the k8s cluster.
* __k8s-node__: add nodes to the cluster.
* __fabric-switch__: setup the switches in the k8s cluster.
* __stratum__: deploy stratum on the switches.
* __onos__: deploy ONOS SDN controller.

To run properly, the order above must be respected when deploying the services.
Except _stratum_ and _onos_ that can be interchanged.

For the sake of simplicity, all the commands below are given for the
`sopnode_emu` inventory but they could be apply to any other inventory.

The `registry` service is also provided but is not described in this document.
It provides a docker registry service with authentication for the k8s cluster.

### k8s-master

_k8s-master_ is defined in the `k8s-master.yaml` playbook. Its role is to create
a kubernetes cluster managed by the hosts of the `masters` group. As of today
only one master node is allowed.

It installs k8s on the master node and create a new cluster with the [Calico
cni](https://projectcalico.docs.tigera.io/about/about-calico).

For authentication and security purposes a certificate of authority is created
and deployed in the newly created cluster.

Run the playbook with the following command.

```bash
ansible-playbook  -i inventories/sopnode_emu/ k8s-master.yaml --extra-vars "@params.sopnode_emu.yaml"
```

The following parameters can be used:

```yaml
k8s:
  subnet: <ip prefix>
  apiserver_advertise_address: <ip address>
calico:
  IP_AUTODETECTION_METHOD: <method>
```

`k8s.subnet` is mandatory and is the subnet that must be used to interconnect
the pods in the cluster.

`k8s.apiserver_advertise_address` is optional. If set, the master will be
reachable via the IP address that is set. Otherwise, an IP address is set
automatically. See
[https://kubernetes.io/docs/reference/setup-tools/kubeadm/](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
for more information.

`calico.IP_AUTODETECTION_METHOD` is optional. If set, calico will follow the
instruction to decided which IP address to use. Otherwise, is automatically
chose an IP address. See
[https://projectcalico.docs.tigera.io/reference/node/configuration](https://projectcalico.docs.tigera.io/reference/node/configuration)
for details.


### k8s-node

_k8s-node_ is defined in `k8s-node.yaml`. Its role is to add the nodes of the
`switches` group to the k8s cluster created above.
To that aim, it installs kubernetes on the nodes, and adds them in the cluster
thanks to a temporary token. It also installs the certificate authority on the
nodes.

Run the playbook with the following command.

```bash
ansible-playbook  -i inventories/sopnode_emu/ k8s-node.yaml --extra-vars "@params.sopnode_emu.yaml"
```

### fabric-switch

_fabric-switch_ is defined in `fabric-switch.yaml` and presets the `fabric-tna`
switches listed in the in the `fabric_switches` group such that they are not
treated as usual compute resources in the k8s cluster. This group must be a
subset of the `switches` group.

```bash
ansible-playbook  -i inventories/sopnode_emu/ fabric-switch.yaml --extra-vars "@params.sopnode_emu.yaml"
```

---------------------


Deploy ONOS:
```bash
ansible-playbook -i inventories/inria/ onos.yaml --extra-vars "@params.yaml"
```

Add switches to the fabric
```bash
ansible-playbook -i inventories/inria/ fabric-switch.yaml --extra-vars "@params.yaml"
```

Deploy stratum on switches
```bash
ansible-playbook -i inventories/inria/ stratum.yaml --extra-vars "@params.yaml"
```