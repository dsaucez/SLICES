# Blueprint Monitoring Charts

This repository contains Ansible scripts and configurations for setting up a comprehensive monitoring solution using Prometheus, Promtail, Node Exporter, Cadvisor, and Kube State Metrics.

## Table of Contents

- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Project Structure

The repository is structured as follows:
```
blueprint-monitoring-charts/
├── prometheus/
├── promtail/
├── node-exporter/
├── cadvisor/
├── kube-state-metrics/
├── bp-monitoring.yml
└── hosts
```

- **prometheus/**: Contains configurations and setup files for Prometheus.
- **promtail/**: Contains configurations and setup files for Promtail.
- **node-exporter/**: Contains configurations and setup files for Node Exporter.
- **cadvisor/**: Contains configurations and setup files for cAdvisor.
- **kube-state-metrics/**: Contains configurations and setup files for Kube State Metrics.
- **bp-monitoring.yml**: Ansible playbook for deploying the monitoring stack.
- **hosts**: Inventory file for Ansible.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Ansible installed on your local machine.
- Access to the servers where you want to deploy the monitoring stack.
- SSH access to the target servers configured in the `hosts` file.
- K8s is installed and configured on the target servers. The deployments will be done in the "default" namespace

## Installation

1. Clone the repository to your local machine and cd to the directory:

```bash
cd blueprint-monitoring-charts
```

2. Update the hosts file with the target server details. The servers should be reachable from the deployment node and accessible without requiring password (e.g. rsa-key based access)

3. Update the respective vars files for each ansible role.
 - prometheus/vars/main.yml
``` 
remote_write_address: "10.64.45.85"   # The address where a central prometheus instance is configured for collecting information from all the clusters
remote_write_port: "9090"             # The port on which the central prometheus instance is listening to
remote_write_user: "admin"            # The username used to access the remote prometheus instance
remote_write_pass: "test1234"         # The password used to access the remote prometheus instance
remote_data_label: "uth"              # A label for annotating the data generated within the k8s cluster, before pushing them to the central prometheus instance
```
 - promtail/vars/main.yml
```
loki_address: 10.64.45.125           # A central Grafana LOKI address used to collect all the logs from the different clusters
loki_port: 3100                      # The port on which the central LOKI instance is listening to
```

4. Run the Ansible playbook to deploy the monitoring stack
```
ansible-playbook -i hosts bp-monitoring.yml
```
