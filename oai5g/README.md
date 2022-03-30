# OAI 5G Deployment on sopnode-l1

Steps required to run OAI 5G on our F35 k8s cluster.

Relevant OAI documentation from Sagar Arora <[sagar.arora@eurecom.fr](mailto:sagar.arora@eurecom.fr)>:

- [https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY\_SA5G\_HC.md](https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed/-/blob/master/docs/DEPLOY_SA5G_HC.md) 

Note that this code is a proof a concept and the charts are not finalized yet. An official version should be available around mi-April. These charts are based on a develop branch that is ahead of release 1.3.

## Retrieve the OAI CN5G release.

- `$ git clone https://gitlab.eurecom.fr/oai/cn5g/oai-cn5g-fed.git`
- `$ cd oai-cn5g-fed/`
- `$ git switch update-charts`

## Prerequisites

Following installations should be appended later to our k8s cluster creation

### Helm installation

- `$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`
- `$ chmod 700 get_helm.sh`
- edit `get_helm.sh` to set `HELM_INSTALL_DIR` to `/bin` instead of `/usr/local/bin`
- `$ ./get_helm.sh`
- `$ helm repo add bitnami https://charts.bitnami.com/bitnami`
- `$ helm repo update`

### Multus installation

- `$ mkdir multus; cd multus; git clone https://github.com/k8snetworkplumbingwg/multus-cni.git && cd multus-cni`
- `$ cat ./deployments/multus-daemonset-thick-plugin.yml | kubectl apply -f - `

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
- `$ kubectl apply -f pv-mysql.yaml`

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

- add R2lab SIM cards information in the *AuthenticationSubscription* table, e.g., for SIM01:

```

    INSERT INTO `AuthenticationSubscription` (`ueid`, `authenticationMethod`, `encPermanentKey`, `protectionParameterId`, `sequenceNumber`, `authenticationManagementField`, `algorithmId`, `encOpcKey`, `encTopcKey`, `vectorGenerationInHss`, `n5gcAuthMethod`, `rgAuthenticationInd`, `supi`) VALUES
    ('208950000000001', '5G_AKA', 'fec86ba6eb707ed08905757b1bb44b8f', 'fec86ba6eb707ed08905757b1bb44b8f', '{\"sqn\": \"000000000020\", \"sqnScheme\": \"NON_TIME_BASED\", \"lastIndexes\": {\"ausf\": 0}}', '8000', 'milenage', '8e27b6af0e692e750f32667a3b14605d', NULL, NULL, NULL, NULL, '208950000000001');
```

### 2/ oai-amf pod configuration

Add following chart/oai-amf/scripts/amf.conf:

