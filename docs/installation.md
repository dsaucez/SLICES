# Instructions to run fabric-tna with SDE 9.7.0

## ONL
### Install ONL on the switch
Download https://github.com/opennetworkinglab/OpenNetworkLinux/releases/download/v1.4.3/ONL-onf-ONLPv2_ONL-OS_2021-07-16.2159-5195444_AMD64_INSTALLED_INSTALLER 
locally.

Then copy it to fedora-serv in the EdgeCore image directory

```bash
scp ~/Downloads/ONL-onf-ONLPv2_ONL-OS_2021-07-16.2159-5195444_AMD64_INSTALLED_INSTALLER fedora-serv.inria.fr:/var/www/html/pub/inria/proj/diana/sopnode/edgecore/images/
```

From `src-diana`, connect to the switch via the drac (e.g., sw2) with credentials `admin/admin`

```bash
ssh -F /dev/null admin@sopnode-sw2-drac.inria.fr
```

Reboot the switch to enter ONIE

Install the ONL image:

```bash
onie-nos-install http://fedora-serv/pub/inria/proj/diana/sopnode/edgecore/images/ONL-onf-ONLPv2_ONL-OS_2021-07-16.2159-5195444_AMD64_INSTALLED_INSTALLER
```

After some time ONL should be installed and the switch reboots by itself.

Connect to the switch with credentials `root/onl` (e.g., `ssh -i .ssh/id_rsa_silecs root@sopnode-sw2-eth0`).


## k8s
### Install k8s on the switch

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

Add the line `apiVersion: kubelet.config.k8s.io/v1beta1` to `/var/lib/kubelet/config.yaml`. If the file does not exist, create it.

Reload daemon
```bash
systemctl daemon-reload
```

Join the cluster with
```bash
kubeadm join 138.96.245.50:6443 --token nq9tul.5lcfspkhhit6slbf --discovery-token-ca-cert-hash sha256:13cd02b6d960bd53ae6de4c9d2f1d0e0e32c12e1fd40e06db977d89a0d4267b4 --v=5
```

