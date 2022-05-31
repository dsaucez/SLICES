## Install dependencies
```bash
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install cloud.common
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.crypto
ansible-galaxy collection install community.general
ansible-galaxy collection install community.docker
```

## Run playbooks

Create a k8s cluster:
```bash
ansible-playbook  -i inventory.yaml k8s-master.yaml --extra-vars "@params.yaml"
```

Add nodes to the k8s cluster:
```bash
ansible-playbook  -i inventory.yaml k8s-node.yaml --extra-vars "@params.yaml"
```

Deploy a docker registry in the k8s cluster:

```bash
ansible-playbook  -i inventory.yaml registry.yaml --extra-vars "@params.yaml"
```

Deploy ONOS:
```bash
ansible-playbook  -i inventory.yaml onos.yaml --extra-vars "@params.yaml"
```

Add switches to the fabric
```bash
ansible-playbook  -i inventory.yaml fabric-switch.yaml --extra-vars "@params.yaml"
```

Deploy stratum on switches
```bash
ansible-playbook  -i inventory.yaml stratum.yaml --extra-vars "@params.yaml"
```