```
 AMF =
{
  INSTANCE_ID = 0;            # 0 is the default
  PID_DIRECTORY = "/var/run";   # /var/run is the default

  AMF_NAME = "OAI-AMF";

  RELATIVE_CAPACITY = 30;
  # Display statistics about whole system (in seconds)
  STATISTICS_TIMER_INTERVAL = 20;  # YOUR CONFIG HERE

  CORE_CONFIGURATION:
  {
    EMERGENCY_SUPPORT = "false";
  };

  GUAMI:
  {
    MCC = "208"; MNC = "95"; RegionID = "128"; AMFSetID = "1"; AMFPointer = "1" # YOUR GUAMI CONFIG HERE

  SERVED_GUAMI_LIST = (
    {MCC = "208"; MNC = "95"; RegionID = "128"; AMFSetID = "1"; AMFPointer = "0"}, #48bits <MCC><MNC><RegionID><AMFSetID><AMFPointer>
    {MCC = "460"; MNC = "11"; RegionID = "10"; AMFSetID = "1"; AMFPointer = "1"}  #48bits <MCC><MNC><RegionID><AMFSetID><AMFPointer>
  );

  PLMN_SUPPORT_LIST = (
  {
    MCC = "208"; MNC = "95"; TAC = 0x0001;  # YOUR PLMN CONFIG HERE
    SLICE_SUPPORT_LIST = (
      {SST = "1"; SD = "1"},  # YOUR NSSAI CONFIG HERE
      {SST = "222"; SD = "123"}   # YOUR NSSAI CONFIG HERE
     )
  }
  );

  INTERFACES:
  {
    # AMF binded interface for N1/N2 interface (NGAP)
    NGAP_AMF:
    {
      INTERFACE_NAME = "eth0";  # YOUR NETWORK CONFIG HERE
      IPV4_ADDRESS   = "read";
      PORT           = 38412;                            # YOUR NETWORK CONFIG HERE
      PPID           = 60;                               # YOUR NETWORK CONFIG HERE
    };

    # AMF binded interface for SBI (N11 (SMF)/N12 (AUSF), etc.)
    N11:
    {
      INTERFACE_NAME = "eth0"; # YOUR NETWORK CONFIG HERE
      IPV4_ADDRESS   = "read";
      PORT           = 80;                             # YOUR NETWORK CONFIG HERE
      API_VERSION    = "v1";                           # YOUR AMF API VERSION CONFIG HERE
      HTTP2_PORT     = 8080;                           # YOUR NETWORK CONFIG HERE

      SMF_INSTANCES_POOL = (
       {SMF_INSTANCE_ID = 1; IPV4_ADDRESS = "0.0.0.0"; PORT = "80"; HTTP2_PORT = 8080, VERSION = "v1"; FQDN = "localhost", SELECTED = "tr\
ue"}, # YOUR SMF CONFIG HERE
        {SMF_INSTANCE_ID = 2; IPV4_ADDRESS = "0.0.0.0"; PORT = "80"; HTTP2_PORT = 8080, VERSION = "v1"; FQDN = "localhost", SELECTED = "fa\
lse"} # YOUR SMF CONFIG HERE
      );
    };

    NRF :
    {
      IPV4_ADDRESS = "0.0.0.0";  # YOUR NRF CONFIG HERE
      PORT         = 80;            # YOUR NRF CONFIG HERE (default: 80)
      API_VERSION  = "v1";   # YOUR NRF API VERSION FOR SBI CONFIG HERE
      FQDN         = "oai-nrf-svc"           # YOUR NRF FQDN CONFIG HERE
    };

    AUSF :
    {
      IPV4_ADDRESS = "127.0.0.1";  # YOUR AUSF CONFIG HERE
      PORT         = 80;            # YOUR AUSF CONFIG HERE (default: 80)
      API_VERSION  = "v1";   # YOUR AUSF API VERSION FOR SBI CONFIG HERE
      FQDN         = "oai-ausf-svc"           # YOUR AUSF FQDN CONFIG HERE
    };

    UDM :
    {
      IPV4_ADDRESS = "127.0.0.1";    # YOUR UDM CONFIG HERE
      PORT         = 80;              # YOUR UDM CONFIG HERE (default: 80)
      API_VERSION  = "v2";     # YOUR UDM API VERSION FOR SBI CONFIG HERE
      FQDN         = "udm-fqdn";            # YOUR UDM FQDN CONFIG HERE
    };

    NSSF :
    {
      IPV4_ADDRESS = "0.0.0.0";  # YOUR NSSF CONFIG HERE
      PORT         = 80;            # YOUR NSSF CONFIG HERE (default: 80)
      API_VERSION  = "v2";   # YOUR NSSF API VERSION FOR SBI CONFIG HERE
      FQDN         = "oai-nssf"           # YOUR NSSF FQDN CONFIG HERE
    };
  SUPPORT_FEATURES:
  {
     # STRING, {"yes", "no"},
     NF_REGISTRATION = "yes";  # Set to yes if AMF resgisters to an NRF
     NRF_SELECTION   = "no";    # Set to yes to enable NRF discovery and selection
     EXTERNAL_NRF    = "no";    # Set to yes if AMF works with an external NRF
     SMF_SELECTION   = "yes";    # Set to yes to enable SMF discovery and selection
     EXTERNAL_AUSF   = "yes";    # Set to yes if AMF works with an external AUSF
     EXTERNAL_UDM    = "no";     # Set to yes if AMF works with an external UDM
     EXTERNAL_NSSF   = "no";     # Set to yes if AMF works with an external NSSF
     USE_FQDN_DNS    = "yes";     # Set to yes if AMF relies on a DNS to resolve NRF/SMF/UDM/AUSF's FQDN
     USE_HTTP2       = "no";      # Set to yes to enable HTTP2 for AMF server
  }

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

  NAS:
  {
    ORDERED_SUPPORTED_INTEGRITY_ALGORITHM_LvIST = [ "NIA0" , "NIA1" , "NIA2" ];  #Default [ "NIA0" , "NIA1" , "NIA2" ];
    ORDERED_SUPPORTED_CIPHERING_ALGORITHM_LIST = [ "NEA0" , "NEA1" , "NEA2" ]; #Default [ "NEA0" , "NEA1" , "NEA2" ];
  };

};

```

