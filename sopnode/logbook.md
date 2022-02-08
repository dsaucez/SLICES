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
- [x] k8s cluster created on `sopnode-l1`
  to join, use this command on the master node
  `/root/kube-install/kube-install.sh show-join`
  and copy-paste on the worker node that wants to join

### deploy k8s on R2lab

- [x] provide a `kubernetes` image on R2lab
  this has the following capabilities
  * all kube code is preinstalled and ready to run
  * firewalling is turned off
  * in `/root/kube-install/kube-install.sh` 
    is a command that allows to create and join clusters
      * master node would typically do
        `/root/kube-install/kube-install.sh create-cluster`
      * run the same, still on master, but with `show-join` as the subcommand, to display the command for workers to join

### connect *sopnode* and R2lab

the thing is, the R2lab nodes are NAT'ed behind faraday, so it's a one-way street from the nodes to `sopnode-l1`  
so, plan is to

- [ ] tweak `kube-install.sh` so that the deployed cluster enables `konnectivity` as a means to maintain connectivity between nodes and control-plane  
  https://kubernetes.io/docs/tasks/extend-kubernetes/setup-konnectivity/
  ***ongoing...***
  
## epilogue

originally this has started in https://dropsu.sorbonne-universite.fr/apps/onlyoffice/s/c4nx5AkK2NKNtSL?fileId=99561549


