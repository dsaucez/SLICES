# Network interface names unificaiton

To ease experiments we provide interface aliases to users on the compute nodes.
The aliases are such that on any compute, the different networks are always
directly reached via an interface with an explicit name (e.g., `p4-net` for the
p4 network).

To create the aliases, we use the Netbox inventory. 

You have to specify the 3 following variables:

* `netbox_server`
* `netbox_port`
* `netbox_token`

that correspond to the server address, the server port from which Netbox is
reachable, and the authentication token to be used to access the server.

The first two are defines in `vars/main.yaml` as they are not critical. On the
contrary, as the token is a critical information, it is defined in
`vars/secrets.yaml` that should be an Ansible vault (e.g., created with
`ansible-vault create secret.yaml`).

Netbox may not be reachable directly from the Ansible orchestrator but you can
create an SSH tunnel to solve this issue, for example:

```bash
ssh -i /workspaces/SLICES/sopnode/ansible/id_rsa_silecs -A -L 12345:127.0.0.1:8000 root@sopnode-z1.inria.fr
```

In this case, `netbox_server=localhost`, `netbox_port=12345`.

Once vars are setup accordingly, you can create the network aliases as usual
from the root directory:

```bash
ansible-playbook  -i inventories/sopnode_tofino/ network.yaml --extra-vars "@params.sopnode_tofino.yaml" --ask-vault-pass
```