Use following `chart/oai-amf/values.yaml` manifest:

```
replicaCount: 1

namespace: oai5g

nfimage:  # image name either locally present or in a public/private repository
  registry: local
  repository: rdefosseoai/oai-amf
  version: develop
  # pullPolicy: IfNotPresent or Never or Always
  pullPolicy: IfNotPresent

tcpdumpimage:
  registry: local
  repository: corfr/tcpdump
  version: latest
  #pullPolicy: IfNotPresent or Never or Always
  pullPolicy: IfNotPresent

## good to use when pulling images from docker-hub mention
imagePullSecrets:
  - name: "regcred"

serviceAccount:
  create: true
  annotations: {}
 template
  name: "oai-amf-sa"

podSecurityContext:
  runAsUser: 0
  runAsGroup: 0

securityContext:
  privileged: true


service:
  type: ClusterIP
  sctpPort: 38412
  http1Port: 80
  http2Port: 9090

start:
  amf: true
  tcpdump: false #start tcpdump collection to analyse but beware it will take a lot of space in the container/persistent volume

### In case your gNB or emulator is outside of the cluster then you need an extra interface to communicate with gNB
## This interface will be for N1/N2/NGAP

multus:
  create: false
  n1IPadd: "172.21.10.6"
  n1Netmask: "22"
  n1Gateway: "172.21.11.254"
  hostInterface: "ens2f0np0"

persistent:
  sharedvolume: false
  volumeName: managed-nfs-storage
  size: 1Gi

resources:
  define: false
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
   cpu: 100m
   memory: 256Mi

readinessProbe: true

livenessProbe: true

terminationGracePeriodSeconds: 30

nodeSelector: {}

nodeName:

```

### 3/ oai-ausf configuration

Set the parameter *imagePullPolicy* to `{{ .Values.tcpdumpimage.pullPolicy }}`in file `oai-ausf/templates/deployment.yaml`:

```
...
      containers:
      - name: tcpdump
        image: "{{ .Values.tcpdumpimage.repository }}:{{ .Values.tcpdumpimage.version }}"
        imagePullPolicy: {{ .Values.tcpdumpimage.pullPolicy }}
...
```

Use following  `chart/oai-ausf/values.yaml` manifest:

```
replicaCount: 1

namespace: oai5g

nfimage:
  registry: local
  repository: rdefosseoai/oai-ausf   ## rdefosseoai/oai-ausf # image name either locally present or in a public/private repository
  version: develop       ## latest/v1.4.0 tag for stable and develop for experimental
  #pullPolicy: IfNotPresent or Never or Always
  pullPolicy: IfNotPresent

tcpdumpimage:
  registry: local
  repository: corfr/tcpdump
  version: latest
  #pullPolicy: IfNotPresent or Never or Always
  pullPolicy: IfNotPresent

## good to use when pulling images from docker-hub mention
imagePullSecrets:
  - name: "regcred"

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: "oai-ausf-sa"

podSecurityContext:
  runAsUser: 0
  runAsGroup: 0

securityContext:
  privileged: false

service:
  type: ClusterIP
  httpPort: 80

start:
  ausf: true
  tcpdump: false #start tcpdump collection to analyse but beware it will take a lot of space in the container/persistent volume

config:
  tz: "Europe/Paris"
  instanceId: "0"
  pidDirectory: "/var/run"
  ausfName: "OAI_AUSF"
  sbiIfName: "eth0"
  sbiPort: "80"
  useFqdnDns: "yes"
  udmIpAddress: "127.0.0.1"
  udmPort: "80"
  udmVersionNb: "v1"
  udmFqdn: "oai-udm-svc"

persistence:
  sharedvolume: false
  volumneName: managed-nfs-storage
  size: 1Gi

resources:
  define: false
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
   cpu: 100m
   memory: 256Mi

readinessProbe: true

livenessProbe: true

terminationGracePeriodSeconds: 30

nodeSelector: {}

nodeName:
```

### 4/ oai-nrf configuration

Apply following changes to manifest `charts/oai-nrf/values.yaml`:

