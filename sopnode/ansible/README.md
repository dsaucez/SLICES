## Install dependencies
```bash
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install cloud.common
ansible-galaxy collection install kubernetes.core
```

## Run playbooks

```bash
ansible-playbook  -i inventory.yaml main.yaml --extra-vars "@oai5g.params.yaml"
```

```bash
ansible-playbook  -i inventory.yaml k8s.yaml --extra-vars "@params.yaml"
ansible-playbook  -i inventory.yaml stratum.yaml --extra-vars "@params.yaml"
ansible-playbook  -i inventory.yaml onos.yaml --extra-vars "@params.yaml"
```