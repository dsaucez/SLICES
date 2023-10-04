all:
  hosts:
    ${COMPUTE}:
      xx-name: ${COMPUTE_NAME}
      xx-local-ip: ${COMPUTE_IP}
    ${MASTER}:
      xx-name: ${MASTER_NAME}
      xx-local-ip: ${MASTER_IP}
    ${OPENVPN}:
      xx-name: ${OPENVPN_NAME}
      xx-local-ip: ${OPENVPN_IP}
    ${HAPROXY}:
      xx-name: ${HAPROXY_NAME}
      xx-local-ip: ${HAPROXY_IP}
      xx-port: 6443
  children:
    computes:
      hosts:
        ${COMPUTE}:
    masters:
      hosts:
        ${MASTER}:
    switches:
      hosts:
    openvpn:
      hosts:
        ${OPENVPN}:
    HAproxy:
      hosts:
        ${HAPROXY}:
