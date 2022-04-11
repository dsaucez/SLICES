## Install dependencies
```bash
ansible-galaxy collection install ansible.posix
```

## Run playbooks

```bash
ansible-playbook  -i inventory.yaml k8s.yaml --extra-vars "@params.yaml"
ansible-playbook  -i inventory.yaml stratum.yaml --extra-vars "@params.yaml"
ansible-playbook  -i inventory.yaml onos.yaml --extra-vars "@params.yaml"
```