```
7,8c7
< namespace: oai5g
<
---
> namespace: "oai"
14c13
<   version: develop
---
>   version: v1.1.0
16c15
<   pullPolicy: IfNotPresent
---
>   pullPolicy: Always
23c22
<   pullPolicy: IfNotPresent
---
>   pullPolicy: Always
26,27c25,26
< imagePullSecrets:
<   - name: "regcred"
---
> #imagePullSecrets:
> #  - name: "personalkey"
64c63
< persistent:
---
> persistence:
```

Apply following changes to configuration file `charts/oai-nrf/templates/deployment.yaml`:

```
28d27
<         imagePullPolicy: {{ .Values.tcpdumpimage.pullPolicy }}
39c38
<         {{- if .Values.persistent.sharedvolume}}
---
>         {{- if .Values.persistence.sharedvolume}}
42c41
<           name: cn5g-pvc
---
>           name: cn5g-pv
46d44
<         imagePullPolicy: {{ .Values.nfimage.pullPolicy }}
118,120c116,118
<       {{- if .Values.persistent.sharedvolume}}
<       - name: cn5g-pvc
<         persistentVolumeClaim:
---
>       {{- if .Values.persistence.sharedvolume}}
>       - name: cn5g-pv
>         persistenceVolumeClaim:
```

Apply following changes to configuration file `charts/oai-nrf/templates/pvc.yaml`:

```
1c1
< {{- if .Values.persistent.sharedvolume }}
---
> {{- if .Values.persistence.sharedvolume }}
9c9
<   storageClassName: {{ .Values.persistent.volumeName }}
---
>   storageClassName: {{ .Values.persistent.volumneName }}
```


### 5/ oai-smf configuration

Set following parameters in file `chart/oai-amf/scripts/smf.conf`:

```
    # DNS address communicated to UEs
    DEFAULT_DNS_IPV4_ADDRESS     = "138.96.0.10";  # YOUR DNS CONFIG HERE
    DEFAULT_DNS_SEC_IPV4_ADDRESS = "138.96.0.11";  # YOUR DNS CONFIG HERE

```

