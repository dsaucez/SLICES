# Netbox

## Installation

Let's start Netbox as docker container.

First, retrieve docker Netbox.

```bash
git clone https://github.com/netbox-community/netbox-docker.git
cd netbox-docker/
```

Then, start it with docker compose
```bash
docker-compose up
```

Assuming Netbox is running, it can be used as source of trust for Ansible.

Install Python dependencies

```bash
pip3 install -r local-requirements.txt
```

and the Ansible Netbox collection

```bash
ansible-galaxy collection install netbox.netbox 
```

## Save data

Netbox being the source of truth it is recommended to backup it. The `backup.sh` file does it.

It can be added in the cron (e.g., `0 * * * * /root/netbox/backup.sh`).

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
