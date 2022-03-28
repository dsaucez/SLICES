# OAI 5G Deployment on sopnode-l1

Steps required to run OAI 5G on our F35 k8s cluster.

Relevant OAI documentation:

- [https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY\_SA5G\_HC.md](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_SA5G_HC.md) 

Nota: Eurecom folks advise to run the pods as regular users, not as root  as it is safer. 
TBD: Check if we can let our k8s cluster visible for all users.

## Retrieve the OAI CN5G release.

- `git clone https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git`
- `cd oai-cn5g-fed/`
- `git switch update-charts`

## Prerequisites

Following installations should be appended later to our k8s cluster creation

### Helm installation

- `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`
- `chmod 700 get_helm.sh`
- edit `get_helm.sh` to set `HELM_INSTALL_DIR` to `/bin` instead of `/usr/local/bin`
- `./get_helm.sh`
- `helm repo add bitnami https://charts.bitnami.com/bitnami`
- `helm repo update`

### Multus installation

- `mkdir multus; cd multus; git clone https://github.com/k8snetworkplumbingwg/multus-cni.git && cd multus-cni`
- `cat ./deployments/multus-daemonset-thick-plugin.yml | kubectl apply -f - `

### k8s PersistentVolume creation
A PersistentVolume is required for the OAI 5G mysql database pod.

Run the following `pv-mysql.yaml` config (located in `oai-cn5g-fed/charts/mysql/pv-mysql.yaml`): 

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-volume
  labels:
    type: local
spec:
  storageClassName: local-storage
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```
- `kubectl apply -f pv-mysql.yaml`

## OAI CN5G Configuration

First, configure the 3 following pods for our R2lab deployment.


### 1/ mysql pod configuration

Edit chart/mysql/values.yaml manifest:
- modify:
``` 
persistence:
  enabled: false
provisioning
  storageClass: local-storage
```

- add new SIM cards information in the *AuthenticationSubscription* table, e.g. for SIM01:
```

    INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
    ('208950000000001', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', '8e27b6af0e692e750f32667a3b14605d', NULL, NULL, NULL, NULL, '208950000000001');
```

### 2/ oai-amf pod configuration

Edit chart/oai-amf/scripts/amf.conf:

```
  GUAMI:
  {
    MCC = "208"; MNC = "95"; RegionID = "128"; AMFSetID = "1"; AMFPointer = "1" # YOUR GUAMI CONFIG HERE
  }
  
  SERVED_GUAMI_LIST = (
    {MCC = "208"; MNC = "95"; RegionID = "128"; AMFSetID = "1"; AMFPointer = "0"}, #48bits <MCC><MNC><RegionID><AMFSetID><AMFPointer>
  );
  
  PLMN_SUPPORT_LIST = (
  {
    MCC = "208"; MNC = "95"; TAC = 0x0001;  # YOUR PLMN CONFIG HERE
    SLICE_SUPPORT_LIST = (
      {SST = "1"; SD = "010203"},  # YOUR NSSAI CONFIG HERE
      {SST = "1"; SD = "112233"}   # YOUR NSSAI CONFIG HERE
    )
  }
  );
  
  AUTHENTICATION:
  {
    ## MySQL mandatory options
    MYSQL_server = "mysql"; # MySQL Server address
    MYSQL_user   = "root";   # Database server login
    MYSQL_pass   = "linux";   # Database server password
    MYSQL_db     = "oai_db";     # Your database name

    ## OP
    OPERATOR_key = "8e27b6af0e692e750f32667a3b14605d"; # OP key matching your database
    RANDOM = "true";
  };  
```

### 3/ oai-smf configuration

Edit chart/oai-amf/scripts/smf.conf:

```
    # DNS address communicated to UEs
    DEFAULT_DNS_IPV4_ADDRESS     = "138.96.0.10";  # YOUR DNS CONFIG HERE
    DEFAULT_DNS_SEC_IPV4_ADDRESS = "138.96.0.11";  # YOUR DNS CONFIG HERE

```

## OAI CN5G Deployment

Assumption: mysql-volume PersistentVolume is available on the k8s cluster, you can check with `kubectl get pv`


- `kubectl create ns oai5g; kns oai5g`
- `cd oai-cn5g-fed/charts`

You can deploy automatically all CN5G pods with:

- `helm_chart.sh install oai5g`

Or you can deploy them manually with  (optional :

```
$ helm install mysql mysql/
# wait for the pod to be ready  
$ helm install nrf oai-nrf/
# wait for the pod to be ready
$ helm install udr oai-udr/
# wait for the pod to be ready
$ helm install udm oai-udm/
# wait for the pod to be ready
$ helm install ausf oai-ausf/
# wait for the pod to be ready
$ helm install amf oai-amf/
# wait for the pod to be ready
$ helm install smf oai-smf/
# wait for the pod to be ready
$ helm install upf oai-spgwu-tiny/
# wait for the pod to be ready
$ helm list 
```

To debug a deployment, use:

`helm install --debug --dry-run mysql mysql/`


To check the deployment:

```
helm list
NAME 	NAMESPACE	REVISION	UPDATED                                 	STATUS  	CHART             	APP VERSION
amf  	oai5g    	1       	2022-03-28 12:31:09.207013802 +0200 CEST	deployed	oai-amf-1.4       	1.4
ausf 	oai5g    	1       	2022-03-28 12:30:28.327699833 +0200 CEST	deployed	oai-ausf-1.4      	1.4
mysql	oai5g    	1       	2022-03-28 12:29:27.026969648 +0200 CEST	deployed	mysql-1.6.9       	5.7.30
nrf  	oai5g    	1       	2022-03-28 12:30:48.748344933 +0200 CEST	deployed	oai-nrf-1.4       	1.4
smf  	oai5g    	1       	2022-03-28 12:31:29.691626662 +0200 CEST	deployed	oai-smf-1.4       	1.4
spgwu	oai5g    	1       	2022-03-28 12:31:50.126904543 +0200 CEST	deployed	oai-spgwu-tiny-1.4	1.4
udm  	oai5g    	1       	2022-03-28 12:30:07.895105726 +0200 CEST	deployed	oai-udm-1.4       	1.4
udr  	oai5g    	1       	2022-03-28 12:29:47.477579718 +0200 CEST	deployed	oai-udr-1.4       	1.4
```

```
kubectl get po
NAME                             READY   STATUS    RESTARTS   AGE
mysql-b8bcd6b8-clxc7             1/1     Running   0          3h16m
oai-amf-5b8885b85c-tp7dw         2/2     Running   0          3h14m
oai-ausf-7db8b57469-frp8b        2/2     Running   0          3h15m
oai-nrf-6c44cf77d4-b9kc6         2/2     Running   0          3h14m
oai-smf-7dcfcbdb9c-2lsjq         2/2     Running   0          3h14m
oai-spgwu-tiny-774fcf5f7-78958   2/2     Running   0          3h13m
oai-udm-69b75db7bf-4v9t6         2/2     Running   0          3h15m
oai-udr-55d5cb58ff-pmxkn         2/2     Running   0          3h15m
```




