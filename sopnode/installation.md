# Instructions to run fabric-tna with SDE 9.7.0

## ONL
### Install ONL on the switch
Download https://github.com/opennetworkinglab/OpenNetworkLinux/releases/download/v1.4.3/ONL-onf-ONLPv2_ONL-OS_2021-07-16.2159-5195444_AMD64_INSTALLED_INSTALLER 
locally.

Then copy it to fedora-serv in the EdgeCore image directory

```bash
scp ~/Downloads/ONL-onf-ONLPv2_ONL-OS_2021-07-16.2159-5195444_AMD64_INSTALLED_INSTALLER fedora-serv.inria.fr:/var/www/html/pub/inria/proj/diana/sopnode/edgecore/images/
```

From `srv-diana`, connect to the switch via the drac (e.g., sw2) with credentials `admin/admin`

```bash
ssh -F /dev/null admin@sopnode-sw2-drac.inria.fr
```

Reboot the switch to enter ONIE

Install the ONL image:

```bash
onie-nos-install http://fedora-serv/pub/inria/proj/diana/sopnode/edgecore/images/ONL-onf-ONLPv2_ONL-OS_2021-07-16.2159-5195444_AMD64_INSTALLED_INSTALLER
```

After some time ONL should be installed and the switch reboots by itself.

Once the switch is started, add your public key for ssh key authentication (default credentials are `root/onl`).
```bash
ssh-copy-id -i .ssh/id_rsa_silecs root@sopnode-sw2-eth0
```

Now you can connect to the switch `ssh -i .ssh/id_rsa_silecs root@sopnode-sw2-eth0`).

Install required dependencies

```bash
apt update -y
apt install -y git
apt install -y conntrack
apt install -y python-pip
pip install docker
```

## k8s
### Install k8s on the switch


```bash
apt install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt update -y
apt install -y kubectl kubeadm kubelet
```

> **NOTE:** ONL is based on Debian Stretch, however Google doesn't provide recent debian packages for this release. Hence the use of the Ubuntu Xenial package instead as it works perfectly fine on Debian Stretch. If you wan to manually install k8s, follow [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/) instructions.

Kubelet looks up in `/run/systemd/resolve` but it doesn't exist as-is in ONL, according to [https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/issues/30](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/issues/30) the fix is:
```bash
 ln -s /run/resolvconf/ /run/systemd/resolve
 ```

### Join the cluster
Edit `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf` to add `--cgroup-driver=cgroupfs` in the `KUBELET_CONFIG_ARGS` arguments.

The file should look like:

```
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml --cgroup-driver=cgroupfs"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

```bash
mkdir -p /var/lib/kubelet/
mkdir -p /etc/kubernetes/manifests
```

Join the cluster with
```bash
kubeadm join sopnode-w2.inria.fr:6443 --token <TOKEN-DATA> --discovery-token-unsafe-skip-ca-verification
```

Make a kubectl config file, e.g., in `~/admin.yaml` with the following content:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <CERTIFICATE-AUTHORITY-DATA>
    server: https://sopnode-w2.inria.fr:6443
  name: devel
contexts:
- context:
    cluster: devel
    namespace: oai5g
    user: kubernetes-admin
  name: kubernetes-admin@devel
current-context: kubernetes-admin@devel
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: <CLIENT-CERTIFICATE-DATA>
    client-key-data: <CLIENT-KEY-DATA>
```

And use this config while running `kubectl` by setting the `KUBECONFIG` environement variable to point to the file, e.g., `export KUBECONFIG=~/admin.yaml`.

Listing the nodes in the cluster (`kubectl get node`) should work.

### Configure switch

To identify the switch as a switch in the cluster, put a label.

```bash
kubectl label node sopnode-sw2-eth0 node-role.kubernetes.io=switch
```

Avoid the switches to be used in k8s scheduling with
```bash
kubectl taint nodes sopnode-sw2-eth0 node-role.kubernetes.io=switch:NoSchedule
```

## Stratum
```bash
echo "vm.nr_hugepages = 128" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
mkdir /mnt/huge
mount -t hugetlbfs nodev /mnt/huge
```

In a separate terminal
```bash
cd /root
git clone https://github.com/stratum/stratum.git
cd stratum
git checkout e2640fc

export SDE_VERSION=9.7.0
stratum/hal/bin/barefoot/docker/start-stratum-container.sh -enable_onlp=false -bf_switchd_background=false -experimental_enable_p4runtime_translation -incompatible_enable_bfrt_legacy_bytestring_responses
```

If the chassis is not detected correctly then use the `CHASSIS_CONFIG` environement variable to explicity state the chassis configuration to be used (here below the config for a Wedge100bg-32x) and then start stratum as above.
```bash
export CHASSIS_CONFIG=/root/stratum/stratum/hal/config/x86-64-accton-wedge100bf-32x-r0/chassis_config.pb.txt
```


## ONOS
```bash
docker run --rm --tty --detach --publish 8181:8181 --publish 8101:8101 --publish 5005:5005 --publish 830:830 --name onos onosproject/onos:2.7.0
```

Once ONOS is started, tunnel to the GUI
```bash
ssh -A -i ~/.ssh/id_rsa_silecs -L 8181:localhost:8181 root@sopnode-sw2-eth0.inria.fr
```
and access the GUI via your browser: `http://localhost:8181/onos/ui/login.html` with credentials `onos/rocks`.

