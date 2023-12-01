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

> git clone --recurse-submodule https://github.com/dsaucez/SLICES.git

# Contact Blueprint Support [[Blueprint Support](contact.md)]