Make a kubectl config file, e.g., in `~/admin.yaml` with the following content:

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1ERXlOekUwTURBMU0xb1hEVE15TURFeU5URTBNREExTTFvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTTlBCjM4RHpXaHdKMHh2c2h0OW52SnFiSnRxc1lseEJSQUpUMHlhSDNDYWVhOGZNdWRMQXlweGZjemQ5LzliR09FRFAKMFJDTHpGM1NtaHhDdEk0aGlkYWlyVmZIZlFBay9PRVAxbWZLcWhxYzd4Zmw5OTdwU3MzUHIvSjdiQzdxL3dHZgpyOVVWVkVuSmxHLzBkUllLZDJUVXN0MEdBeHRFR1RqTkZZMlhZLzdMK0lvTkd1TUVwd1VzVVlLWXgxenlKOFZ5CkxnVFdnc1VmdUovMldpaFZCOEFzTTVYYkJtdGJKNUw3bzBqSlhnc1UxSzRPUjVta04rOFp3MzBYaGx0dllxT2QKOWgyamNXYWl3aVBGRlhENVhSTWxVN2kyMmRIRzNqMlo3QVJDelEyKzhXRnNoZmZsN25rQ3hKdGdIUExTNmxmRgpuVjdRcWM4VVlWSEFqN2twUEJVQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZQYmlkK3AzaW84RkpUaE9jdjF5RHM5TUNKZ3JNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBSSsxc3BCQVZZOTVmdUFsaElsWQpnT0M5Y21rYmJyakVkV1F0ZzErenhNVHhNOWhPYUZOL2xXMWF3bUJXNFJLMkppaStLemsvQ3VhU1F6UjJlZEhhCjVYQ2Nua0F6NVcvR3ZmeEFOZHp2R2lDQlhEZm44OEpPL0dIMk1rOEMrQzNYV3VReVBQaE9MTVRNN3NOcjhpbHEKU29tMFBmWFhjN2FMcXg0Q3Nyd09QdlJ1QklUSlNoV0s0OGRLM256WHZZaTFZYmoreXdLRU4xS095TmVnbTREdgpIZ1NhS1NiUkxBRjdjbllWYWJ0azhYQkwzZ1RYWnlCanBYai9pUENCWXpVSDNBSTFycUp1RzNnbU5DcnhPb0VTClg0OG5Pdk8yMnhoUm5pM1p4NnBXV2xqME4xeGIzWmRoVXl2dXRLc3Y0SUlRNUppN05ic0FlYkNtTWs2SWJiamQKM0pRPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://138.96.245.50:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJVENDQWdtZ0F3SUJBZ0lJTjljdVZ6WEVHMVV3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TWpBeE1qY3hOREF3TlROYUZ3MHlNekF4TWpjeE5EQXdOVFJhTURReApGekFWQmdOVkJBb1REbk41YzNSbGJUcHRZWE4wWlhKek1Sa3dGd1lEVlFRREV4QnJkV0psY201bGRHVnpMV0ZrCmJXbHVNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTFkNWxkYzlIK2RqeEJydkYKT2MzaE02SVA0OGQwUXFFMWdQY2pyZzU0Nk04blFCSEoyS3krKzE5aGtkUVlUbnExbTA0NWM0NnNLSkdJcE1xUQo2UEswZ2tOMDk3eFhvNFE5V3pvRldJYjNBZXNRYmw4SGtSL2NOVjNBODVvVHZVM1VKZzZzTXY5bTNodDJzSWV3Ck1aNDBCaTBmRzc4WG5McHorUVNJYldaNzJuUkdqVThXdDlUdmVFM3E0dVdTdExIMzhreFpCclgvc21IY0hXK0YKR24rWVBHWitzOHdtYnBnS3VGcjRBSEp1MkpaclU4cktBQUpmbzhXMWxxM0tKMzR3K1YybUUzNndLbXUya0dJWgowYWNpdGVBSEQ3dWtzc3RKR3gxYms2bFNJQzhjWTBMSzd6K0dEcExLNSsvV1VjL3Y0R0xCd2dTVWhDYzF1dzZKCkJQRStDd0lEQVFBQm8xWXdWREFPQmdOVkhROEJBZjhFQkFNQ0JhQXdFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUgKQXdJd0RBWURWUjBUQVFIL0JBSXdBREFmQmdOVkhTTUVHREFXZ0JUMjRuZnFkNHFQQlNVNFRuTDljZzdQVEFpWQpLekFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBaktrNmJLYUpOMC9vYldXVFp4VkdHZHdOaTF4K05qOEF1cmhkCk16SW1xVkI2bFJnUDhWTnZTTnpxcExMMi9MNXRqWUR0ZmNWby8zTW9NK2FmTTVmVXNzZ2F0cFJDd1dwMXhDdE8KYVNPS1FCajNyQzhLdnIwY3p1R1hwZXprNVFrSC93THlsRm16NXdTdDdvRmVpS1VzY2dmK2kwZXladDZnVGRVZApFQi8rbGx3UHBvS1IyaHVzWEtUQmtJUTZuRUQ5SnhVUGVybVVmT0lHb3hzRGhBMWdoRnUxdEsxU09kVXB1a053CmNOcXdnUEgvUzl1M0JCSUpZYytDZUtqKzB1WXowTmluVmtjSTRJY0V6WXk4RVZ4T3hYT0YrYitwSU96ZVY4Vk8KcDlycDZ0WS9DeFh4U3JNZkUxM2M4bEhPOXlVNENkenI4cFF5NjR4all2Ty9ZSTMzOEE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBMWQ1bGRjOUgrZGp4QnJ2Rk9jM2hNNklQNDhkMFFxRTFnUGNqcmc1NDZNOG5RQkhKCjJLeSsrMTloa2RRWVRucTFtMDQ1YzQ2c0tKR0lwTXFRNlBLMGdrTjA5N3hYbzRROVd6b0ZXSWIzQWVzUWJsOEgKa1IvY05WM0E4NW9UdlUzVUpnNnNNdjltM2h0MnNJZXdNWjQwQmkwZkc3OFhuTHB6K1FTSWJXWjcyblJHalU4Vwp0OVR2ZUUzcTR1V1N0TEgzOGt4WkJyWC9zbUhjSFcrRkduK1lQR1orczh3bWJwZ0t1RnI0QUhKdTJKWnJVOHJLCkFBSmZvOFcxbHEzS0ozNHcrVjJtRTM2d0ttdTJrR0laMGFjaXRlQUhEN3Vrc3N0Skd4MWJrNmxTSUM4Y1kwTEsKN3orR0RwTEs1Ky9XVWMvdjRHTEJ3Z1NVaENjMXV3NkpCUEUrQ3dJREFRQUJBb0lCQVFDbG1DV0hLby9ZYkpsegpWVUJJbVppZG1nWWpuL1B0QTFXaUhibUtzN242eVNyaStPTUkyZmltT2h3YUJkY3NMT2NnOFZpYW1RWEVBNnVCCnJUYTJwL1lNUnA3eWt1cG91YU9vVnl4OGQwUWFRQi9nMWNQT0lwVW0zUWpobFpOaktEZnpuN2pGWSt3S1hjbHcKdGg4K3kvZ01NRE8rRUNBQVFuNDVlY0VJdENtQjRzcGhGYUlmaU1XMjRJNVR5b3BieTVYdEZJVjRTdjkvLzlVWgphTWpmS3pPK2dMc1o5bGRFRXpPdU56R0UxUFQ5ZnRYR3RzdG1ydDUwS1JKVkErM0ZGN3QvYTMrQjcxY2YwNjFuClAvd1Q1eWo4OStWTXVlZFhhNmdaVWRPaTRONkh0cXFxL2pZSFBSRXpIcDJtcjZoMUM2WklGeGRiSkswK2toM2oKUUdNY0FmMUJBb0dCQU5aakZSc0ptczE3c2w4RlMzWTcweEx5TG00aThjVmI3dFBibS80L3dib2FaeUd4eEQ2MwpuYzZSUHFPNE50QysyYU9hUUxvWmhhdVpsbTZwQ2IyWWZwbVphUXpnRGFFenErRHhxelZzRVV0SThFQnVWeXlwCi9kemlhY0dXMUhIMlBJc1NnKzRPam1pZ05GaDhaelBybjZRZ2d2NzFraWRYUEl4ZU9nRDZzS0YvQW9HQkFQOWgKanlwdVhTTm1ybFBkZWY2Uy9sM0FxTkpvV0U3STZZQjdUdzQ0WlRsQmZ1UWVKM1hFa1BBNndFK2UyaG1Xak1hNgpaM2FndkFxdEhrRERVQUd5WGFxTXdtL2l4TmJlVVZnZ3IxNVg3Vy9zVG56emZOTlNIdFNHaTVTT1E2ZTlDQkUwCnhhTldocDAvb2pUaXNEczNlTmhzZHQ2WVVwUzJHZ1ZsTzlITGdoRjFBb0dBZDNaWTRXc1Z0dUR4d1I4ck1LUWYKZHhRNnFTYVJ3Sjc4MDFNeGRwakNjOWlZbFY4QWNzNVFnalhQU04yeXRkbFRYMlhxSVlsdFFmVGdyYU5HQ1Q4NwpkSTNXeXRUaTQydnVuL2NxcHljajcrYWg4ZFZLZ0ZudFd6TlRLUXZLTUFLOU0rWEtYRklDS3V6eW5rZ2NIZ056ClBycmJKQVZsUHNUT3VZMGNGMFdhUFRNQ2dZRUE1REdJZTZHaUY3L29oWWVoT3BpZU1hZTFNazJLbXR0cnlpSmsKd1pBaTRzWmpXL0tWeitXVW5SUGlRMEx1SDI4bTIydzBod3VZK3ZFMTF5aXVsTldNWEpqcUpJKzgwMEpUN1N0SAppRVdKSkRsQzZPT281aXE2NGF4WGpLYVNUWS9iWllTQ0ZURjdsNGNFcWJ6bFBBU1ZOczIwYWJJeUdDK2ZrTEtrCmdSSVhad0VDZ1lCQ1VWZXlJUzY4L0ZLaXh6bjI2c2xpaEhYQVdMdW1YWWZKSDJRUXprOHB4Mm92YmdRZWljNXoKWE9IaFdDMU4zYjUzMkpDNmxURVNKdWFvM2UwY1ZTek0yL3dSUHN6SUE2dkwxS2NCVFhKY2xydzRXaGI4Z1V0bApPb2NrSXh4MFk2WnVMN2E3YkNYUGZsbEVpbjROYUFGd2Nnd3R6OCsrWlBJbHBvakZGZHBrWHc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=
```

And use this config while running `kubectl` by setting the `KUBECONFIG` environement variable to point to the file, e.g., `export KUBECONFIG=~/admin.yaml`.

Listing the nodes in the cluster (`kubectl get node`) should work.


### Configure switch
```bash
kubectl label node sopnode-sw2-eth0 node-role.kubernetes.io=switch
```

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
export CHASSIS_CONFIG=/root/stratum/stratum/hal/config/x86-64-accton-wedge100bf-32x-r0/chassis_config.pb.txt
stratum/hal/bin/barefoot/docker/start-stratum-container.sh -enable_onlp=false -bf_switchd_background=false -experimental_enable_p4runtime_translation -incompatible_enable_bfrt_legacy_bytestring_responses
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
    }
  }
}
```

```bash
export SDE_VERSION=9.7.0
export SDE_DOCKER_IMG=p4-studio
make fabric
make pipeconf
make build PROFILES="fabric"
```

```bash
make pipeconf-install ONOS_HOST=localhost
make netcfg ONOS_HOST=localhost
```

## HELP
### Useful debug commands
* `journalctl -u kubelet`
* `systemctl stop kubelet`
* `kubectl get node -o custom-columns=NAME:.metadata.name,TAINT:.spec.taints`
* `kubectl get nodes -lnode-role.kubernetes.io=switch`
* `kubectl get nodes -o wide`
* `docker exec -it <stratum container name or ID> attach-bf-shell.sh`
* Read ONOS logs: run the `log:tail` command in the ONOS CLI
* `pipeconfs` command in the ONOS CLI

## BACKUP
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