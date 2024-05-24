# Launch common core + Inria slice

All commands to be run from `sopnode/ansible` directory (i.e., `../../../../../`)

To simplify deployment, it is performed from within a dedicated docker
container that we call the *deployment environement* in this document.

## Configure cluster, core and RAN

As usual, edit the parameters contained in directory `params/vwall/`. Helm
charts are located in `roles/5g/files/blueprint/v2.0.1_vwall/`. Edit the
helm charts to correspond to your need.

In addition, confirugre the inventory to correspond to your setup, the
inventory is in `inventories/blueprint/vwall/`.

## Prepare the deployment environment

Build the deployment docker image that contains Ansible and all required
dependencies with the following command:

```
docker build -t blueprint -f Dockerfile .
```

Then start the container. First, make sure you have access to the private key
that is used to connect to the nodes composing the cluster.

Assuming that this key is saved in `${HOME}/.ssh/id_rsa` run the following
command to start a container that has

```
docker run -it -v "$(pwd)":/blueprint -v ${HOME}/.ssh/id_rsa:/id_rsa_blueprint blueprint
```

By now you are in the container

### Setup cluster

From within the deployment environement

```
ansible-playbook -i inventories/blueprint/vwall k8s-master.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
ansible-playbook -i inventories/blueprint/vwall k8s-node.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
ansible-playbook -i inventories/blueprint/vwall k8s-metallb.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
```

### Common core

From within the deployment environement
```
ansible-playbook -i inventories/blueprint/vwall 5g.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
```

### UPF

From within the deployment environement
```
ansible-playbook -i inventories/blueprint/vwall 5g.yaml --extra-vars "@params/vwall/ran-upf.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml" 
```

### RAN

From within the deployment environement
```
ansible-playbook -i inventories/blueprint/vwall 5g.yaml --extra-vars "@params/vwall/ran.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
```
