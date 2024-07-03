# Integration of FlexRIC on Blueprint

This branch of the Blueprint project integrates the FlexRIC controller, offering advanced features and capabilities. Below is a detailed overview of the included features, fixes, deployment instructions, and customization options.

## Features

This branch includes the following major enhancements:

1. **New OAI Core (v2.0.1)**: Updated version for improved performance and reliability.
2. **New OAI RAN (v2.0.1)**: Enhanced Radio Access Network functionality with O-RAN capabilities (KPM and RC).
3. **FlexRIC Integration (Development Version)**: O-RAN standard KPM v2.01/v2.03/v3.00 and RC v1.03
4. **RF Simulator FlexRIC Connectivity**: Enables RIC connectivity and in the simulation of radio frequencies setup within Kubernetes pods.
5. **Baremetal Environment Preparation**: Supports compiling E2-Enabled RAN and FlexRIC on baremetal as a systemd service.
6. **Baremetal FlexRIC Connectivity (USRP RAN)**: Direct connectivity through Universal Software Radio Peripheral (USRP) for real-world testing and deployment.
7. **Fix of the K8s Cluster Initialization (v1.28.2)**: Fix of the K8s end-of-life old versions issue.
8. **Flannel & Calico CNI support**: Option to install one of the two CNI plugins in the cluster.

## Deployment Instructions

#### Prerequisites

- You have already copied the public key of the deployment node to all the compute nodes including it self.

- You have already built the ansible host container with docker with the following command:

    ```
    cd sopnode/ansible
    docker build -t blueprint -f Dockerfile .
    ```

- You already operating in the ansible host container by running this command in the repo's root directory (`blueprint-flexric`):

    ```
    docker run -it -v "$(pwd)":/blueprint -v ${HOME}/.ssh/id_rsa_blueprint:/id_rsa_blueprint blueprint
    ```

- You have already assigned the nodes to the inventories directory: `blueprint/sopnode/ansible/inventories/` (refer to the `inventories/UTH` example for guidance).

- **If** you're using non-root users as usernames in group-vars file (e.g `blueprint/sopnode/ansible/inventories/UTH/group_vars/all`) you should have the same usernames (e.g ubuntu username) accross nodes.

- The (non-root) users should be added to the sudo group. Example commands:

To create a user:

`sudo adduser username`

To add the user to the sudo group:


`sudo usermod -aG sudo username`

replace username with your actual user name

The users should have a pasword-less sudo by simply adding the format in the visudo file:

`sudo visudo`

Add the following line to the file to allow the user to execute sudo commands without a password. Again, replace username with your actual user name.


`<username> ALL=(ALL) NOPASSWD: ALL `

### Working setup with 22.04.4 LTS (Jammy Jellyfish) Cloud Image

```cd blueprint```

Install K8s Control Plane:

```ansible-playbook -i ansible/inventories/UTH k8s-master.yaml -e "@params.blueprint.yaml"```

Install K8s worker nodes and join the cluster:

```ansible-playbook -i ansible/inventories/UTH k8s-node.yaml -e "@params.blueprint.yaml"```

Deploy FlexRIC BP:

```ansible-playbook -i ansible/inventories/UTH flexric.yaml -e "@params.oai-flexric.yaml" ```




### Cluster Initialization

To install the k8s cluster with the **Flannel CNI** run the following playbook from the `blueprint/k8s_deployment` directory:

```
ansible-playbook -i ../sopnode/ansible/inventories/UTH k8s_master.yml -e "cni_plugin=flannel"
```

To install the k8s cluster with the **Calico CNI** run the following playbook from the `blueprint/k8s_deployment` directory:

```
ansible-playbook -i ../sopnode/ansible/inventories/UTH k8s_master.yml -e "cni_plugin=calico"
```

The k8s_master playbook will deploy the following:

1. Prepare all the nodes: computes and masters
2. Install docker and cri-dockerd to every node
3. Initialize the master node and deploy the CNI
4. Join the worker(s) to the master


- The default CNI pod network CIDR for **flannel** is: 10.244.0.0/16 

- The default CNI pod network CIDR for **calico** is: 192.168.0.0/16 


If you want to change the default subnet edit accordingly the files:


`/blueprint/k8s_deployment/k8s_master.yml` :

```
- name: Initialize k8s cluster
  hosts: masters
  become: yes
  roles:
    - role: k8s_master
      vars:
        cni_pod_network_cidrs:
          calico: "192.168.0.0/16"
          flannel: "10.244.0.0/16"

```

and the deployment files of flannel and calico respectively:

 `blueprint/k8s_deployment/roles/k8s_master/files/flannel.yaml`:

```
net-conf.json: |
    {
    "Network": "10.244.0.0/16",
    "Backend": {
        "Type": "vxlan"
    }
    }
```

`blueprint/k8s_deployment/roles/k8s_master/files/calico.yaml`:

```
    - name: CALICO_IPV4POOL_CIDR
        value: "192.168.0.0/16"
        Disable file logging so `kubectl logs` works.
```


## Full End-to-End 5G Deployment (OAI CORE, RF Simulator, FLEXRIC, UE)

To deploy, run the following playbook from the `blueprint/sopnode/ansible` directory:

```
ansible-playbook -i inventories/UTH flexric.yaml --extra-vars "@params.oai-flexric.yaml"
```