Use following template file `oai-smf/templates/deployment.yaml`:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
  labels:
    {{- include "oai-smf.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "oai-smf.selectorLabels" . | nindent 6 }}
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        {{- include "oai-smf.selectorLabels" . | nindent 8 }}
    {{- if .Values.multus.create }}
      annotations:
        k8s.v1.cni.cncf.io/networks: >-
          [{
                 "name": "{{ .Chart.Name }}-{{ .Values.namespace }}-n4-net1",
                 "default-route": ["{{ .Values.multus.n4Gw }}"]
          }]
    {{- end }}
    spec:
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
    {{- if .Values.imagePullSecrets }}
      imagePullSecrets:
        {{ toYaml .Values.imagePullSecrets | indent 8 }}
    {{- end }}
      containers:
      - name: tcpdump
        image: "{{ .Values.tcpdumpimage.repository }}:{{ .Values.tcpdumpimage.version }}"
        imagePullPolicy: {{ .Values.tcpdumpimage.pullPolicy }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        {{- if .Values.start.tcpdump}}
        command:
          - /bin/sh
          - -c
          - /usr/sbin/tcpdump -i any -w /pcap/oai-smf_`date +%Y-%m-%d_%H_%M-%S-%Z`.pcap
        {{- else}}
        command:
          - /bin/sleep
          - infinity
        {{- end}}
        {{- if .Values.persistent.sharedvolume}}
        volumeMounts:
        - mountPath: "/pcap"
          name: cn5g-pvc
        {{- end}}
      - name: smf
        image: "{{ .Values.nfimage.repository }}:{{ .Values.nfimage.version }}"
        imagePullPolicy: {{ .Values.nfimage.pullPolicy }}
        securityContext:
          {{- toYaml .Values.securityContext | nindent 12 }}
        volumeMounts:
        - mountPath: /scripts
          name: scripts
        - mountPath: /openair-smf/etc/smf.conf
          name: edit-smf
          subPath: smf.conf
        {{- if .Values.readinessProbe}}
        readinessProbe:
          exec:
            command:
            - sh
            - /scripts/live-ready.sh
          initialDelaySeconds: 5
          periodSeconds: 5
        {{- end}}
        {{- if .Values.livenessProbe}}
        livenessProbe:
          exec:
            command:
            - sh
            - /scripts/live-ready.sh
          initialDelaySeconds: 10
          periodSeconds: 5
        {{- end}}
        ports:
        - containerPort: {{ .Values.service.n4Port }}
          name: oai-smf
        - containerPort: {{ .Values.service.http1Port }}
          name: http1
        - containerPort: {{ .Values.service.http2Port }}
          name: http2
        {{- if .Values.resources.define}}
        resources:
          requests:
            memory: {{ .Values.resources.requests.memory | quote }}
            cpu: {{ .Values.resources.requests.cpu | quote }}
          limits:
            memory: {{ .Values.resources.limits.memory | quote }}
            cpu: {{ .Values.resources.limits.cpu | quote }}
        {{- end}}
        {{- if .Values.start.smf}}
        command:
          - /openair-smf/bin/oai_smf
          - -c
          - /openair-smf/etc/smf.conf
          - -o
        {{- else}}
        command:
          - /bin/sleep
          - infinity
        {{- end}}
      volumes:
      {{- if .Values.persistent.sharedvolume}}
      - name: cn5g-pvc
        persistentVolumeClaim:
          claimName: cn5g-pvc
      {{- end }}
      - name: scripts
        configMap:
          name: {{ .Chart.Name }}-health-cm
      - name: edit-smf
        configMap:
          name: {{ .Chart.Name }}-real-config
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      serviceAccountName: {{ .Values.serviceAccount.name }}
      terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds }}
      {{- if .Values.nodeSelector}}
      nodeSelector: {{- toYaml .Values.nodeSelector | nindent 4 }}
      {{- end }}
      {{- if .Values.nodeName}}
      nodeName: {{ .Values.nodeName }}
      {{- end }}
```

### 6/ oai-spgwu-tiny configuration

Use following manifest `charts/oai-spgwu-tiny/values.yaml`:

```
replicaCount: 1

namespace: "oai"

nfimage:
  registry: local
  repository: oai-spgwu-tiny # dockerhub rdefosseoai/oai-spgwu-tiny
  version: v1.1.2            # develop for experimental feature in that case check the configuration file
  # pullPolicy: IfNotPresent or Never or Always
  pullPolicy: Always

tcpdumpimage:
  registry: local
  repository: corfr/tcpdump
  version: latest
  #pullPolicy: IfNotPresent or Never or Always
  pullPolicy: Always

## good to use when pulling images from docker-hub mention
#imagePullSecrets:
#  - name: "personalkey"

serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: "oai-spgwu"

podSecurityContext:
  runAsUser: 0
  runAsGroup: 0

securityContext:
  privileged: true

service:
  type: ClusterIP
  pfcpPort: 8805 # default port no need to change unless necessary
  gtpuPort: 2152 # default port no need to change unless necessary

start:
  spgwu: true
  tcpdump: false

# create an extra interface for N3 incase the gNB is outside the cluster network or there is a need to have dedicated interface for N3
multus:
  create: true
  n3Ip: "192.168.18.179"
  n3Netmask: "24"
  sgiGw: "192.168.18.129"
  hostInterface: "bond0"

config:
  gwId: 1 # no need to configure
  mcc: 208 # should match with AMF and SMF
  mnc: 95 # should match with AMF and SMF
  realm: "3gpp.org" # no need to configure
  pidDirectory: "/var/run" # no need to configure
  sgwS1uIf: "net1"  # net1 if gNB is outside the cluster network and multus creation is true else eth0
  s1uThreads: 1 # experimental to play with the performance of SPGWU
  sxThreads: 1 # experimental to play with the performance of SPGWU
  sgiThreads: 1 # experimental to play with the performance of SPGWU
  threadS1Upriority: 98 # experimental to play with the performance of SPGWU
  threadSXpriority: 98 # experimental to play with the performance of SPGWU
  threadSGIpriority: 98 # experimental to play with the performance of SPGWU
  sgwSxIf: "eth0" # use for SMF communication
  pgwSgiIf: "net1"  # net1 if gNB is outside the cluster network and multus creation is true else eth0 (important because it sends the traffic towards internet)
  netUeNatOption: "yes" # yes to get the traffic out towards internet
  gtpExtentionHeaderPresent: "yes" # needed for 5G (Always true)
  netUeIp: "12.1.1.0/24"  # The range in which UE ip-address will be allocated should be configured the same in SMF
  nssaiSst0: 1 # should match with SMF information
  nssaiSd0: 1  # should match with SMF information
  dnn0: "oai" # should match with SMF information
  spgwc0IpAdd: "127.0.0.1" # SMF ip-address incase NRF is not used to initiate a PFCP session
  bypassUlPfcpRules: "no"
  enable5GFeatures: "yes" # This will make SPGWU to function as 5G UPF, if set no then it will work for 4G
  registerNRF: "yes"
  useFqdnNrf: "yes"  # use FQDN to resolve nrf ip-address
  nrfIpv4Add: "127.0.0.1" # set it if nrf FQDN can not be resolved
  nrfPort: "80"
  nrfApiVersion: "v1"
  nrfFqdn: "oai-nrf-svc" # make sure this can be resolved by container dns
  upfFqdn5g: "oai-spgwu-tiny-svc" # fqdn of upf

## currently only used by tcpdump container to store the tcpdump, this volume will be shared between all the network functions
persistence:
  sharedvolume: false  # should be true when if wants to store the tcpdump of all the network functions at same place
  volumneName: managed-nfs-storage
  size: 1Gi


resources:
  define: false
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
   cpu: 100m
   memory: 256Mi

readinessProbe: true

livenessProbe: true

terminationGracePeriodSeconds: 30

nodeSelector: {}

nodeName:
```

Use following configuration file `charts/oai-spgwu-tiny/templates/configmap.yaml`:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-configmap
data:
  {{- range $key, $val := .Values.config }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-health-cm
data:
  {{ (.Files.Glob "scripts/live-ready.sh").AsConfig | indent 2 | trim }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-real-config
data:
  {{ (.Files.Glob "scripts/spgw_u.conf").AsConfig | indent 2 | trim }}
```

Add following configuration file `charts/oai-spgwu-tiny/scripts/spgw_u.conf`

```
SPGW-U =
{
    FQDN = "gw1.spgw.node.epc.mnc99.mcc208.3gpp.org"; # FQDN for 4G
    INSTANCE                       = 0;            # 0 is the default
    PID_DIRECTORY                  = "/var/run";     # /var/run is the default

    #ITTI_TASKS :
    #{
        #ITTI_TIMER_SCHED_PARAMS :
        #{
            #CPU_ID       = 1;
            #SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
            #SCHED_PRIORITY = 85;
        #};
        #S1U_SCHED_PARAMS :
        #{
            #CPU_ID       = 1;
            #SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
            #SCHED_PRIORITY = 84;
        #};
        #SX_SCHED_PARAMS :
        #{
            #CPU_ID       = 1;
            #SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
            #SCHED_PRIORITY = 84;
        #};
        #ASYNC_CMD_SCHED_PARAMS :
        #{
            #CPU_ID       = 1;
            #SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
            #SCHED_PRIORITY = 84;
        #};
    #};

    INTERFACES :
    {
        S1U_S12_S4_UP :
        {
            # S-GW binded interface for S1-U communication (GTPV1-U) can be ethernet interface, virtual ethernet interface, we don't advise wireless interfaces
            INTERFACE_NAME         = "net1";  # STRING, interface name, YOUR NETWORK CONFIG HERE
            IPV4_ADDRESS           = "read";                                    # STRING, CIDR or "read to let app read interface configured IP address
            #PORT                   = 2152;                                     # Default is 2152
            SCHED_PARAMS :
            {
                #CPU_ID       = 2;
                SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
                SCHED_PRIORITY = 98;
                POOL_SIZE = 1; # NUM THREADS
            };
        };
        SX :
        {
            # S/P-GW binded interface for SX communication
            INTERFACE_NAME         = "eth0"; # STRING, interface name
            IPV4_ADDRESS           = "read";                        # STRING, CIDR or "read" to let app read interface configured IP address
            #PORT                   = 8805;                         # Default is 8805
            SCHED_PARAMS :
            {
                #CPU_ID       = 1;
                SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
                SCHED_PRIORITY = 98;
                POOL_SIZE = 1; # NUM THREADS
            };
        };
        SGI :
        {
           # No config to set, the software will set the SGi interface to the interface used for the default route.
            INTERFACE_NAME         = "net1"; # STRING, interface name or "default_gateway"
            IPV4_ADDRESS           = "read";                         # STRING, CIDR or "read" to let app read interface configured IP address
            SCHED_PARAMS :
            {
                #CPU_ID       = 3;
                SCHED_POLICY = "SCHED_FIFO"; # Values in { SCHED_OTHER, SCHED_IDLE, SCHED_BATCH, SCHED_FIFO, SCHED_RR }
                SCHED_PRIORITY = 98;
                POOL_SIZE = 1; # NUM THREADS
            };
        };
    };

    SNAT = "yes"; # SNAT Values in {yes, no}
    PDN_NETWORK_LIST  = (
                      {NETWORK_IPV4 = "12.2.1.0/24";} # 1 ITEM SUPPORTED ONLY
                    );

    SPGW-C_LIST = (
         {IPV4_ADDRESS="127.0.0.1" ;}
    );

    NON_STANDART_FEATURES :
    {
        BYPASS_UL_PFCP_RULES = "no"; # 'no' for standard features, yes for enhancing UL throughput
    };

    SUPPORT_5G_FEATURES:
    {
       # STRING, {"yes", "no"},
       ENABLE_5G_FEATURES = "yes" # Set to 'yes' to support 5G Features
       REGISTER_NRF = "yes";  # Set to 'yes' if UPF resgisters to an NRF
       USE_FQDN_NRF = "yes"; # Set to 'yes' if UPF relies on a DNS/FQDN service to resolve NRF's FQDN
       UPF_FQDN_5G  = "oai-spgwu-tiny-svc";  #Set FQDN of UPF

       NRF :
       {
          IPV4_ADDRESS = "127.0.0.1";  # YOUR NRF CONFIG HERE
          PORT         = 80;            # YOUR NRF CONFIG HERE (default: 80)
          HTTP_VERSION = 1;   #Set HTTP version for NRF (1 or 2)Default 1
          API_VERSION  = "v1";   # YOUR NRF API VERSION HERE
          FQDN = "oai-nrf-svc";
       };

       # Additional info to be sent to NRF for supporting Network Slicing
       UPF_INFO = (
          { NSSAI_SST = 1; NSSAI_SD = "1";  DNN_LIST = ({DNN = "oai.ipv4";}); },
          { NSSAI_SST = 222; NSSAI_SD = "123";  DNN_LIST = ({DNN = "oai.ipv4";}); }
       );
    }
};
```
### 7/ oai-udm configuration

Apply following changes in manifest `charts/oai-udm/values.yaml`:

```
7,8c7
< namespace: oai5g
<
---
> namespace: "oai"
12c11
<   repository: rdefosseoai/oai-udm          ## rdefosseoai/oai-udm # image name either locally present or in a public/private repository
---
>   repository: oai-udm          ## rdefosseoai/oai-udm # image name either locally present or in a public/private repository
25,26c24,25
< imagePullSecrets:
<   - name: "regcred"
---
> #imagePullSecrets:
> #  - name: "personalkey"
```

Apply following changes in template file `charts/oai-udm/templates/deployment.yaml`:

```
28d27
<         imagePullPolicy: {{ .Values.tcpdumpimage.pullPolicy }}
47d45
<         {{- if .Values.resources.define}}
```

### oai-udr configuration

Apply following changes in manifest `charts/oai-udr/values.yaml`:

```
7c7
< namespace: oai5g
---
> namespace: "oai"
12c12
<   version: develop # image tag
---
>   version: v1.1.0 # image tag
14c14
<   pullPolicy: IfNotPresent
---
>   pullPolicy: Always
21,24c21
<   pullPolicy: IfNotPresent
<
< imagePullSecrets:
<   - name: "regcred"
---
>   pullPolicy: Always
55d51
<   udrname: "oai-udr"
57,59d52
<   registerNrf: "no"
<   usehttp2: "no"
<   useFqdnDns: "yes"
64,67d56
<   nrfIpv4Address: "127.0.0.1"
<   nrfPort: "80"
<   nrfApiVersion: "v1"
<   nrfFqdn: "oai-nrf-svc"
```

Apply following changes in configuration file ``:

```
21,22d20
<       imagePullSecrets:
<         {{ toYaml .Values.imagePullSecrets | indent 8 }}
26d23
<         imagePullPolicy: {{ .Values.tcpdumpimage.pullPolicy }}
94,98d90
<           - name: UDR_NAME
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: udrname
109,113d100
<           - name: USE_FQDN_DNS
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: useFqdnDns
119,128d105
<           - name: REGISTER_NRF
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: registerNrf
<           - name: USE_HTTP2
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: usehttp2
144,163d120
<           - name: NRF_IPV4_ADDRESS
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: nrfIpv4Address
<           - name: NRF_PORT
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: nrfPort
<           - name: NRF_API_VERSION
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: nrfApiVersion
<           - name: NRF_FQDN
<             valueFrom:
<               configMapKeyRef:
<                 name: {{ .Chart.Name }}-configmap
<                 key: nrfFqdn
```



## OAI CN5G Deployment

Assumption: mysql-volume PersistentVolume is available on the k8s cluster, you can check with `kubectl get pv`


- `$ kubectl create ns oai5g; kns oai5g`
- `$ cd oai-cn5g-fed/charts`

You can deploy automatically all CN5G pods with:

- `$ helm_chart.sh install oai5g`

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

To debug a deployment, use following options:

`$ helm install --debug --dry-run mysql mysql/`


To check the 5GCN deployment:

```
$ helm list
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
$ kubectl get po
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
Then, run:

```
$ kubectl logs oai-smf-7dcfcbdb9c-2lsjq -c smf | grep 'Received N4 ASSOCIATION SETUP RESPONSE from an UPF'
[2022-03-28T12:32:01.919851] [smf] [smf_n4 ] [info ] Received N4 ASSOCIATION SETUP RESPONSE from an UPF

$ kubectl logs oai-spgwu-tiny-774fcf5f7-78958 -c spgwu | grep 'Received SX HEARTBEAT REQUEST' | wc -l
2951 (should be more than 1)
```

## OAI 5G RAN-emulator 


### oai-gnb pod

Nota: `oai-gnb` will run with `--sa -E --rfsim` options

Set the *master* parameter to `"eth0"` in the `charts/oai-gnb/templates/multus.yaml` chart

```
{{- if .Values.multus.create }}
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: {{ .Chart.Name }}-{{ .Values.namespace }}-net1
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      "master": "eth0",
      "mode": "bridge",
      "ipam": {
        "type": "static",
        "addresses": [
                {
                        "address": {{- cat .Values.multus.ipadd "/" .Values.multus.netmask | nospace | quote }}
                }
        ]
      }
    }'
{{- end }}
```

Set the parameters *namespace* to `"oai5g"`, set *repository*  to `"docker.io/rdefosseoai/oai-gnb"` and set the *amfIpAddress* parameter in the manifest `charts/oai-gnb/values.yaml`

```
namespace: "oai5g"

