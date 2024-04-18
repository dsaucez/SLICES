# Launch common core + Inria slice

All commands to be run from `sopnode/ansible` directory (i.e., `../../../../../`)

## Setup cluster

```
ansible-playbook -i inventories/blueprint/vwall k8s-master.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
ansible-playbook -i inventories/blueprint/vwall k8s-node.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
ansible-playbook -i inventories/blueprint/vwall k8s-metallb.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
```

## Common core

```
ansible-playbook -i inventories/blueprint/vwall 5g.yaml --extra-vars "@params/vwall/core.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
```

## UPF
```
ansible-playbook -i inventories/blueprint/vwall 5g.yaml --extra-vars "@params/vwall/ran-upf.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml" 
```

## RAN

```
iansible-playbook -i inventories/blueprint/vwall 5g.yaml --extra-vars "@params/vwall/ran.yaml" --extra-vars "@params/vwall/misc.yaml" --extra-vars "@params/vwall/k8s.yaml"
```