After all the pods are running you can ssh to the control-plane node and check the logs of core, RAN and FlexRIC Controller by:


```
cd $HOME/bp-flexric/scripts
bash amf-logs.sh
bash ran-logs.sh
bash flexric-logs.sh
```

Finally you can deploy your xapp by running these commands on the deployment host (master):
```
cd $HOME/bp-flexric/scripts
bash exec-flexric.sh
```

This connects you to the RIC environment, allowing you to select the programming language for your xApp (C or Python3)..

For C language: `/flexric/build/examples/xApp/c`

For python3: `/flexric/build/examples/xApp/python3`


An example command to run an xApp monitoring KPM of RAN:

`root@oai-flexric-698bf9f699-bssqd:/flexric/build/examples/xApp/c/monitor# ./xapp_kpm_moni`


You can always check/edit the configurations for both core/RAN, FlexRIC and UE:

- For Core Files:  `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/core_files`

- For Core Configs: `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/core_values`

- For RAN Files:  `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/ran_files`

- For RAN Configs: `blueprint/sopnode/ansible/roles/flexrc/files/blueprint/oai-flexric/ran_values`

- For FlexRIC Files:  `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/flexric_files`

- For FlexRIC Configs: `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/flexric_values`

- For UE Files:  `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/ue_files`

- For UE Configs: `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/ue_values`



You can simply uninstall the previous blueprint deployment (OAI CORE,RFsimulator,FLEXRIC,UE) by simply run this playbook:

```
ansible-playbook  -i inventories/UTH destroy-oai-flexric.yaml
```

## For the Baremetal end-to-end deployment (OAI CORE,OAI RAN (USRP),FLEXRIC):

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
ansible-playbook  -i inventories/UTH/ ran-bm-flexric.yaml
```

This playbook does the following:

1. Will set system/perfomance parameters and will deploy a new linux kernel (low-latency).
2. Will install and build the RAN with E2 capabilities (E2 Agent).
3. Will install and build FlexRIC.
4. Will assign a host macvlan interface (named 5g-macvlan) based on eth0 parent interface (it can be changed on line 306: ran-bm-flexric.yaml) to be able to communicate with any pod deployed on any node within the same subnet (for n3 and n2 connectivity). The IP address is well-known: 10.10.20.1/24 (it can be changed on line 307: ran-bm-flexric.yaml).
5. Will create a systemd service for FlexRIC and will start the FlexRIC Controller.

#### Core

The AMF adress is static IP adress atatched on the pod via Multus and is well-known: 10.10.20.2
( it can be changed on `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/custom_core_values/oai-5g-basic/values.yaml`)

You can always change the configurations on the core network:

For Core Files:  `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/custom_core_files`

For Core Configs: `blueprint/sopnode/ansible/roles/flexric/files/blueprint/oai-flexric/custom_core_values`

Be carefull, with this setup the custom core directories that you can edit the configs are these:
 **custom_core_files, custom_core_values** not these ~~core_files, core_values~~ like the previous RFsimulator setup


Before starting the OAI RAN you need to start the OAI Core by simply running this playbook:

```
ansible-playbook  -i inventories/UTH flexric.yaml  --extra-vars "@params.core-v2.0.1-multus.yaml"
```

#### RAN

To start the OAI RAN software, you need to update the conf file (depending on your USRP platform, the AMF IP address, the IP address of the gnodeB (macvlan interface: 5g-macvlan) and the IP address of the USRP).  

On the RAN node, do the following:

USRP B210:

```
cd /root/openairinterface5g
source oaienv
cd cmake_targets/ran_build/build
```


Update the ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf file based on your AMF IP address. Make sure that it is reachable from your RAN node.

To run the OAI RAN:

`sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band78.fr1.106PRB.usrpb210.conf --sa -E --continuous-tx`

USRP N300:

```
cd /root/openairinterface5g
source oaienv
cd cmake_targets/ran_build/build
```


Update the ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/ggnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf file based on your AMF IP address. Make sure that it is reachable from your RAN node. Also update the field on the SDR addresses in the RU section of the config file to indicate the IP addresses that the USRP is reachable.

To run the OAI RAN:

`sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf --sa --usrp-tx-thread-config 1`

USRP X300:

```
cd /root/openairinterface5g/
source oaienv
cd cmake_targets/ran_build/build
```


Update the ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf file based on your AMF IP address. Make sure that it is reachable from your RAN node. Also update the field on the SDR addresses in the RU section of the config file to indicate the IP addresses that the USRP is reachable.

To run the OAI RAN:

`sudo ./nr-softmodem -O ../../../targets/PROJECTS/GENERIC-NR-5GC/CONF/gnb.sa.band77.fr1.273PRB.2x2.usrpn300.conf –sa –usrp-tx-thread-config 1 -E –continuous-tx`


#### COTS UE


For COTS UE connection and perfomance tips rely on: [this tutorial](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/NR_SA_Tutorial_COTS_UE.md)


#### FlexRIC

- You can check the logs of the FlexRIC controller with this command:

```
systemctl status flexric.service
```

- You can access the xapp libraries within this directory in your RAN node:

```
cd /root/flexric/build/examples/xApp
```

and run you xapp.

- You can simply uninstall the blueprint deployment (OAI CORE and FLEXRIC) by simply run this playbook:

```
ansible-playbook  -i inventories/UTH destroy-bm-oai-flexric.yaml
```
