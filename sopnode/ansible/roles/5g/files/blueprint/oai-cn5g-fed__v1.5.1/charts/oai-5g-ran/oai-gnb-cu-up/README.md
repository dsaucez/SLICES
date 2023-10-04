# Helm Chart for OAI Central Unit User Plane (OAI-CU-UP)

Before using this helm-chart we recommend you read about OAI codebase and its working from the documents listed on [OAI gitlab](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop/doc). Here you can find a dedicated document on [F1 design](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/F1-design.md) and [E1 design](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/E1-design.md) 

**Note**: This chart is tested on [Minikube](https://minikube.sigs.k8s.io/docs/) and [Red Hat Openshift](https://www.redhat.com/fr/technologies/cloud-computing/openshift) 4.10 and 4.12. It requires minimum 1CPU and 1Gi RAM and [multus-cni](https://github.com/k8snetworkplumbingwg/multus-cni) plugin for multiple interfaces. 

## Introduction

To know more about the feature set of OpenAirInterface you can check it [here](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/FEATURE_SET.md#openairinterface-5g-nr-feature-set). 

The [codebase](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop) for gNB, CU, DU, CU-CP/CU-UP, NR-UE is the same. Everyweek on [docker-hub](https://hub.docker.com/r/oaisoftwarealliance/oai-gnb) our [Jenkins Platform](https://jenkins-oai.eurecom.fr/view/RAN/) publishes two docker-images 

1. `oaisoftwarealliance/oai-gnb` for monolithic gNB, DU, CU, CU-CP 
2. `oaisoftwarealliance/oai-nr-cuup` for CU-UP. 

Each image has develop tag and a dedicated week tag for example `2023.w18`. We only publish Ubuntu 18.04/20.04 images. We do not publish RedHat/UBI images. These images you have to build from the source code on your RedHat systems or Openshift Platform. You can follow this [tutorial](../../../openshift/README.md) for that.

The helm chart of OAI-CU-UP creates multiples Kubernetes resources,

1. Service
2. Role Base Access Control (RBAC) (role and role bindings)
3. Deployment
4. Configmap
5. Service account
6. Network-attachment-defination (Optional only when multus is used)

The directory structure

```
.
├── Chart.yaml
├── templates
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── multus.yaml
│   ├── NOTES.txt
│   ├── rbac.yaml
│   ├── serviceaccount.yaml
│   └── service.yaml
└── values.yaml
```

## Parameters

[Values.yaml](./values.yaml) contains all the configurable parameters. Below table defines the configurable parameters. The ip-addresses of N3, E1 and F1U have to be pre-configured in the configuration. Most of the primary CNIs do not allow static ip-address allocation. To overcome this we are using multus-cni with static ip-address allocation. At minimum you have to create one multus interface which you can use for N3, E1 and F1U. If you want you can create dedicated interfaces for N3, E1 and F1U. 


|Parameter                        |Allowed Values                 |Remark                           |
|---------------------------------|-------------------------------|---------------------------------|
|kubernetesType                   |Vanilla/Openshift              |Vanilla Kubernetes or Openshift  |
|nfimage.repository               |Image Name                     |                                 |
|nfimage.version                  |Image tag                      |                                 |
|nfimage.pullPolicy               |IfNotPresent or Never or Always|                                 |
|imagePullSecrets.name            |String                         |Good to use for docker hub       |
|serviceAccount.create            |true/false                     |                                 |
|serviceAccount.annotations       |String                         |                                 |
|serviceAccount.name              |String                         |                                 |
|podSecurityContext.runAsUser     |Integer (0,65534)              |                                 |
|podSecurityContext.runAsGroup    |Integer (0,65534)              |                                 |
|multus.defaultGateway            |Ip-Address                     |default route in the pod         |
|multus.n3Interface.create        |true/false                     |                                 |
|multus.n3Interface.IPadd         |Ip-Address                     |                                 |
|multus.n3Interface.Netmask       |Netmask                        |                                 |
|multus.n3Interface.Gateway       |Ip-Address                     |                                 |
|multus.n3Interface.routes        |Json                           |Routes you want to add in the pod|
|multus.n3Interface.hostInterface |host interface                 |Host machine interface name      |
|multus.e1Interface.create        |true/false                     |                                 |
|multus.e1Interface.IPadd         |Ip-Address)                    |                                 |
|multus.e1Interface.Netmask       |Netmask                        |                                 |
|multus.e1Interface.Gateway       |Ip-Address                     |                                 |
|multus.e1Interface.hostInterface |host interface                 |                                 |
|multus.e1Interface.routes        |Json                           |Routes you want to add in the pod|
|multus.f1uInterface.create       |true/false                     |                                 |
|multus.f1uInterface.IPadd        |Ip-Address                     |                                 |
|multus.f1uInterface.Netmask      |Netmask                        |                                 |
|multus.f1uInterface.Gateway      |Ip-Address                     |                                 |
|multus.f1uInterface.routes       |Json                           |Routes you want to add in the pod|
|multus.f1uInterface.hostInterface|host interface                 |Host machine interface name      |

The config parameters mentioned in `config` block of `values.yaml` are limited on purpose to maintain simplicity. They do not allow changing a lot of parameters of oai-gnb-cu-cp. If you want to use your own configuration file for oai-gnb-cu-up. It is recommended to copy it in `templates/configmap.yaml` and set `config.mountConfig` as `true`. The command line arguments for oai-gnb-cu-up is provided in `config.useAdditionalOptions`. 

You can find [here](https://gitlab.eurecom.fr/oai/openairinterface5g/-/tree/develop/targets/PROJECTS/GENERIC-NR-5GC/CONF) different sample configuration files for different bandwidths and frequencies. The binary of oai-gnb is called as `nr-softmodem`. To know more about its functioning and command line parameters you can visit this [page](https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/develop/doc/RUNMODEM.md)


### Configure CU-UP with 1 interface

Minimum you need two interfaces for e1,f1 split. It is because in CU-UP F1U and N3 bind to the same 2152 port number for GTP. 

Though you can use only 1 interface but then you need to change the port of F1U to 2153 or some other port number.

To enable choose any one of the interfaces out of three, lets say we will enable `multus.e1Interface.create`. This interface has name `e1` inside the pod.

If you want to use only one interface then you have to configure some parameters in `templates/configmap.yaml`. You can replace the below blocks with the blocks in templates/configmap.yaml

```
          local_s_if_name = "e1";
          local_s_address = "{{ .Values.multus.e1Interface.IPadd }}";
          remote_s_address = "{{ .Values.config.f1duIpAddress }}";
          local_s_portc   = 501;
          local_s_portd   = 2153;
          remote_s_portc  = 500;
          remote_s_portd  = 2153;
```

```
          NETWORK_INTERFACES :
          {
              GNB_INTERFACE_NAME_FOR_NG_AMF            = "e1";
              GNB_IPV4_ADDRESS_FOR_NG_AMF              = "{{ .Values.multus.e1Interface.IPadd }}";
              GNB_INTERFACE_NAME_FOR_NGU               = "e1";
              GNB_IPV4_ADDRESS_FOR_NGU                 = "{{ .Values.multus.e1Interface.IPadd }}";
              GNB_PORT_FOR_S1U                         = 2152; # Spec 2152
          };
```

## Advanced Debugging Parameters

Only needed if you are doing advanced debugging


|Parameter                        |Allowed Values                 |Remark                                         |
|---------------------------------|-------------------------------|-----------------------------------------------|
|start.gnbcuup                    |true/false                     |If true gnbcuup container will go in sleep mode|
|start.tcpdump                    |true/false                     |If true tcpdump container will go in sleepmode |
|includeTcpDumpContainer          |true/false                     |If false no tcpdump container will be there    |
|tcpdumpimage.repository          |Image Name                     |                                               |
|tcpdumpimage.version             |Image tag                      |                                               |
|tcpdumpimage.pullPolicy          |IfNotPresent or Never or Always|                                               |
|persistent.sharedvolume          |true/false                     |Save the pcaps in a shared volume with NRF     |
|resources.define                 |true/false                     |                                               |
|resources.limits.tcpdump.cpu     |string                         |Unit m for milicpu or cpu                      |
|resources.limits.tcpdump.memory  |string                         |Unit Mi/Gi/MB/GB                               |
|resources.limits.nf.cpu          |string                         |Unit m for milicpu or cpu                      |
|resources.limits.nf.memory       |string                         |Unit Mi/Gi/MB/GB                               |
|resources.requests.tcpdump.cpu   |string                         |Unit m for milicpu or cpu                      |
|resources.requests.tcpdump.memory|string                         |Unit Mi/Gi/MB/GB                               |
|resources.requests.nf.cpu        |string                         |Unit m for milicpu or cpu                      |
|resources.requests.nf.memory     |string                         |Unit Mi/Gi/MB/GB                               |
|readinessProbe                   |true/false                     |default true                                   |
|livenessProbe                    |true/false                     |default false                                  |
|terminationGracePeriodSeconds    |5                              |In seconds (default 5)                         |
|nodeSelector                     |Node label                     |                                               |
|nodeName                         |Node Name                      |                                               |

## How to use

0. Make sure the core network is running else you need to first start the core network. You can follow any of the below links
  - [OAI 5G Core Basic](../../oai-5g-basic/README.md)
  - [OAI 5G Core Mini](../../oai-5g-mini/README.md)
  - Check properly that the n2 and n3 ip-address are configured via multus interface because we need multiple interfaces for cu-cp and cu-up deployment. 
1. Configure the `parent` interface for `n3`, `e1` and `f1` based on your Kubernetes cluster worker nodes. 

Make sure `oai-gnb-cu-cp` is running before starting the `cu-up`

```bash
helm install oai-gnb-cu-cp ../oai-gnb-cu-cp
#wait for cu-cp to start
helm install oai-gnb-cu-up .
helm install oai-gnb-du ../oai-gnb-du 
```

### Connect the UE

1. Configure the `oai-nr-ue` charts for `oai-gnb-du`, change `config.rfSimulator` to `oai-gnb-du` and `useAdditionalOptions` to `--sa --rfsim -r 106 --numerology 1 -C 3619200000 --nokrnmod --log_config.global_log_options level,nocolor,time`. As the configuration of cu/du is set at this frequency and resource block. If you mount your own configuration file then set the configuration of nr-ue accordingly. 

```bash
helm install oai-nr-ue ../oai-nr-ue
```

2. Once NR-UE is connected you can go inside the pod and ping via `oai` interface. If you do not see this interface then the UE is not connected to gNB or have some issues at core network.

```bash
kubectl exec -it <oai-nr-ue-pod-name> -- bash
#ping towards spgwu/upf
ping -I oaitun_ue1 12.1.1.1
#ping towards google dns
ping -I oaitun_ue1 8.8.8.8
```

## Note

1. If you are using multus then make sure it is properly configured and if you don't have a gateway for your multus interface then avoid using gateway and defaultGateway parameter. Either comment them or leave them empty. Wrong gateway configuration can create issues with pod networking and pod will not be able to resolve service names.