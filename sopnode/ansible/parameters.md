## Container runtime configuration

| variable | type | optional | comment |
|---|---|---|---|
|`docker.registry_mirrors`| list of URL| x| list docker registry pull through cache (see https://docs.docker.com/docker-hub/mirror/)|

## Kubernetes cluster

| variable | type | optional | comment |
|---|---|---|---|
|`k8s.runtime`| string | | container runtime to use, only docker is supported [choice:`{docker}`] |
|`k8s.podSubnet`| ip prefix | | subnet used by Kubernetes pods |
|`k8s.serviceSubnet`| ip prefix | | subnet used by Kubernetes services |
|`k8s.dnsDomain`|  domain name | | DNS domain used by Kubernetes services |
|`k8s.controlPlaneEndpoint`| string | x | address to use to interract with Kubernetes control plane. Needed when in high availablitly (see https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/)|
|`k8s.apiserver_advertise_address`| ip | x| IP address on which Kubernetes API is advertised (must be reachable by all nodes of the cluster) |
| `k8s.calico` | dict | x | calico configuration (see https://docs.tigera.io/calico/latest/networking/ipam/ip-autodetection) |
| `k8s.encapsulation`| string | | type of encapsulation between pods, only VXLAN is supported [choice:`{VXLAN}`]|

## 5G configuration

| variable | type | optional | comment |
|---|---|---|---|
|`GCN.namespace` | string | | name of the blueprint where GCN is deployed |
|`GCN.core.present` | boolean | | deploy NG Core|
|`GCN.core.custom_values` | path | x | directory where to get custom charts* |
|`GCN.RAN.present`| boolean | | deploy RAN |
|`GCN.RAN.custom_values:`| path | | directory where to get custom charts* |
|`GCN.RAN.split.f1` |boolean| x| split RAN with F1 interface [default=`false`] |
|`GCN.RAN..split.e1`|boolean| x| split RAN with E1 interface [default=`false`] |
|`GCN.UE.present`| boolean |  | deploy user equipement |
|`GCN.UE.tests.landmark_ping.landmark` | ip address | | IP address to test|

The 5G core and RAN are implemented with OpenAirInterface and deployed with
helm charts. `GCN.core.custom_values` and `GCN.RAN.custom_values` allow to
overwrite the charts and values with custom ones. They correspond to the
`charts/oai-5g-core` diretory and the `chats/oai-5g-ran` directory of *oai-cn5g-fed* repository (see https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git).

## Notes
Parameters overwrite Ansible inventories variables and defaults.