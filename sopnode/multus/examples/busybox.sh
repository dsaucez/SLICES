#!/bin/bash

if test $# -lt 3; then
  echo "Usage : busybox.sh <Host network interface name> <new interface name prefix> <namespace>"
  exit 1
else
  export NODE_NETIF=$1 #NIC on host machine to be used for multus
  echo "Host network interface : $NODE_NETIF"
  export IFNAME=$2 #prefix to be assigned to name of created multus interface
  echo "New interface name prefix : $IFNAME"
  export NS=$3 # Desired namespace of the newly created multus interface
  echo "Namespace : $NS"
  envsubst < busybox-namespace.yaml | kubectl create -f -
  envsubst < ../p4-network.yaml | kubectl -n$NS create -f -
  kubectl -n${NS} delete net-attach-def p4-macvlan-${IFNAME}
  kubectl delete namespaces ${NS}
fi
