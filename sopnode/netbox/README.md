# Netbox

Assuming Netbox is running, it can be used as source of trust for Ansible.

## Installation
First, install Python dependencies

```bash
pip3 install -r local-requirements.txt
```

and Ansible Netbox collection

```bash
ansible-galaxy collection install netbox.netbox 
```

## Examples

Show the inventory built with Netbox:

```bash
ansible-inventory -i netbox_inventory.yaml --list -y
```

Use the playbook with the inventory

```bash
ansible-playbook -i netbox_inventory.yaml simple_playbook.yaml
```

Check https://blog.networktocode.com/post/netbox_as_ansible_sot/ for a brief tutorial.
