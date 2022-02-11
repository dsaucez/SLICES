## admin@sopnode-sw1-drac.inria.fr
```bash
ONIE:/ # onie-syseeprom 
TlvInfo Header:
   Id String:    TlvInfo
   Version:      1
   Total Length: 173
TLV Name             Code Len Value
-------------------- ---- --- -----
Product Name         0x21  22 Wedge100BF-32QS-O-AC-F
Part Number          0x22  13 F0PEC7632000S
Serial Number        0x23  10 AK49040479
Base MAC Address     0x24   6 90:3C:B3:4C:B3:0E
Manufacture Date     0x25  19 12/04/2020 14:57:54
Label Revision       0x27   3 R01
Platform Name        0x28  29 x86_64-accton_wedge100bf_32qs
MAC Addresses        0x2A   2 140
Manufacturer         0x2B   7 Joytech
Country Code         0x2C   2 CN
Vendor Name          0x2D   8 Edgecore
Diag Version         0x2E   7 0.0.1.5
ONIE Version         0x29  13 2018.05.00.10
CRC-32               0xFE   4 0x62EC3A20
Checksum is valid.
```

## admin@sopnode-sw2-drac.inria.fr
```bash
ONIE:/ # onie-syseeprom 
TlvInfo Header:
   Id String:    TlvInfo
   Version:      1
   Total Length: 174
TLV Name             Code Len Value
-------------------- ---- --- -----
Product Name         0x21  21 Wedge100BF-32X-O-AC-F
Part Number          0x22  13 FP3ZZ7632051A
Serial Number        0x23  10 AK22063451
Base MAC Address     0x24   6 04:F8:F8:DD:26:1C
Manufacture Date     0x25  19 06/18/2020 10:54:50
Label Revision       0x27   4 R01C
Platform Name        0x28  31 x86_64-accton_wedge100bf_32x-r0
ONIE Version         0x29  13 2018.05.00.09
MAC Addresses        0x2A   2 140
Manufacturer         0x2B   6 Accton
Country Code         0x2C   2 TW
Vendor Name          0x2D   8 Edgecore
Diag Version         0x2E   7 0.0.1.5
CRC-32               0xFE   4 0x345F521F
Checksum is valid.
ONIE:/ # 
```

### Running stratum
```bash
root@sopnode-sw2-eth0:~# apt update
```

```bash
root@sopnode-sw2-eth0:~# apt install git -y
```

```bash
root@sopnode-sw2-eth0:~# git clone https://github.com/stratum/stratum.git
Cloning into 'stratum'...
remote: Enumerating objects: 21720, done.
remote: Counting objects: 100% (4476/4476), done.
remote: Compressing objects: 100% (2020/2020), done.
remote: Total 21720 (delta 2852), reused 3617 (delta 2444), pack-reused 17244
Receiving objects: 100% (21720/21720), 9.39 MiB | 7.95 MiB/s, done.
Resolving deltas: 100% (15195/15195), done.
root@sopnode-sw2-eth0:~# cd stratum/
root@sopnode-sw2-eth0:~/stratum# 
```

```bash
root@sopnode-sw2-eth0:~/stratum# export DOCKER_IMAGE_TAG=21.12-9.5.0
root@sopnode-sw2-eth0:~/stratum# docker pull stratumproject/stratum-bfrt:${DOCKER_IMAGE_TAG}
21.12-9.5.0: Pulling from stratumproject/stratum-bfrt
f3785b3e7e79: Pull complete 
3faf46a824c5: Pull complete 
6eab94b26aa9: Download complete 
6eab94b26aa9: Pull complete 
e1cea7a666d6: Pull complete 
Digest: sha256:8beb860d6a0d6dffef1d738a1f5f0c2f70899382acb7ec630f57bb44b1b36c06
Status: Downloaded newer image for stratumproject/stratum-bfrt:21.12-9.5.0
docker.io/stratumproject/stratum-bfrt:21.12-9.5.0
root@sopnode-sw2-eth0:~/stratum#
```

