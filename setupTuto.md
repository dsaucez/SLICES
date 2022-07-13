# Instructions
This tutorial, will cover how to setup a software switch setup, managed by onos

## Vagrant + Ansible controller

Before we start we need to setup vagrant, which will be our tool to setup vms and manage our developper envirenement.

start by cloning the repo of this tutorial in your working envirement
```console
git clone ...
```

### Virtualbox installation
#### On Linux (such as Fedora)
- Download .run file for linux-64bit from https://www.virtualbox.org/wiki/Testbuilds
- sh \<linux-64bit file\>.run
- To verify that virtualbox is installed correctly, use this command : 
```console
vboxmanage --version
```

#### On Windows and MacOS
- Follow instructions on https://www.virtualbox.org/manual/ch02.html


### Vagarant Installation

From the website below, download and install the appropriate version of vagrant depending on your OS.

https://www.vagrantup.com/downloads

to verify that vagrant is installed correctly, use this command: 
```console
vagrant -v
```

### Ansible Setup



## Start the environment
  
Update environment variable VAGRANT_DEFAULT_PROVIDER with following command in each terminal: 
  ``` console
  export VAGRANT_DEFAULT_PROVIDER=
  ```

in a seperate terminal type these commands to start the first switch :

```console
export VAGRANT_DEFAULT_PROVIDER=
cd switch1
vagrant up
```

start a new  terminal and type these commands to start the second switch :

```console
export VAGRANT_DEFAULT_PROVIDER=
cd switch2
vagrant up
```

Above commands start 2 vms with bmv2 software switch installed on both of them.

Now we will use Ansible to start the stratum switches. its very simple you just have to go to the ansible controller vm.
  
start a new  terminal and type these commands to start the ansible controller :
```console
export VAGRANT_DEFAULT_PROVIDER=
cd ansiblecontroller
vagrant up
vagrant ssh
```