nfimage:   # image name either locally present or in a public/private repository
  registry: local
  repository: docker.io/rdefosseoai/oai-gnb           
```

Then deploy the oai-gnb pod with:

`oai-cn5g-fed/charts $ helm install oai-gnb oai-gnb/`

To check the gnB logs, run:

*kubectl logs \`kubectl get po | grep gnb | awk '{print $1}'\` -c gnb*

### oai-nr-ue pod

Set the *master* parameter to `"eth0"` in the `charts/oai-nr-ue/templates/multus.yaml` chart

```
{{- if .Values.multus.create }}
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: {{ .Chart.Name }}-{{ .Values.namespace }}-net1
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      "master": "eth0",
      "mode": "bridge",
      "ipam": {
        "type": "static",
        "addresses": [
                {
                        "address": {{- cat .Values.multus.ipadd "/" .Values.multus.netmask | nospace | quote }}
                }
        ]
      }
    }'
{{- end }}
```


Set the following parameters in the manifest `charts/oai-nr-ue/values.yaml`: *namespace, repository, rfSimulator, fullImsi, fullKey, opc*.

For now, the rfSimulator should be manually retrieved using:

 *kubectl describe po \`kubectl get po | grep gnb | awk '{print $1}'\` | grep IP:* 

```
namespace: "oai5g"

nfimage:
  registry: local
  repository: docker.io/rdefosseoai/oai-nr-ue     
...
config:
  timeZone: "Europe/Paris"
  rfSimulator: "10.244.1.103"    # ip-address of gnb rf-sim
  fullImsi: "208990100001121"       # make sure all the below entries are present in the subscriber database
  fullKey: "fec86ba6eb707ed08905757b1bb44b8f"
  opc: "8e27b6af0e692e750f32667a3b14605d"
...      
    
```

Then, deploy the oai-nr-ue pod with:

`oai-cn5g-fed/charts $ helm install nr-ue oai-nr-ue/`

To check the logs, run:

*kubectl logs \`kubectl get po | grep nr-ue | awk '{print $1}'\` -c nr-ue*


