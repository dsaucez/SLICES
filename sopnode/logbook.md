# sopnode - DIANA logbook

## networking

Edge-Core SONiC Enterprise installed sucessfully on Wedge100-32X. This image has very limited functionalities. Ok for basic scenarios but won’t be very useful on the long run.
Edge-Core does not provide SONiC image or support for the Wedge1000-32QS though they provide a brief documentation on how to setup an open source SONiC for that platform.
The issue is that compilation fails for the open source SONiC for the p4 platform (i.e., the one corresponding to the ASICs in the Wedge100 switches). The issue comes from dependencies that are incompatible. Almost 2 years since the p4 platform is not supported anymore by the open source project and unfortunately compile scripts did not “fix” the version so we have to rebuild the dependency tree with trials and errors. 

## compute

### deploy k8s on the micro-cluster

- [x] 4 poweredge r640 are setup on these hostnames
  `sopnode-l1.inria.fr` - k8s control-plane
  `sopnode-w{1,2,3}.inria.fr` - k8s worker
- [x] k8s *production* cluster created on `sopnode-l1` with `sopnode-w1` as a worker
- [x] k8s *devel* cluster created on `sopnode-w2` with `sopnode-w3` as a worker

### deploy k8s on R2lab

- [x] provide a `kubernetes` image on R2lab
  this has the following capabilities
  * firewalling is turned off
  * all kube code is preinstalled and ready to run in `/root/kube-install`  
    (a `git pull` won't harm, as you know the images are rather costly to produce...)
- [x] based on a super lightweight bash tool named `kube-install.sh`  
  <https://github.com/parmentelat/kube-install>
  * **cluster creation**
    `kube-install.sh create-cluster`  
    this sets up a `konnectivity` service
  * **joining a cluster**
    * worker side  
      `kube-install.sh join-cluster r2lab@sopnode-l1.inria.fr`  
      note that here the `r2lab` user is only used to enter in the master node
      and get the token needed to join (by actually running the command below)
    * leader side  
      `kube-install.sh join-command`
      will just display the command for a worker node to join  


### connect *sopnode* and R2lab

- [x] one node at a time - OK
  ```
  # typical set up
  rload -i kubernetes 1
  ssh root@fit01
  [fit01] kube-install.sh join-cluster r2lab@sopnode-l1.inria.fr
  ```
- [x] en masse joins
  for instance, to do it en masse
  ```
  [faraday]
  nodes -a 
  n- 4 14 18 31 37
  rload -i kubernetes
  rwait
  map kube-install.sh join-cluster r2lab@sopnode-l1.inria.fr
  ```
  this turned out to work reliably on my first attempt to join these 32 nodes simultaneously with kube-install-v0.4
- [x] study consequences on the R2lab workflow  
  users will never leave properly !  
  so see how the k8s cluster reacts to a R2lab node being re-imaged
  - [x] apparently the k8s cluster realizes rather quick that the node is down
  - [x] from a sopnode, the following bash functions are available
    - `fit-nodes` `fit-deads` `fit-alives` gives list of fit nodes in the cluster, whether they are alive or not
    - `fit-drain-nodes` `fit-delete-nodes` to cleanse the cluster from any reference to a fit node

- [x] en masse leave
  ```
  [faraday]
  map kube-install.sh destroy-cluster

  [sopnode]
  fit-drain-nodes
  fit-delete-nodes
  ```
- [x] labelling and selecting nodes  
  * use `fit-label-nodes` from a sopnode box once the nodes have joined the cluster; this sets `r2lab/node=true` on all R2lab nodes (actually all nodes returned by `fit-nodes`)
  * see https://github.com/parmentelat/kube-install/tree/devel/kiada for examples of how this can be used to select a particular node, or any node on the R2lab or the sopnode side
