all:
  hosts:
    ${RAN_MASTER}:
      xx-name: ${RAN_MASTER_NAME}
      xx-local-ip: ${RAN_MASTER_IP}
  children:
    computes:
      hosts:
        ${RAN_MASTER}:
    masters:
      hosts:
        ${RAN_MASTER}:
