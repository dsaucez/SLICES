all:
  hosts:
    ${MASTER}:
      xx-name: ${MASTER_NAME}
      xx-local-ip: ${MASTER_IP}
  children:
    computes:
      hosts:
        ${MASTER}:
    masters:
      hosts:
        ${MASTER}:
