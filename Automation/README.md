# BMV2

## BMV2 INSTALLATION 
Steps to initiate an instant with BMV2 and stratum. 
these instruction were tested on a GCP instance running Ubuntu 20.04 TLS

general dependecies : 
```console
sudo apt-update
sudo apt-get install -y automake cmake libgmp-dev \
    libpcap-dev libboost-dev libboost-test-dev libboost-program-options-dev \
    libboost-system-dev libboost-filesystem-dev libboost-thread-dev \
    libevent-dev libtool flex bison pkg-config g++ libssl-dev
```
### bmv2(tested for debian 9 and ubuntu TLS 20.04): 
```console
set -e
git clone https://github.com/p4lang/behavioral-model.git bmv2_tmp
cd bmv2_tmp
sudo ./install_deps.sh
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
```
### docker ubuntu
Docker need to be installed for stratum to run
```console
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
### bmv2 stratum
```console
git clone https://github.com/stratum/stratum.git
cd stratum
sudo chmod 666 /var/run/docker.sock
./setup_dev_env.sh
```
now you are inside the container
```console
bazel build //stratum/hal/bin/bmv2:stratum_bmv2_deb
cp -f /stratum/bazel-bin/stratum/hal/bin/bmv2/stratum_bmv2_deb.deb /stratum/
```
After you build the stratum package, you can start stratum as follow
```console
./setup_dev_env.sh # Do this command if you are not inside the container already
# -- inside the container
sudo apt-get update 
sudo apt-get install -y --reinstall ./stratum_bmv2_deb.deb
sudo stratum_bmv2 \
    -chassis_config_file=/etc/stratum/chassis_config.pb.txt
```
## Onos Installation  (tested on ubuntu 20,04 TLS): 
general dependecies : 
```console
sudo apt-update
sudo apt install make
```

### Install docker (same steps as before)
### Start onos container: 
```console
docker run -t -d -p 8181:8181 -p 8101:8101 -p 5005:5005 -p 830:830 --name onos onosproject/onos:2.7.0
ssh -p 8101 onos@localhost  # to go inside the onos container : credentials : onos/rocks
app activate org.onosproject.drivers.bmv2 
```
## Fabric-tna (tested on ubuntu 20,04) :
general dependecies : 
```console
sudo apt-update
sudo apt install make git
```

fabric : 
```console
git clone https://github.com/stratum/fabric-tna.git
git checkout tags/1.1.0
sudo make fabric-v1model
sudo make pipeconf
sudo make build PROFILES=fabric-v1model
sudo make pipeconf-install ONOS_HOST=localhost  # if onos is in the same machine, if not replace localhost with the ip address of the onos machine
make netcfg ONOS_HOST=localhost  # push the netcfg
```


bmv2 netcfg example :
```json
{
  "devices": {
    "device:switch-1": {
      "basic": {
        "managementAddress": "grpc://ip_for_switch_1:9559?device_id=1",
        "driver": "stratum-bmv2",
        "pipeconf": "org.stratumproject.fabric.bmv2"
      }
    },
    "device:switch-2": {
      "basic": {
        "managementAddress": "grpc://ip_for_switch_2:9559?device_id=1",
        "driver": "stratum-bmv2",
        "pipeconf": "org.stratumproject.fabric.bmv2"
      }
    }
  }
}
```


