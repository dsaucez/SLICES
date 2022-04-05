## Install dependencies
```bash
ansible-galaxy collection install ansible.posix
```

## Run playbooks

```bash
ansible-playbook  -i inventory.yaml stratum.yaml
ansible-playbook  -i inventory.yaml onos.yaml
```