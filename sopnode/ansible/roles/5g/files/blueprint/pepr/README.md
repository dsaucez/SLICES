# Launch common core + Inria slice

All commands to be run from `sopnode/ansible` directory (i.e., `../../../../../`)

## Common core

```
ansible-playbook  -i inventories/blueprint/core/  5g.yaml  --extra-vars "@params/core-common.yaml" --exra-vars "@params.pipeline.yaml" 
```

## Inria slice UPF
```
ansible-playbook  -i inventories/blueprint/core/  5g.yaml  --extra-vars "@params/ran-upf.yaml" --exra-vars "@params.pipeline.yaml" 
```

## Inria slice RAN

```
ansible-playbook  -i inventories/blueprint/core/  5g.yaml  --extra-vars "@params/ran.yaml" --exra-vars "@params.pipeline.yaml" 
```
