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
- [ ] en masse joins
  for instance, to do it en masse
  ```
  nodes -a ~4 ~13 ~15 ~31 ~37
  rload -i kubernetes
  rwait
  map kube-install.sh join-cluster r2lab@sopnode-l1.inria.fr
  ```
  however this kind of synchronous approach seems to cause a burst and some nodes fail to reach - to be investigated...
- [ ] study consequences of the R2lab workflow  
  users will never leave properly !  
  so see how the k8s cluster reacts to a R2lab node being re-imaged
  - [x] apparently the k8s cluster realizes rather quick that the node is down
  - [ ] however it might make sense to help it by doing an explicit `kubectl delete node` on stale nodes  
  **DOES NOT SEEM TOO SERIOUS ?** 
  - [ ] what happens if the same node tries to join again after it is re-imaged - (and the cluster is not cleaned up)  
  so here the answer is, no big deal, the cluster realizes on its own (in about one minute) that the node has gone; it gets marked 'NotReady'; the same node re-imaged later on can join again with no particular fuss (the time for re-imaging seems enough :)
  - [ ] now all this was with an empty load (no pod on the fit nodes);
    of course when pods are going to be running on the nodes all this might need more care...
