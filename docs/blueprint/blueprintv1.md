# SLICES Blueprint

We are currently working on a newer version of the blueprint reference implementation that may break the hands’on presented in this document.
During this transition if you want to practice with our hands’on please follow the MOOC mentioned below:

This documentation describes the SLICES blueprint. Historically blueprints were used to produce unlimited numbers of accurate copies of plans. For SLICES, the concept is taken to allow each site to reproduce software and hardware architectures on the SLICES sites and nodes. The SLICES blueprint targets testbed owners and operators, it is not intended to be used by experimenters or testbed users. The blueprint is an way to eventually reach a unified architecture between sites and nodes composing SLICES and easily onboard members to fields of research that may not be their core business and so learn about the needs and best practices to make SLICES a success.

With the blueprint, sites are able to deploy and operate partial or full 5G networks, with simulated and/or hardware components.

The blueprint is designed in a modular way such that one can either deploy it fully or only partially. For example, people only interested in 5G can only deploy the core and use a simulated RAN while people interested only by the RAN can just deploy a RAN, assuming they have access to a core (e.g., via the SLICE central node or another partner). Advanced users may even deploy a core and connect it with multiple RANs.

## Architecture
In this blueprint, the core and RAN are implemented with OpenAirInterface (see https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed for details) that are deployed in kubernetes clusters that can be remotely connected as shown in the figure below.

<img src="./images/5g_ran_advanced_different_clusters.svg">

The deployment of the blueprint is split in four main steps:
1. Kubernetes clusters must be deployed to host the core and/or the RAN.
2. The core can be deployed in a cluster.
3. Finally, the RAN can be deployed and connected core.
4. Nodes and sites interconnection

But the first step is to make sure that you properly setup your deployment environment.

## Deployment Setup

Functions and services of the blueprint run on hosts with operating systems installed. It is recommended to run the operating system directly on baremetal devices but virtual machines are also possible, unless stated otherwise.

It is assumed that the hosts (or vhost) used in the blueprint have one of the following operating system installed

* Ubuntu 20.04
* Ubuntu 22.04
* Rocky 9.1 (with or without real-time kernel)
* RHEL 8
* RHEL 9
* Debian 10
* Debian 11
* Fedora 36
* Fedora 37

and that they are all configured with remote access for privileged users with SSH keys. A good choice to start with the blueprint is to use an Ubuntu 20.04 environment. These hosts are assumed to have Internet access and no network filtering between them.

Vanilla installations are considered. No extra software or configuration shall be setup. The only exception being the installation and configuration of an SSH server allowing key authentication.

Only the AMD64 architecture has been extensively tested.

The blueprint installation is automated and can be run from any location as long as it has an SSH access to the nodes of the infrastructure (if no direct SSH access is possible, the use of a proxy or jump host is possible). The node used to deploy the blueprint in the infrastructure is called the deployment node and it is assumed to run either Linux or macOS, in either x86, amd64, or arm64 architectures. We provide a container to play the role of the deployment node.

The following figure presents the installation setup.

<img src="./images/deploy.svg">

To simplify operations, we containerized the deployment node. Check the following for more details about the installation and configuration of the deployment node.

### Deployment Node Preparation

The deployment node does not need to be part of the infrastructure on which the blueprint is replicated. But it needs to be able to connect to every host of the infrastructure with SSH using key based authentication.

The blueprint is a collection of deployments proposed by the partners of the project. To simplify the life of operators replicating the blueprint, the deployment details are hidden behind Ansible playbooks.

For the sake of reproducibility and the flexibility it offers, we strongly recommend to run all operations of the deployment node in a container. In the following we assume that it is the case. Nevertheless, the working directory is shared between the container and the host so you can prepare your configuration from outside of the container.

First, clone the repository with Ansible playbooks on the deployment node:
```
git clone --recurse-submodule https://github.com/dsaucez/SLICES.git
```

Then go to the sopnode/ansible directory:
```
cd SLICES/sopnode/ansible
```

Then, from that directory build the container with docker with the following command:
```
docker build -t blueprint -f Dockerfile .
```
Finally, to use this container, run the following:
```
docker run -it -v "$(pwd)":/blueprint -v ${HOME}/.ssh/id_rsa_blueprint:/id_rsa_blueprint blueprint
```
This launches the deployment node container where the blueprint is mounted in the /blueprint directory and the private key to use to connect to the infrastructure is mounted in the /id_rsa_blueprint file, assuming the key is actually stored in your home SSH directory and is called id_rsa_blueprint.

At that stage you are in a shell with the deployment environment fully setup.

The first thing to do is to create the Ansible inventory with the nodes composing the infrastructure. See below for details.

### Ansible Inventory
The directory inventories/blueprint/ contains a skeleton of Ansible inventory for deploying the blueprint.

First, adapt the inventories/blueprint/hosts file to reflect your infrastructure.

It is composed of 3 host groups:

computes lists all the nodes to be used as compute nodes in the cluster,
aka k8s node.

masters lists all the nodes to be used as k8s control-plane nodes. As of
know only one is allowed.

openvpn lists all the nodes to be used as openvpn servers.
For each node in the infrastructure you have to provide the xx-name parameter that is the hostname of the node without its domain. For hosts running in RAM disks, add the xx-ramdisk parameter to the host and set it to true.

The following example shows the case with two compute nodes (node2, node3), one control-plane master (node1) and one openvpn server. Their IP addresses are 192.0.2.2, 192.0.2.3, 192.0.2.1, and 192.0.2.4, respectively.:

```
all:
  children:
    computes:
      hosts:
        192.0.2.2:
          xx-name: node2
        192.0.2.3:
          xx-name: node3
    masters:
      hosts:
        192.0.2.1:
          xx-name: node1
    openvpn:
      hosts:
        192.0.2.4:
          xx-name: openvpn-1
```

Configure your inventory to suit your needs. Instead of providing their IP addresses, you can use the FQDNs of the nodes.

You also have to adapt the inventories/blueprint/group_vars/all file to define the username to use to connect to the hosts and the path to the private key to get authenticated:

```
ansible_ssh_private_key_file: /id_rsa_blueprint
ansible_user: ubuntu
```

Here we are in the case where the private key is stored in the /id_rsa file and the user to login to the machine is ubuntu.

Obviously the inventory can be adapted for the specific needs of the infrastructure (e.g., jump host, different credentials for different hosts…). For more details about Ansible inventories, check [^1].


# Contact Blueprint Support [[Blueprint Support](contact.md)]

# External References
[^1]: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html.