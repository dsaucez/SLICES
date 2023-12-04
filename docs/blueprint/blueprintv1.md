# SLICES Blueprint

We are currently working on a newer version of the blueprint reference implementation that may break the hands’on presented in this document.
During this transition if you want to practice with our hands’on please follow the MOOC mentioned below:

This documentation describes the SLICES blueprint. Historically blueprints were used to produce unlimited numbers of accurate copies of plans. For SLICES, the concept is taken to allow each site to reproduce software and hardware architectures on the SLICES sites and nodes. The SLICES blueprint targets testbed owners and operators, it is not intended to be used by experimenters or testbed users. The blueprint is an way to eventually reach a unified architecture between sites and nodes composing SLICES and easily onboard members to fields of research that may not be their core business and so learn about the needs and best practices to make SLICES a success.

With the blueprint, sites are able to deploy and operate partial or full 5G networks, with simulated and/or hardware components.

The blueprint is designed in a modular way such that one can either deploy it fully or only partially. For example, people only interested in 5G can only deploy the core and use a simulated RAN while people interested only by the RAN can just deploy a RAN, assuming they have access to a core (e.g., via the SLICE central node or another partner). Advanced users may even deploy a core and connect it with multiple RANs.

## Architecture
In this blueprint, the core and RAN are implemented with OpenAirInterface (see https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed for details) that are deployed in kubernetes clusters that can be remotely connected as shown in the figure below.

<img src="./images/5g_ran_advanced_different_clusters.svg">

The deployment of the blueprint is split in five main steps:
1. Setup Deployment Environment.
2. Deploy Kubernetes Clusters to host the 5G Core and/or the RAN.
3. Deploy 5G Core in the Cluster.
4. Deploy 5G RAN and the connected Core.
5. Nodes and Sites Interconnection

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
---
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
---
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

## Kubernetes Cluster Deployment
In the blueprint we deploy and operate the 5G network in a cloud native manner, this means that the core and the RAN need a cluster to be deployed. In this part of the tutorial we describe how to deploy a multi-nodes kubernetes (aka k8s) cluster where the 5G functions will be automatically orchestrated. We consider standard kubernetes (in the future and depending on the needs, other flavors of k8s such as OpenShift or Rancher will be considered). Either VM based kubernetes or baremetal kubernetes can be used.

To deploy the blueprint, at least 2 servers are required. They are inter-connected by high speed link (ideally 100 Gbps).

In the simplest scenario the core and the RAN are deployed in the same cluster but we also consider the case where the core and the RAN are deployed in independent clusters. Follow the same deployment procedure for every cluster and adapt the IP addresses and kubernetes parameters accordingly. Instructions on how to intercconnect clustars are provided in

[Nodes and sites interconnection](docs/nodesinterconnect.md)

### Deploy K8S
---
The creation of the kubernetes cluster and all of its dependencies (e.g., container runtimes) is taken care of by the blueprint instantiation itself.

The blueprint distinguishes 2 types of nodes in the k8s cluster. The masters nodes are nodes that run the cluster control plane and the computes nodes are normal k8s node to which load can be scheduled. Make sure you set your Ansible inventory adequately as described in

[Nodes and sites interconnection](docs/nodesinterconnect.md)

This blueprint only support 1 control plane node.

The configuration of the k8s cluster is provided via the Ansible k8s variable.

It is possible to chose between docker or cri-o container runtimes by setting the k8s.runtime variable to either docker or cri-o. In the example below, docker is used. Remember that the playbook takes care of installing and configuring all dependencies. Therefore, it will properly install the container runtime as specified in the configuration.

K8s pod and service subnets, and domain name are set via the k8s.podSubnet, k8s.serviceSubnet, and k8s.dnsDomain variables, respectively.

The cluster uses the Calico CNI, it is configured via the k8s.calico variables. In the example below calico network is bound to interfaces in the 192.0.2.0/24 subnet. Only VXLAN encapsulation has been tested. Multus is also automatically installed and configured in the cluster.

