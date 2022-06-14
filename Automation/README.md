Material related to the evaluation of automation tools in the context of the SLICES project.

# BMV2

## BMV2 INSTALLATION 
Steps to initiate an instant with BMV2 and stratum. 
these instruction were tested on a GCP instance running Ubuntu 20.04 TLS

general dependecies : `apt-get install libboost-dev libboost-system-dev libboost-thread-dev`

### bazel:
```console
sudo apt install apt-transport-https curl gnupg
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt update && sudo apt install bazel
```
### protobuf:
```console
git clone --depth=1 -b v3.18.1 https://github.com/google/protobuf.git
cd protobuf/
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
```
### grpc
```console
git clone --depth=1 -b v1.43.2 https://github.com/google/grpc.git
cd grpc
git submodule update --init --recursive
mkdir build 
cd build
cmake ..
make 
sudo make install
```
### sysrepo :
Dependecies : `build-essential cmake libpcre3-dev libavl-dev libev-dev libprotobuf-c-dev protobuf-c-compiler`
##### libyang
```console
git clone --depth=1 -b v0.16-r1 https://github.com/CESNET/libyang.git
cd libyang
mkdir build
cd build
cmake ..
make
sudo make install
```
now we install sysrepo
```console
git clone --depth=1 -b v0.7.5 https://github.com/sysrepo/sysrepo.git
cd sysrepo
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=Off -DCALL_TARGET_BINS_DIRECTLY=Off ..
make
sudo make install
```



cd /usr/local/src/
wget https://www.openssl.org/source/openssl-1.0.2o.tar.gz
tar -xf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
make 
make test
make install 

apt-get install -y pkg-config
sudo apt-get install libssl-dev

### PI :
```console
git clone https://github.com/p4lang/PI.git
cd PI
git submodule update --init --recursive
./autogen.sh
./configure --with-proto --without-internal-rpc --without-cli --without-bmv2 --with-sysrepo
make
sudo make install
sudo ldconfig
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
sudo make install  # if you need to install bmv2
```
### p4c (tested only for ubuntu TLS 20.04):
```console
. /etc/os-release
echo "deb http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/home:p4lang.list
curl -L "http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -
sudo apt-get update
sudo apt install p4lang-p4c
```
### docker ubuntu
### bmv2 stratum
```console
git clone https://github.com/stratum/stratum.git
cd stratum
sudo chmod 666 /var/run/docker.sock
./setup_dev_env.sh
#now you are inside the container
bazel build //stratum/hal/bin/bmv2:stratum_bmv2_deb
cp -f /stratum/bazel-bin/stratum/hal/bin/bmv2/stratum_bmv2_deb.deb /stratum/
[sudo] apt-get update
[sudo] apt-get install -y --reinstall ./stratum_bmv2_deb.deb
stratum_bmv2 \
    -chassis_config_file=/etc/stratum/chassis_config.pb.txt \
    -bmv2_log_level=debug
```


sudo bazel-bin/stratum/hal/bin/bmv2/stratum_bmv2 \
    -persistent_config_dir=/tmp/ \
    -chassis_config_file=${BMV2_DIR}/chassis_config.pb.txt \
    -initial_pipeline=${BMV2_DIR}/dummy.json \
    -forwarding_pipeline_configs_file=/tmp/bmv2_pipeline_cfg \
    -bmv2_log_level=debug \

## ONOS
```bash
docker run --rm --tty --detach --publish 8181:8181 --publish 8101:8101 --publish 5005:5005 --publish 830:830 --name onos onosproject/onos:2.7.0
```
To access ONOS CLI: `ssh -p 8101 onos@localhost` with the same credentials `onos/rocks`.

Activate bmv2 drivers via the ONOS CLI with

```bash
onos@root > app activate org.onosproject.drivers.bmv2
```


to start a simple-switch : 

cd bmv2 
cd targets
cd simple_switch
sudo ./simple_switch -i 0@ens4 -i 1@ens5 ../../../prog.json

and in another terminal you do : 

cd tools 
./runtime_CLI.py --thrift-port 9090

fabric-tna :
