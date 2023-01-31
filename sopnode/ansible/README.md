This repository provides Ansible playbooks and roles to automate the deployment
of a Fabric-TNA environment on SophiaNode

## Setup automation environment

We use Ansible to deploy the different services on the SophiaNode
infrastructure. The playbooks require Ansible 2.13 or higher (we tested them on
`Ansible 2.13.2`). The present section presents instructions on how to setup the
environment on GNU/Linux Ubuntu 20.04.

To interact with the infrastructure we rely on `ansible.posix`,
`community.kubernetes`, `cloud.common`, `kubernetes.core`, `community.crypto`,
`community.general`, `community.docker`, and `netbox.netbox` collections that
can be installed with `ansible-galaxy`:

```bash
ansible-galaxy install -r collections/requirements.yml
```

To allow non-interactive ssh password authentication we rely on `sshpass` that
can be installed as follows.

```
sudo apt install sshpass
```

To interact with Netbox inventory, `netaddr`, `pynetbox`, `PyYAML`, and
`requests` are required. They can be installed with pip as follow:

```
pip3 install -r requirements.txt
```

## Deploy the services on SophiaNode

Ansible uses inventories to determine on which hosts to execute its tasks. Our
inventories are provided in the `inventories` directory.

The inventories are composed of the following groups:

* `controllers`: group all the hosts that will run the SDN controller.
* `computes`: group all the compute nodes managed by the k8s cluster.
* `switches`: group all the switches.
* `masters`: group all the hosts that will play the role of k8s master.

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
* __fabric__: deploy SD-Fabric.

To run properly, the order above must be respected when deploying the services.
Except _stratum_ and _fabric_ that can be interchanged.

For the sake of simplicity, all the commands below are given for the
`sopnode_emu` inventory but they could be apply to any other inventory.

The `registry` service is also provided but is not described in this document.
It provides a docker registry service with authentication for the k8s cluster.

### k8s-master

_k8s-master_ is defined in the `k8s-master.yaml` playbook. Its role is to create
a kubernetes cluster managed by the hosts of the `masters` group. As of today
only one master node is allowed.

