# Instructions
This tutorial, will cover how to setup a software switch setup, managed by onos

## Vagrant + Ansible controller

Before we start we need to setup vagrant, which will be our tool to setup vms and manage our developper envirenement.

start by cloning the repo of this tutorial in your working envirement
```console
git clone ...
```

### Vagarant Installation

From the website below, download and install the appropriate version of vagrant depending on your OS.

https://www.vagrantup.com/downloads

to verify that vagrant is installed correctly, use this command: 
```console
vagrant -v
```

### Ansible Setup



## Start the envirement

in a seperate terminal type these commands to start the first switch :

```console
cd switch1
vagrant up
vagrant ssh
```

start a new  terminal and type these commands to start the second switch :

```console
cd switch2
vagrant up
vagrant ssh
```

these commands starts 2 vms with bmv2 software switch installed on both of them.

Now we will use Ansible to start the stratum switches. its very simple you just have to go to the ansible controller vm.