```bash
root@sopnode-sw2-eth0:~/stratum# ./stratum/hal/bin/barefoot/docker/start-stratum-container.sh -bf_switchd_cfg=/usr/share/stratum/tofino_skip_p4.conf -enable_onlp=false
++ uname -r
++ uname -r
+ docker run -it --rm --privileged -v /dev:/dev -v /sys:/sys -v /lib/modules/4.14.49-OpenNetworkLinux:/lib/modules/4.14.49-OpenNetworkLinux --env PLATFORM=x86-64-accton-wedge100bf-32x-r0 --network host -v /lib/x86_64-linux-gnu/libonlp-platform-defaults.so:/lib/x86_64-linux-gnu/libonlp-platform-defaults.so -v /lib/x86_64-linux-gnu/libonlp-platform-defaults.so.1:/lib/x86_64-linux-gnu/libonlp-platform-defaults.so.1 -v /lib/x86_64-linux-gnu/libonlp-platform.so:/lib/x86_64-linux-gnu/libonlp-platform.so -v /lib/x86_64-linux-gnu/libonlp-platform.so.1:/lib/x86_64-linux-gnu/libonlp-platform.so.1 -v /lib/x86_64-linux-gnu/libonlp.so:/lib/x86_64-linux-gnu/libonlp.so -v /lib/x86_64-linux-gnu/libonlp.so.1:/lib/x86_64-linux-gnu/libonlp.so.1 -v /lib/platform-config:/lib/platform-config -v /etc/onl:/etc/onl -v /var/log:/var/log/stratum stratumproject/stratum-bfrt:21.12-9.5.0 -bf_switchd_cfg=/usr/share/stratum/tofino_skip_p4.conf -enable_onlp=false
Mounting hugepages...
bf_kdrv_mod found! Unloading first...
loading bf_kdrv_mod...
I20220210 16:02:48.764670     1 logging.cc:63] Stratum version deddede3f8c5c643c21f8ece5f3c453e3ec659fd built at 2021-12-13T22:21:19+00:00 on host 46533c884405 by user brian.
I20220210 16:02:48.765215     1 bf_sde_wrapper.cc:1737] bf_sysfs_fname: /sys/class/bf/bf0/device/dev_add
Install dir: /usr (0x5622d58e0020)
bf_switchd: system services initialized
bf_switchd: loading conf_file /usr/share/stratum/tofino_skip_p4.conf...
bf_switchd: processing device configuration...
Configuration for dev_id 0
  Family        : Tofino
  pci_sysfs_str : /sys/devices/pci0000:00/0000:00:03.0/0000:05:00.0
  pci_domain    : 0
  pci_bus       : 5
  pci_fn        : 0
  pci_dev       : 0
  pci_int_mode  : 1
  sbus_master_fw: /usr/
  pcie_fw       : /usr/
  serdes_fw     : /usr/
  sds_fw_path   : /usr/
  microp_fw_path:
bf_switchd: processing P4 configuration...
P4 profile for dev_id 0
  p4_name: dummy
    libpd:
    libpdthrift:
    context:
    config:
  Agent[0]: /usr/lib/libpltfm_mgr.so
  diag:
  accton diag:
  non_default_port_ppgs: 0
  SAI default initialize: 1
bf_switchd: library /usr/lib/libpltfm_mgr.so loaded
bf_switchd: agent[0] initialized
Health monitor started
Operational mode set to ASIC
Initialized the device types using platforms infra API
ASIC detected at PCI /sys/class/bf/bf0/device
ASIC pci device id is 16
bf_switchd: drivers initialized
Skipping P4 program load for dev_id 0
Setting core_pll_ctrl0=cd44cbfe

bf_switchd: dev_id 0 initialized

bf_switchd: initialized 1 devices
Skip p4 lib init
Skip mav diag lib init
bf_switchd: spawning cli server thread
bf_switchd: running in background; driver shell is disabled
bf_switchd: server started - listening on port 9999
I20220210 16:02:57.728843     1 bf_sde_wrapper.cc:1747] switchd started successfully
W20220210 16:02:57.728976     1 credentials_manager.cc:44] Using insecure server credentials
I20220210 16:02:57.729300     1 hal.cc:127] Setting up HAL in COLDBOOT mode...
I20220210 16:02:57.729372     1 config_monitoring_service.cc:94] Pushing the saved chassis config read from /etc/stratum/x86-64-accton-wedge100bf-32x-r0/chassis_config.pb.txt...
I20220210 16:02:57.733150     1 bfrt_switch.cc:322] Chassis config verified successfully.
E20220210 16:02:57.733759     1 phal.cc:96] No phal_config_file specified and no switch configurator found! This is probably not what you want. Did you forget to specify any '--define phal_with_*=true' Bazel flags?
I20220210 16:02:57.734702     1 attribute_database.cc:210] PhalDB service is listening to localhost:28003...
I20220210 16:02:57.734758     1 bf_chassis_manager.cc:1415] Successfully registered port status notification callback.
I20220210 16:02:57.755875     1 bf_chassis_manager.cc:111] Added port 1 in node 1 (SDK Port 132).
I20220210 16:02:57.755916     1 bf_chassis_manager.cc:147] Enabled port 1 in node 1 (SDK Port 132).
I20220210 16:02:57.776587     1 bf_chassis_manager.cc:111] Added port 2 in node 1 (SDK Port 140).
I20220210 16:02:57.776621     1 bf_chassis_manager.cc:147] Enabled port 2 in node 1 (SDK Port 140).
I20220210 16:02:57.797338     1 bf_chassis_manager.cc:111] Added port 3 in node 1 (SDK Port 148).
I20220210 16:02:57.797369     1 bf_chassis_manager.cc:147] Enabled port 3 in node 1 (SDK Port 148).
I20220210 16:02:57.817915     1 bf_chassis_manager.cc:111] Added port 4 in node 1 (SDK Port 156).
I20220210 16:02:57.817947     1 bf_chassis_manager.cc:147] Enabled port 4 in node 1 (SDK Port 156).
I20220210 16:02:57.838476     1 bf_chassis_manager.cc:111] Added port 5 in node 1 (SDK Port 164).
I20220210 16:02:57.838506     1 bf_chassis_manager.cc:147] Enabled port 5 in node 1 (SDK Port 164).
I20220210 16:02:57.859045     1 bf_chassis_manager.cc:111] Added port 6 in node 1 (SDK Port 172).
I20220210 16:02:57.859077     1 bf_chassis_manager.cc:147] Enabled port 6 in node 1 (SDK Port 172).
I20220210 16:02:57.879637     1 bf_chassis_manager.cc:111] Added port 7 in node 1 (SDK Port 180).
I20220210 16:02:57.879668     1 bf_chassis_manager.cc:147] Enabled port 7 in node 1 (SDK Port 180).
I20220210 16:02:57.900238     1 bf_chassis_manager.cc:111] Added port 8 in node 1 (SDK Port 188).
I20220210 16:02:57.900271     1 bf_chassis_manager.cc:147] Enabled port 8 in node 1 (SDK Port 188).
I20220210 16:02:57.922363     1 bf_chassis_manager.cc:111] Added port 9 in node 1 (SDK Port 56).
I20220210 16:02:57.922394     1 bf_chassis_manager.cc:147] Enabled port 9 in node 1 (SDK Port 56).
I20220210 16:02:57.944461     1 bf_chassis_manager.cc:111] Added port 10 in node 1 (SDK Port 48).
I20220210 16:02:57.944501     1 bf_chassis_manager.cc:147] Enabled port 10 in node 1 (SDK Port 48).
I20220210 16:02:57.966981     1 bf_chassis_manager.cc:111] Added port 11 in node 1 (SDK Port 40).
I20220210 16:02:57.967053     1 bf_chassis_manager.cc:147] Enabled port 11 in node 1 (SDK Port 40).
I20220210 16:02:57.989817     1 bf_chassis_manager.cc:111] Added port 12 in node 1 (SDK Port 32).
I20220210 16:02:57.989852     1 bf_chassis_manager.cc:147] Enabled port 12 in node 1 (SDK Port 32).
I20220210 16:02:58.011963     1 bf_chassis_manager.cc:111] Added port 13 in node 1 (SDK Port 24).
I20220210 16:02:58.011998     1 bf_chassis_manager.cc:147] Enabled port 13 in node 1 (SDK Port 24).
I20220210 16:02:58.034111     1 bf_chassis_manager.cc:111] Added port 14 in node 1 (SDK Port 16).
I20220210 16:02:58.034147     1 bf_chassis_manager.cc:147] Enabled port 14 in node 1 (SDK Port 16).
I20220210 16:02:58.056254     1 bf_chassis_manager.cc:111] Added port 15 in node 1 (SDK Port 8).
I20220210 16:02:58.056289     1 bf_chassis_manager.cc:147] Enabled port 15 in node 1 (SDK Port 8).
I20220210 16:02:58.078405     1 bf_chassis_manager.cc:111] Added port 16 in node 1 (SDK Port 0).
I20220210 16:02:58.078441     1 bf_chassis_manager.cc:147] Enabled port 16 in node 1 (SDK Port 0).
I20220210 16:02:58.100594     1 bf_chassis_manager.cc:111] Added port 17 in node 1 (SDK Port 4).
I20220210 16:02:58.100631     1 bf_chassis_manager.cc:147] Enabled port 17 in node 1 (SDK Port 4).
I20220210 16:02:58.122853     1 bf_chassis_manager.cc:111] Added port 18 in node 1 (SDK Port 12).
I20220210 16:02:58.122889     1 bf_chassis_manager.cc:147] Enabled port 18 in node 1 (SDK Port 12).
I20220210 16:02:58.145084     1 bf_chassis_manager.cc:111] Added port 19 in node 1 (SDK Port 20).
I20220210 16:02:58.145124     1 bf_chassis_manager.cc:147] Enabled port 19 in node 1 (SDK Port 20).
I20220210 16:02:58.167384     1 bf_chassis_manager.cc:111] Added port 20 in node 1 (SDK Port 28).
I20220210 16:02:58.167426     1 bf_chassis_manager.cc:147] Enabled port 20 in node 1 (SDK Port 28).
I20220210 16:02:58.189661     1 bf_chassis_manager.cc:111] Added port 21 in node 1 (SDK Port 36).
I20220210 16:02:58.189710     1 bf_chassis_manager.cc:147] Enabled port 21 in node 1 (SDK Port 36).
I20220210 16:02:58.211856     1 bf_chassis_manager.cc:111] Added port 22 in node 1 (SDK Port 44).
I20220210 16:02:58.211892     1 bf_chassis_manager.cc:147] Enabled port 22 in node 1 (SDK Port 44).
I20220210 16:02:58.234105     1 bf_chassis_manager.cc:111] Added port 23 in node 1 (SDK Port 52).
I20220210 16:02:58.234145     1 bf_chassis_manager.cc:147] Enabled port 23 in node 1 (SDK Port 52).
I20220210 16:02:58.261600     1 bf_chassis_manager.cc:111] Added port 24 in node 1 (SDK Port 60).
I20220210 16:02:58.261682     1 bf_chassis_manager.cc:147] Enabled port 24 in node 1 (SDK Port 60).
I20220210 16:02:58.283118     1 bf_chassis_manager.cc:111] Added port 25 in node 1 (SDK Port 184).
I20220210 16:02:58.283162     1 bf_chassis_manager.cc:147] Enabled port 25 in node 1 (SDK Port 184).
I20220210 16:02:58.303781     1 bf_chassis_manager.cc:111] Added port 26 in node 1 (SDK Port 176).
I20220210 16:02:58.303822     1 bf_chassis_manager.cc:147] Enabled port 26 in node 1 (SDK Port 176).
I20220210 16:02:58.324458     1 bf_chassis_manager.cc:111] Added port 27 in node 1 (SDK Port 168).
I20220210 16:02:58.324499     1 bf_chassis_manager.cc:147] Enabled port 27 in node 1 (SDK Port 168).
I20220210 16:02:58.345228     1 bf_chassis_manager.cc:111] Added port 28 in node 1 (SDK Port 160).
I20220210 16:02:58.345266     1 bf_chassis_manager.cc:147] Enabled port 28 in node 1 (SDK Port 160).
I20220210 16:02:58.365962     1 bf_chassis_manager.cc:111] Added port 29 in node 1 (SDK Port 144).
I20220210 16:02:58.366003     1 bf_chassis_manager.cc:147] Enabled port 29 in node 1 (SDK Port 144).
I20220210 16:02:58.386673     1 bf_chassis_manager.cc:111] Added port 30 in node 1 (SDK Port 152).
I20220210 16:02:58.386715     1 bf_chassis_manager.cc:147] Enabled port 30 in node 1 (SDK Port 152).
I20220210 16:02:58.407380     1 bf_chassis_manager.cc:111] Added port 31 in node 1 (SDK Port 128).
I20220210 16:02:58.407428     1 bf_chassis_manager.cc:147] Enabled port 31 in node 1 (SDK Port 128).
I20220210 16:02:58.428172     1 bf_chassis_manager.cc:111] Added port 32 in node 1 (SDK Port 136).
I20220210 16:02:58.428215     1 bf_chassis_manager.cc:147] Enabled port 32 in node 1 (SDK Port 136).
I20220210 16:02:58.428283     1 bfrt_switch.cc:61] Chassis config pushed successfully.
I20220210 16:02:58.440557     1 p4_service.cc:121] Pushing the saved forwarding pipeline configs read from /etc/stratum/pipeline_cfg.pb.txt...
W20220210 16:02:58.440691     1 p4_service.cc:142] Empty forwarding pipeline configs file: /etc/stratum/pipeline_cfg.pb.txt.
E20220210 16:02:58.441041     1 hal.cc:220] Stratum external facing services are listening to 0.0.0.0:9339, 0.0.0.0:9559, localhost:9559...
```