It installs k8s on the master node and creates a new cluster with the [Calico
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
  apiserver_advertise_address: <ip address>
  serviceSubnet: <ip prefix>
  podSubnet: <ip prefix>
  dnsDomain: <dns name>
  calico:
    nodeAddressAutodetectionV4: <KubernetesAutodetectionMethod>
    encapsulation: <EncapsulationType>
  runtime: <string>  
```

* `k8s.podSubnet` is the subnet that will be used to interconnect the pods in
the cluster. Defaults to `10.244.0.0/16` if not provided.

* `k8s.serviceSubnet` is the subnet that will be used to advertise services in
the cluster. Defaults to `10.96.0.0/16` if not provided.

* `k8s.dnsDomain` is the domain suffix that will be used for pods and services
in the cluster. Defaults to `cluster.local` if not provided.

* `k8s.apiserver_advertise_address` is optional. If set, the master will be
reachable via the IP address that is set. Otherwise, an IP address is set
automatically. See
[https://kubernetes.io/docs/reference/setup-tools/kubeadm/](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)
for more information.

* `k8s.calico.nodeAddressAutodetectionV4` is mandatory and is the calico's node
address auto-detection method to use. See
[https://projectcalico.docs.tigera.io/reference/installation/api](https://projectcalico.docs.tigera.io/reference/installation/api)
for more information.

* `k8s.calico.encapsulation` is the calico's encapsulation
method to use. Defaults to `VXLAN` if not provided. See
[https://projectcalico.docs.tigera.io/reference/installation/api](https://projectcalico.docs.tigera.io/reference/installation/api)
for more information.

* `k8s.runtime` is the container runtime to be used by k8s, e.g., docker, cri-o.

### k8s-node

_k8s-node_ is defined in `k8s-node.yaml`. Its role is to add the nodes of the
`switches` and `computes` groups to the k8s cluster created above.
To that aim, it installs kubernetes on the nodes, and adds them in the cluster
thanks to a temporary token. It also installs the certificate authority on the
nodes.

Run the playbook with the following command.

```bash
ansible-playbook  -i inventories/sopnode_emu/ k8s-node.yaml --extra-vars "@params.sopnode_emu.yaml"
```

### fabric-switch

_fabric-switch_ is defined in `fabric-switch.yaml` and presets the `fabric-tna`
switches listed in the in the `switches` group such that they are not
treated as usual compute resources in the k8s cluster.

Run the playbook with the following command.

```bash
ansible-playbook  -i inventories/sopnode_emu/ fabric-switch.yaml --extra-vars "@params.sopnode_emu.yaml"
```

### stratum

_stratum_ is defined in `stratum.yaml` and deploys stratum on the switches
defined in the `switches` group. Stratum runs in docker.

It can deploy stratum on tofino switches or on bmv2 switches. If bmv2 is
selected, it will build and install bmv2 before deploying stratum. As of today
all switches must be of the same type (either bmv2 or tofino).

Run the playbook with the following command.

```bash
ansible-playbook  -i inventories/sopnode_emu/ stratum.yaml --extra-vars "@params.sopnode_emu.yaml"
```

The following parameters can be used:

```yaml
stratum:
  mode: 'tofino' | 'bmv2'
  bmv2_user: <username>
```

* `stratum.mode` is mandatory and defines whether the switches are tofino or
bmv2.

* `stratum.bmv2_user` is needed (and mandatory) when the `bmv2` mode is
selected. It specifies which user should be used to launch the stratum instance.
This user cannot be `root`.

Stratum relies on a chassis configuration that defines a mapping between the
actual device and stratum. To define a chassis configuration, just put the
chassis configuration in
`files/chassis_config/<inventory_hostname>/chassis_config.pb.txt` where
`<inventory_hostname>` is the hostname provided in the inventory. If you do not
provide a chassis configuration then the default one from stratum will be used.

See [https://docs.sd-fabric.org/sdfabric-1.1/configuration/chassis.html](https://docs.sd-fabric.org/sdfabric-1.1/configuration/chassis.html)
for details.

> When the `bmv2` mode is chosen, the chassis config is not loaded as described
> above. Instead a default configuration with 9 ports is loaded.
>
> Each port is attached to a `veth` of the hosting machine. You can send and
> receive packets for stratum port `i` using `veth[(i-1) * 2 + 1]` on the
> hosting machine.
>
> The simplest way to feed this `veth` port is to bridge it to the physical port
> you want to use to carry traffic.

### fabric

_fabric_ is defined in _fabric.yaml_. It is in charge of building SD-Fabric,
deploy an ONOS controller in the nodes of the `controllers` group and deploy 
SD-Fabric on the switches. SD-Fabric can be built for bmv2 or for tofino
switches.

ONOS can be deployed either as a docker instance or in the k8s cluster.


Because of licensing issues, we cannot provide `p4-studio` that is required to
build SD-Fabric for tofino switches. It is assumed here that  the `p4-studio`
docker image is available on the controller nodes and that this image contains
`p4-studio` with the `SDE 9.7.0`.

```bash
ansible-playbook  -i inventories/sopnode_emu/ fabric.yaml --extra-vars "@params.sopnode_emu.yaml"
```

The following parameters can be used:

```yaml
fabric:
  profile: <profile>

onos:
  image: <docker image>
  mode:  'k8s' | 'docker'
  applications:
    - name: <application>
    - ...

netcfg:
  <fabric-tna netcfg>
```

* `fabric.profile` is the SD-Fabric profile to compile. Typically, this will be
`fabric-tna` for tofino switches and `fabric-v1model` for bmv2 switches. See
[Fabric-Tna documentation](https://github.com/stratum/fabric-tna) for details.

* `onos.image` is the image to use for the ONOS SDN controller (e.g.,
`onosproject/onos:2.5.8`).

* `onos.mode` is the mode of deployment for ONOS. If the mode is `k8s` then ONOS
will be deployed in k8s cluster created above. If `docker` is used then ONOS
will be deployed on the node in the `controllers` group as a docker instance.

* `onos.applications` is a list of tuples `name: <application>` where each
`<application>` corresponds to an application available in the ONOS instance,
e.g., `org.onosproject.drivers.bmv2`, and that must be activated.

* `netcfg`: takes a Fabric-TNA network configuration described in YAML. See
[https://docs.sd-fabric.org/master/configuration/network.html](https://docs.sd-fabric.org/master/configuration/network.html)
for details.

In the Fabric-TNA network configuration, the driver must be `stratum-tofino` for
tofino switches and `stratum-bmv2` for bmv2 switches. In a similar manner, the
pipeconf for bmv2 switches is `org.stratumproject.fabric.bmv2`, is
`org.stratumproject.fabric.mavericks_sde_9_7_0` for EdgeCore Wedge100BF-32QS
switches, and is `org.stratumproject.fabric.montara_sde_9_7_0` for EdgeCore
Wedge100BF-32X switches. 

#### Building a p4-studio docker image

On the controller, assuming that the you have the SDE in the tar ball called
`bf-sde-9.7.0.tgz`, create the following dockerfile

```Dockerfile
FROM ubuntu:18.04
ADD bf-sde-9.7.0.tgz .
WORKDIR bf-sde-9.7.0/p4studio
RUN ./install-p4studio-dependencies.sh
RUN ./p4studio profile apply ./profiles/all-tofino.yaml
ENV PATH="/bf-sde-9.7.0/install/bin/:${PATH}"
```

and build the docker image with
```bash
docker build  -t p4-studio -f Dockerfile .
```

### Dealing with slow network connection or machine
In some situations, retrieving packages or compiling code may take some time, resulting in Ansible loosing its SSH channels.

A first solution is to force keep alive messages with the ssh client, for
example by adding the following in `~/.ssh/config`
```
Host *
        ServerAliveInterval 10
        ServerAliveCountMax 2
```

If timeouts still occur, agood enough solution is to increase timeouts for `ControlPersist`, `connect_timeout`, and `command_timeout` in Ansible
configuration. In our setup we directly changed them to 3600 (i.e., 1h) in
`/etc/ansible/ansible.cfg` as our ansible runs in a sandbox. In other scenarios, using environment variables is probably better (see [https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html) for more information).