To access ONOS CLI: `ssh -p 8101 onos@localhost` with the same credentials `onos/rocks`.

Activate Barefoot drivers and segment routing, e.g., via the ONOS CLI with

```bash
onos@root > app activate org.onosproject.drivers.barefoot
```

## SD-Fabric

Download SDE 9.7.0 from 
`https://www.intel.com/content/www/us/en/secure/confidential/collections/programmable-ethernet-switch-products/p4-suite/p4-studio.html?wapkw=P4%20studio&s=Newest`.

assuming that the tar ball is called `bf-sde-9.7.0.tgz`, create the following dockerfile

```Dockerfile
FROM ubuntu:18.04
ADD bf-sde-9.7.0.tgz .
WORKDIR bf-sde-9.7.0/p4studio
RUN ./install-p4studio-dependencies.sh
RUN ./p4studio profile apply ./profiles/all-tofino.yaml
ENV PATH="/bf-sde-9.7.0/install/bin/:${PATH}"
```

and build the docker image with
```bash
docker build  -t p4-studio -f Dockerfile .
```

This image is required for compiling P4 pipelines as it runs in docker.

```bash
git clone https://github.com/stratum/fabric-tna.git
cd fabric-tna/
git checkout 126aba9
```

Edit `tofino-netcfg.json` to become
```json
{
  "devices": {
    "device:sopnode-sw2": {
      "basic": {
        "managementAddress": "grpc://138.96.245.12:9559?device_id=1",
        "driver": "stratum-tofino",
        "pipeconf": "org.stratumproject.fabric.montara_sde_9_7_0"
      }
    },
    "device:sopnode-sw1": {
      "basic": {
        "managementAddress": "grpc://138.96.245.11:9559?device_id=1",
        "driver": "stratum-tofino",
        "pipeconf": "org.stratumproject.fabric.montara_sde_9_7_0"
      }
    },
    "device:sopnode-sw3": {
      "basic": {
        "managementAddress": "grpc://138.96.245.13:9559?device_id=1",
        "driver": "stratum-tofino",
        "pipeconf": "org.stratumproject.fabric.montara_sde_9_7_0"
      }
    }
  }
}
```

```bash
export ONOS_HOST=localhost
```

```bash
export SDE_VERSION=9.7.0
export SDE_DOCKER_IMG=p4-studio
make fabric
make pipeconf
make build PROFILES="fabric"
```

```bash
make pipeconf-install
make netcfg
```

> ### Container base compilation for fabric-tna building
> It is possible to compile fabric-tna from a container instead of from the host. The trick is to make the container use the host's docker engine and so to use the same absolute path inside the container and outside the container (in the example below we use `/tmp/XXX`)
> 
>```Dockerfile
>FROM ubuntu:20.04
>RUN apt update -y
>RUN apt install -y docker.io nano build-essential git curl
>```
>
>```bash
>docker build -t ubuntu-dev:20.04 -f Dockerfile .
>```
>
>Launch the container
>```bash
>docker run -v /var/run/docker.sock:/var/run/docker.sock -v /tmp/XXX/:/tmp/XXX -e ONOS_HOST=<ONOS_HOST_IP> --rm -ti ubuntu-dev:20.04
>```
>
>Go to `/tmp/XXX` directory and then compile as above.


## HELP
### Useful debug commands
* `journalctl -u kubelet`
* `systemctl stop kubelet`
* `kubectl get node -o custom-columns=NAME:.metadata.name,TAINT:.spec.taints`
* `kubectl get nodes -lnode-role.kubernetes.io=switch`
* `kubectl get nodes -o wide`
* `docker exec -it <stratum container name or ID> attach-bf-shell.sh`
* `kubectl exec --namespace onos-ns --stdin --tty pod-5cbf84749f-79ztg  -- bash`
* Read ONOS logs: run the `log:tail` command in the ONOS CLI
* `pipeconfs` command in the ONOS CLI

### APIs
Configure network in ONOS via the REST API `http://localhost:8181/onos/v1/network/configuration/` with credentials `onos/rocks` (for posting a configuration, use `POST` method and `application/json` content type).

Simple 
```json
{
  "devices" : {
    "device:sopnode-sw2" : {
      "segmentrouting" : {
        "ipv4NodeSid" : 101,
        "ipv4Loopback" : "138.96.245.12",
        "routerMac" : "00:90:fb:6e:5e:e4",
        "isEdgeRouter" : true,
        "adjacencySids" : []
      },
      "basic" : {
        "name": "sopnode-sw2",
        "managementAddress": "grpc://138.96.245.12:9339?device_id=1",
        "driver": "stratum-tofino",
        "pipeconf": "org.stratumproject.fabric.montara_sde_9_5_0"
      }
    }
  }
}
```


The following example (`kubectl apply -f <filename.yaml>`) avoids the pod to be deployed on the switches.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: compute-pod
spec:
  containers:
  - name: nginx
    image: nginx
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-role.kubernetes.io
            operator: NotIn
            values:
            - switch
  containers:
  - name: compute-srv
    image: nginx
    ports:
    - containerPort: 80
```

The following example ensures that the pod is deployed on the switches.

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: switch-pod
spec:
  containers:
  - name: nginx
    image: nginx
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: node-role.kubernetes.io
            operator: In
            values:
            - switch
  containers:
  - name: switch-srv
    image: nginx
    ports:
    - containerPort: 80
    ```