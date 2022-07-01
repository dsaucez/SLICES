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

- we have been unsuccessful at adding the R2Lab nodes (behind the NAT at `faraday.inria.fr`) into the cluster that has a master on the sopnode side; have tried to deply konnectivity, which works fine as far as control plane, but the data plane never can't seem to follow suit.
- so in order to work around that, we have instrumented our network - our of band, as far as k8s is concerned, by
  - creating a static IPIP tunnel between `faraday.inria.fr` and `sopnode-l1.inria.fr`
  - adding static routes on `sopnode*` and `faraday`
  - so that all these boxes have smooth connectivity with the FIT nodes on their private `192.168.3.x` addresses
  - in theory we provide a `join-tunnel` command on the FIT side (so, in the `kubernetes` image) but for most practical purposes this is not a crucial thing to run
  - all participants have a `test-tunnel` command that check for that connectivity (when called on a non-fit box, specify which fit node you are targetting with e.g. `test-tunnel 3`)

### upgrading

plan is to move to fedora-36 and kubernetes-1.24

this is WIP