### Running ONOS
```bash
root@sopnode-sw2-eth0:~# docker run \
     --rm \
     --tty \
     --detach \
     --publish 8181:8181 \
     --publish 8101:8101 \
     --publish 5005:5005 \
     --publish 830:830 \
     --name onos \
     onosproject/onos
Unable to find image 'onosproject/onos:latest' locally
latest: Pulling from onosproject/onos
7595c8c21622: Pull complete 
d13af8ca898f: Pull complete 
70799171ddba: Pull complete 
b6c12202c5ef: Pull complete 
a3caae5bc1ad: Pull complete 
d9e716dbeb75: Pull complete 
449c5b8e7d46: Pull complete 
Digest: sha256:93f34efc7ba1943bcc9107428ca92aa80610ea872af44b83574f77adc4fc5c8e
Status: Downloaded newer image for onosproject/onos:latest
e5eca3a1fa3dcab0e96e8e8aefa6182a440a088766edbea5ab7cf9efb2136df2
root@sopnode-sw2-eth0:~#
```

Remote access to ONOS GUI
```bash
hodhr:~ dsaucez$ ssh -A -i ~/.ssh/id_rsa_silecs -L 8181:localhost:8181 root@sopnode-sw2-eth0.inria.fr
Enter passphrase for key '/Users/dsaucez/.ssh/id_rsa': 
Linux sopnode-sw2-eth0 4.14.49-OpenNetworkLinux #1 SMP Wed Oct 27 20:10:54 UTC 2021 x86_64
Last login: Thu Feb 10 16:09:35 2022 from 138.96.0.59
root@sopnode-sw2-eth0:~# 
```

You should be able to access `http://localhost:8181/onos/ui/login.html` from your browser (`user:password`: `onos:rocks`).

From there, activate `org.onosproject.drivers.barefoot` application (`Menu/Applications/`) or from the onos cli if installed

```bash
onos> app activate org.onosproject.drivers.barefoot
```


### Define pipeconf
```bash
root@sopnode-sw2-eth0:~# git clone https://github.com/opencord/fabric-tofino.git
Cloning into 'fabric-tofino'...
remote: Enumerating objects: 403, done.
remote: Counting objects: 100% (403/403), done.
remote: Compressing objects: 100% (247/247), done.
remote: Total 403 (delta 182), reused 322 (delta 101), pack-reused 0
Receiving objects: 100% (403/403), 1.33 MiB | 0 bytes/s, done.
Resolving deltas: 100% (182/182), done.
root@sopnode-sw2-eth0:~# cd fabric-tofino/
root@sopnode-sw2-eth0:~/fabric-tofino# 
```

03b743e9c56948a06d9236addc2fb47b  /root/fabric-tofino/target/fabric-tofino-1.1.1-SNAPSHOT.oar