In some environments the address of the default interface should not be used for kubernetes API. To configure it to a specific value, the k8s.apiserver_advertise_address variable can be set to the desired IP address to listen on and to advertise.

Below is an example of content of a configuration file to deploy the k8s cluster:
```
# k8s config
k8s:
    runtime: docker
    podSubnet: 10.244.0.0/16
    serviceSubnet: 10.96.0.0/16
    dnsDomain: cluster.local
    apiserver_advertise_address: 192.0.2.1
    calico:
        nodeAddressAutodetectionV4:
          cidrs:
            - 192.0.2.0/24
        encapsulation: VXLAN
```

If this file is called params.blueprint.yaml, to create the cluster run the following command:

```
ansible-playbook  -i inventories/blueprint/ k8s-master.yaml --extra-vars "@params.blueprint.yaml"
```

This command provisions the k8s control-plane node and creates a kubernetes cluster.

Once the cluster is created, the other nodes can be attached to it with the following command:

```
ansible-playbook  -i inventories/blueprint/ k8s-node.yaml --extra-vars "@params.blueprint.yaml"
```

At this stage the k8s cluster is up and running with all the nodes from the infrastructure.

## Deploy 5G Core
In this blueprint, the core is implemented with the 5G Core network by the OpenAirInterface community (see https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed for details).

The 5G Core core runs in the kubernetes cluster setup above. The core deployed in the blueprint is composed of UDR, UDM, AUSF, NRF, AMF, SMF, and UPF. All these functions are connected to a common database

We distinguish two scenarios. The basic option consists is the case where the core and RAN are deployed in the same kubernetes cluster and where only one network is used to interconnect all functions together. In the Advanced scenario the core and the RAN are in different clusters and the control and user planes use different networks.

### Basic Option
---
Message exchanges between all 5G functions are carried over by the pod network of the k8s cluster, as depicted in the figure below.

<img src="./images/5g_core.svg">

To deploy 5G core, the k8s namespace in which to deploy the function must be provided with the GCN.namespace ansible variable (e.g., blueprint). If the namespace doesn’t exist, it will be created automatically. In addition, the GCN.core.present ansible variable must be true:

```
# 5G config
GCN:
    namespace: blueprint
    core:
        present: true
```

Assuming this file is called params.5g.yaml, then the core is deployed with the following command:
```
ansible-playbook  -i inventories/blueprint/  5g.yaml  --extra-vars "@params.5g.yaml"
```
After running this command, the 5G core is deployed in the blueprint namespace of the kubernetes cluster.

### Advanced Option
---
The deployment above is rather simple and does not segment user traffic from control traffic. In real world scenarios (e.g., core and RAN not in the same cluster), it is required to separate these traffic by exposing multiple interfaces to the functions (i.e., pods). To do so we rely on multus.

More precisely, the AMF and UPF functions have an additional interface connected to a network dedicated to the RAN traffic. These interface are called net1 in the AMF and UPF pods. This network uses the 172.22.10.0/24 subnet as shown below.

<img src="./images/5g_core_advanced.svg">

The deployment of the core uses helm charts from OPENAIR-CN-5G. It is possible to redefine the charts and chart values directly by setting the GCN.core.custom_files and GCN.core.custom_values variables. If these variables are not defined, defaults from OAI are used. The configurations looks as follows:
```
# 5G config
GCN:
    namespace: blueprint
    core:
        present: true
        custom_files: blueprint/files
        custom_values: blueprint/values
```

Assuming this file is called params.5g.yaml, then the core is deployed with the following command:
```
ansible-playbook  -i inventories/blueprint/  5g.yaml  --extra-vars "@params.5g.yaml"
```

After running this command, the 5G core is deployed in the blueprint namespace of the kubernetes cluster.

The behavior of these two additions is to replace standard chart elements taken from the official repository with custom ones, stored locally.

More precisely, the whole directory found in these two specified locations is replicated in the oai-cn5g-fed/charts/oai-5g-core/ of the OAI deployment.

