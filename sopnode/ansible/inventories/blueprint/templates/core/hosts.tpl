all:
  hosts:
    ${CORE_COMPUTE}:
      xx-name: ${CORE_COMPUTE_NAME}
      xx-local-ip: ${CORE_COMPUTE_IP}
    ${CORE_MASTER}:
      xx-name: ${CORE_MASTER_NAME}
      xx-local-ip: ${CORE_MASTER_IP}
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
        ${CORE_COMPUTE}:
    masters:
      hosts:
        ${CORE_MASTER}:
    switches:
      hosts:
    openvpn:
      hosts:
        ${OPENVPN}:
    HAproxy:
      hosts:
        ${HAPROXY}:
