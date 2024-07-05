name=vm_group$1
export IP1=$(get-vm-ip ${name}_1)
export IP2=$(get-vm-ip ${name}_2)
export IP3=$(get-vm-ip ${name}_3)
export IP4=$(get-vm-ip ${name}_4)

cat <<EOF
all:
  hosts:
    $IP1:
      xx-name: $IP1
      xx-local-ip: $IP1
      xx-vwall: node1
    $IP2:
      xx-name: $IP2
      xx-local-ip: $IP2
      xx-vwall: node2
    $IP3:
      xx-name: $IP3
      xx-local-ip: $IP3
      xx-vwall: node3
    $IP4:
      xx-name: $IP4
      xx-local-ip: $IP4
      xx-vwall: node4
  children:
    computes:
      hosts:
        $IP1:
        $IP2:
        $IP3:
        $IP4:
    masters:
      hosts:
        $IP1:
EOF