For example, if the content of the blueprint directory is the following:
```
blueprint/
├── files
│   ├── oai-amf
│   │   └── templates
│   │       └── deployment.yaml
│   └── oai-spgwu-tiny
│       └── templates
│           └── deployment.yaml
└── values
    ├── oai-5g-basic
    │   └── values.yaml
    ├── oai-amf
    │   └── templates
    │       └── multus.yaml
    └── oai-spgwu-tiny
        └── templates
            └── multus.yaml
```

it means that oai-cn5g-fed/charts/oai-5g-core/oai-5g-basic/values.yaml, oai-cn5g-fed/charts/oai-5g-core/oai-amf/templates/deployment.yaml, oai-cn5g-fed/charts/oai-5g-core/oai-amf/templates/multus.yaml, oai-cn5g-fed/charts/oai-5g-core/oai-spgwu-tiny/templates/deployment.yaml, and oai-cn5g-fed/charts/oai-5g-core/oai-spgwu-tiny/templates/multus.yaml files will be changed on the OAI chart to be run by the one given in the Ansible deployment node. If the file does not exist, it is created.

To define where to store your files, please refer to Ansible precedence rules (https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html). By default we store them in the roles/5g/files/ directory.

The example provided in the blueprint is used for deployment of the 5G core on hosts where the Dedicated network is attached to the ran0 interface. The multus attachment and addressing plan for the AMF and SPGWU is defined in the blueprint/values/oai-5g-basic/values.yaml file.

Make sure that the following variables in this file reflect your topology and addressing plan: oai-amf.multus.n2IPadd oai-amf.multus.n2Netmask, oai-amf.multus.hostInterface, oai-spgwu-tiny.multus.n3IPadd, oai-spgwu-tiny.multus.n3Netmask, and oai-spgwu-tiny.multus.hostInterface.

The variables oai-amf.multus.create and oai-spgwu-tiny.multus.create must be set to true to create the dedicated interface in the AMF and UPF pods. It is called net1 inside the pod.

By default with the OAI repository the default route is set to use the multus interface. In the blueprint deployment this behavior is not desired. Hence, oai-amf/templates/deployment.yaml and oai-spgwu-tiny/templates/deployment.yaml are modified avoid it.

To be able to reach the RAN network or other external networks via the multus interface, routes to these prefixes must be added in the AMF and the SPGWU pods. These routes are added with multus via the blueprint/values/oai-amf/templates/multus.yaml and blueprint/values/oai-spgwu-tiny/templates/multus.yaml files. In our case, the prefixes are 10.8.0.0/24, 10.0.10.0/24, and 10.0.20.0/24 and the gateway is 172.22.10.1.

We use OAI defaults for operator information, for example, we have
* Data Network Name (dnn): oai
* Mobile Country Code (mcc): 001
* Mobile Network Code (mnc): 01

Please refer to OAI documentation for details about how to setup the environment (https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_HOME.md).

We recommend to put all the files that corresponds to parameters of the deployment in the custom_values directory and use the custom_files directory to put the static files (i.e., not changing from one deployment to another).

## Deploy 5G RAN
In this blueprint, the RAN is implemented with OpenAirInterface (see https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed for details). We assume that the 5G core is already deployed.

We distinguish two scenarios. The basic option consists is the case where the core and RAN are deployed in the same kubernetes cluster and where only one network is used to interconnect all functions together. In the Advanced scenario the core and the RAN are in different clusters and the control and user planes use different networks.

### UE subscription in 5G Core
---
The core will allow a user equipment to connect to the network only if its SIM card is registered correctly. In the current version of OAI, subscription information is stored in the Database function that is implemented with MySQL.

We do not provide abstractions for this action yet, instead please update the database directly with the new information. To connect to the MySQL server of the core, run the following command from any node in the cluster hosting the core (default password is linux):
```
kubectl exec -n blueprint -it $(kubectl get -n blueprint pods --selector=app=mysql -o jsonpath='{.items[*].metadata.name}') -c mysql  -- mysql -p oai_db
```

Below is an example of addition of UEID 001010000000001 in the database:
```
INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
('001010000000001', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', 'C42449363BBAD02B66D16BC975D77CC1', NULL, NULL, NULL, NULL, '001010000000001');
INSERT INTO `SessionManagementSubscriptionData` (`ueid`, `servingPlmnid`, `singleNssai`, `dnnConfigurations`) VALUES
('001010000000001', '00101', '{\"sst\": 1, \"sd\": \"16777215\"}','{\"oai\":{\"pduSessionTypes\":{ \"defaultSessionType\": \"IPV4\"},\"sscModes\": {\"defaultSscMode\": \"SSC_MODE_1\"},\"5gQosProfile\": {\"5qi\": 1,\"arp\":{\"priorityLevel\": 15,\"preemptCap\": \"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\", \"downlink\":\"1000Mbps\"},\"staticIpAddress\":[{\"ipv4Addr\": \"12.1.1.10\"}]},\"ims\":{\"pduSessionTypes\":{ \"defaultSessionType\": \"IPV4V6\"},\"sscModes\": {\"defaultSscMode\": \"SSC_MODE_1\"},\"5gQosProfile\": {\"5qi\": 2,\"arp\":{\"priorityLevel\": 15,\"preemptCap\": \"NOT_PREEMPT\",\"preemptVuln\":\"PREEMPTABLE\"},\"priorityLevel\":1},\"sessionAmbr\":{\"uplink\":\"1000Mbps\", \"downlink\":\"1000Mbps\"}}}');
```

Make sure that gNBs and UEs are configured with the proper DNN, MCC, MNC…

### Basic Option
---
In this scenario the RAN consists of a gNB that is connected on the pod network of the k8s cluster that also hosts the 5G core, as shown below as well as an optional User Equipment (UE) connected to the gNB.

<img src="./images/5g_ran.svg">

To deploy the RAN, the k8s namespace in which to deploy the function must be provided with the GCN.namespace ansible variable (e.g., blueprint). It must be the same one as the one of the 5G core. In addition, the GCN.RAN.present ansible variable must be true:
```
# 5G config
GCN:
    namespace: blueprint
    RAN:
        present: true
    UE:
        present: true
```

Assuming this file is called params.5g.yaml, then the RAN is deployed with the following command:
```
ansible-playbook  -i inventories/blueprint/  5g.yaml  --extra-vars "@params.5g.yaml"
```

After running this command, the RAN is deployed in the blueprint namespace of the kubernetes cluster with a gNB and a UE.

### Advanced Scenario
---
In the advanced scenario a dedicated network is used to carry the user plane. We consider three deployment cases. In the first case, the 5G core and the RAN are deployed in the same k8s cluster. In the second case, the RAN is deployed in its own k8s cluster. In the last case, we consider a standalone hardware based RAN remotely connected to the 5G core.

In all cases, it is assumed that the 5G core has been deployed according to the Advanced option of the blueprint.

#### Shared 5G Core and 5G RAN cluster
In this scenario the 5G core and the RAN are deployed in the same k8s cluster and a network is dedicated to covey RAN traffic. The RAN must be configured to use this dedicated network and to use addresses in the correct subnet, as shown in the figure below.

<img src="./images/5g_ran_advanced_same_cluster.svg">

To deploy the RAN and a UE to use this network, we have to define GCN.RAN.custom_files and GCN.RAN.custom_values:
```
# 5G config
GCN:
    namespace: blueprint
    RAN:
        present: true
        custom_files: blueprint/ran_files
        custom_values: blueprint/ran_values
    UE:
        present: true
```

Assuming this file is called params.5g.yaml, then the RAN is deployed with the following command:
```
ansible-playbook  -i inventories/blueprint/  5g.yaml  --extra-vars "@params.5g.yaml"
```

The behavior of these two additions is to replace standard chart elements taken from the official repository with custom ones, stored locally.

More precisely, the whole directory found in these two specified locations is replicated in the oai-cn5g-fed/charts/oai-5g-ran/ of the OAI deployment.

For example, if the content of the blueprint directory is the following:

```
blueprint
├── ran_files
│   ├── oai-gnb
│   │   └── templates
│   │       └── deployment.yaml
│   └── oai-nr-ue
│       └── templates
│           └── deployment.yaml
└── ran_values
    ├── oai-gnb
    │   └── values.yaml
    └── oai-nr-ue
        └── values.yaml
```

it means that oai-cn5g-fed/charts/oai-5g-ran/oai-gnb/values.yaml, oai-cn5g-fed/charts/oai-5g-ran/oai-gnb/templates/deployment.yaml, oai-cn5g-fed/charts/oai-5g-ran/oai-nr-ue/templates/multus.yaml, and oai-cn5g-fed/charts/oai-5g-ran/oai-nr-ue/templates/deployment.yaml files will be changed on the OAI chart to be run by the one given in the Ansible deployment node. If the file does not exist, it is created.

To define where to store your files, please refer to Ansible precedence rules (https://docs.ansible.com/ansible/latest/reference_appendices/general_precedence.html). By default we store them in the roles/5g/files/ directory.

The example provided in the blueprint is used for deployment of the 5G RAN on hosts where the Dedicated network is attached to the ran0 interface.

#### Separate 5G Core and 5G RAN clusters
In general, the 5G core and the RAN will be deployed in separate clusters (e.g,. one for the central core and one per RAN region).

This means that the RAN and core are not on the same networks as depicted in the figure below.

<img src="./images/5g_ran_advanced_different_clusters.svg">

In this scenario, we assume IP connectivity between the dedicated network of the 5G core cluster (172.22.10.0/24) and the dedicated network of the RAN cluster (10.0.10.0/24). This is why we configured multus in the Advanced scenario of 5G core with routes to the prefix 10.0.10.0/24. We will do a similar configuration in the RAN too. However, configuring multus is not sufficient and the infrastructures themselves must be configured to have L3 connectivity between the core and the RAN. Please refer to

[Nodes and sites interconnection](docs/nodesinterconnect.md)

to see how to interconnect RAN and Core infrastructures. In substance, if the RAN in a separate infrastructure than the core, the network must be configured such that the RAN is able to reach the N2 address of the AMF and the N3 address of the UPF and that the UPF and AMF are able to reach the N2N3 addresses of the gNB.

Once network connectivity is properly setup, we can deploy the RAN in its own cluster.

To deploy the RAN and a UE we have to define GCN.RAN.custom_files and GCN.RAN.custom_values:
```
# 5G config
GCN:
    namespace: blueprint
    RAN:
        present: true
        custom_files: blueprint/client1/ran_files
        custom_values: blueprint/client1/ran_values
    UE:
        present: true
```

Assuming this file is called params.5g.yaml, then the RAN is deployed with the following command:
```
ansible-playbook  -i inventories/blueprint/  5g.yaml  --extra-vars "@params.5g.yaml"
```

If you look at the files in blueprint/client1/ you will see that the only differences with the scenario where core and RAN use the same cluster are the local addresses used by the gNB and UE that are in the 10.0.10.0/24 prefix and the presence of a route towards the 172.22.10.0/24 subnet in the multus configuration.

#### RAN on a bare-metal server with a USRP platform
For the RAN nodes, we consider high-end PCs that are connected with the respective RUs. The RUs tested within this scenario are USRP X310s, and USRP N310.

The PC used as the RAN node is a 11th Gen Intel(R) Core(TM) i7-11700K with 64GB of RAM and 128GB SSD storage.

##### **Communication with the USRP**
You need to configure the appropriate communication links with the USRP platform. To do this, please follow the links below for each platform.

USRP B210: https://kb.ettus.com/B200/B210/B200mini/B205mini_Getting_Started_Guides

USRP X310: https://kb.ettus.com/X300/X310_Getting_Started_Guides

Connecting with a 10Gbps optical link: https://kb.ettus.com/X300/X310_Getting_Started_Guides#Upgrade_to_10_Gigabit_Ethernet_or_PCI-Express and load the “XG” FPGA image for the USRP

USRP N310: https://kb.ettus.com/USRP_N300/N310/N320/N321_Getting_Started_Guide#N300.2FN310

For the USRP N310, use the “XG” FPGA image for using the 10Gbps network interfaces to the host node.

##### **RAN**
In order to deploy the needed components for the RAN, you need to use a separate ansible playbook, and specify the node on which the RAN software should be added.

To do this, update the file inventories/UTH/hosts.yml:
```
all:
    children:
        rans:
            hosts:
                10.64.44.77
```

In the above example, we assume that the node hosting the RAN is located at the 10.64.44.77 IP address.

Then, prepare the node and installed all needed software using the following command:
```
ansible-playbook  -i inventories/UTH/ ran.yml
```

This will deploy all the needed software on the RAN node on the folder /root/openairinterface/

To start the OAI RAN software, you need to update the conf file (depending on your USRP platform, the AMF IP address, and the IP address of the USRP). On the RAN node, do the following:

###### **USRP B210:**
```
cd /root/openairinterface5g
source oaienv
cd cmake_targets/ran_build/build
```

Update the ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf file based on your AMF IP address. Make sure that it is reachable from your RAN node.

To run the OAI RAN:
```
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf --sa -E --continuous-tx
```

###### **USRP N300:**
```
cd /root/openairinterface5g
source oaienv
cd cmake_targets/ran_build/build
```

Update the ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/ggnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf file based on your AMF IP address. Make sure that it is reachable from your RAN node. Also update the field on the SDR addresses in the RU section of the config file to indicate the IP addresses that the USRP is reachable.

To run the OAI RAN:
```
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf --sa --usrp-tx-thread-config 1
```

###### **USRP X300:**
```
cd /root/openairinterface5g/
source oaienv
cd cmake_targets/ran_build/build
```

Update the ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf file based on your AMF IP address. Make sure that it is reachable from your RAN node. Also update the field on the SDR addresses in the RU section of the config file to indicate the IP addresses that the USRP is reachable.

To run the OAI RAN:
```
sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf –sa –usrp-tx-thread-config 1 -E –continuous-tx
```

### Testing Deployment
---
#### Standard option
Testing if the blueprint is replicated correctly and corresponds to the parameters can be tedious but is a good exercise to get acquainted with the different technologies and concepts used in the blueprint. Therefore, this section does not pretend to provide exhaustive tests.

If the deployment succeeded, the UE shall be able to ping (i.e., ICMP echo request/response) a landmark node (e.g., google.fr). To run this test, we connect to the UE and run the ping command to the landmark.

The landmark must be a host that can be pinged from the infrastructure.

To run the test, the k8s namespace in which the UE is deployed must be set in the GCN.namespace ansible variable (e.g., blueprint). In addition, the GCN.UE.present ansible variable must be true (i.e., a UE must be present). Finally, the landmark to ping must be defined in the GCN.UE.tests.landmark_ping.landmark ansible variable (e.g., google.fr or 8.8.8.8):
```
# 5G config
GCN:
    namespace: blueprint
    core:
        present: true
    RAN:
        present: true
    UE:
        present: true
        tests:
            landmark_ping:
                landmark: google.fr
```

To run the test, execute the following command:
```
ansible-playbook  -i inventories/blueprint/  5g_test.yaml  --extra-vars "@params.5g.yaml"
```

The output of the task should be similar to the following:
```
TASK [Results of the ping to the landmark] *******************************************************************************************************************************************************
ok: [192.0.2.1] => {
    "msg": "4 packets transmitted, 4 received, 0% packet loss, time 3002ms"
}
```

That is essentially a summary of the ping command. If less than 100% packet loss is observed, it means that the UE was able to have at least one successful ping, meaning that the UE can send and received traffic with the outside via its GTP tunnel.

## Contact Blueprint Support [[Blueprint Support](contact.md)]

## External References
[^1]: https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html.