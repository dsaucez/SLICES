# Ansible Playbooks for Grafana, Prometheus, and Loki #

This repository contains Ansible playbooks and roles to automate the deployment of Grafana, Prometheus, and Loki on multiple servers.

### Directory Structure ###
```
grafana_loki_prometheus/
├── grafana/
│   ├── tasks/
│   │   └── main.yml
│   ├── templates/
│   │   ├── grafana.list.j2
│   │   └── grafana.ini.j2
│   └── vars/
│       └── main.yml
├── prometheus/
│   ├── tasks/
│   │   └── main.yml
│   ├── templates/
│   │   ├── prometheus.yml.j2
│   │   ├── prometheus.service.j2
│   └── vars/
│       └── main.yml
├── loki/
│   ├── tasks/
│   │   └── main.yml
│   ├── templates/
│   │   ├── loki-local-config.yaml.j2
│   │   └── loki.service.j2
│   └── vars/
│       └── main.yml
├── site.yml
└── hosts
```

## File Explanations ##
##### lpg.yml #####

This is the main playbook that includes all the roles needed for deploying Grafana, Prometheus, and Loki. It runs these roles on all specified hosts.

```
- hosts: all
  become: yes
  roles:
    - grafana
    - prometheus
    - loki
```

##### hosts #####

This inventory file lists the target servers where the playbooks will be executed. It specifies the server addresses and the SSH key to use for connecting.

```
[servers]
server1 ansible_host=your_server_ip_1 ansible_user=your_user ansible_ssh_private_key_file=/path/to/your/private/key
server2 ansible_host=your_server_ip_2 ansible_user=your_user ansible_ssh_private_key_file=/path/to/your/private/key
````

#### grafana/ ####
#### grafana/tasks/main.yml ####

This playbook installs and configures Grafana on the target servers:
 * Installs dependencies.
 * Adds the Grafana GPG key and repository.
 * Installs Grafana.
 * Configures Grafana using a template.
 * Starts and enables the Grafana service.
```
- name: Install dependencies
  apt:
    name:
      - gnupg2
      - apt-transport-https
      - software-properties-common
      - wget
    state: present

- name: Add Grafana GPG key
  get_url:
    url: https://packages.grafana.com/gpg.key
    dest: /tmp/grafana.key

- name: Add Grafana APT repository
  shell: |
    cat /tmp/grafana.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/grafana.gpg > /dev/null
    echo 'deb [signed-by=/etc/apt/trusted.gpg.d/grafana.gpg] https://packages.grafana.com/oss/deb stable main' | tee /etc/apt/sources.list.d/grafana.list

- name: Update APT cache
  apt:
    update_cache: yes

- name: Install Grafana
  apt:
    name: grafana
    state: present

- name: Configure Grafana
  template:
    src: grafana.ini.j2
    dest: /etc/grafana/grafana.ini

- name: Start and enable Grafana service
  systemd:
    name: grafana-server
    state: started
    enabled: yes
```

#### grafana/templates/grafana.list.j2 ####

This template file adds the Grafana APT repository.

```
deb [signed-by=/etc/apt/trusted.gpg.d/grafana.gpg] https://packages.grafana.com/oss/deb stable main
```

#### grafana/templates/grafana.ini.j2 ####

This template file configures Grafana to bind to all interfaces and sets the HTTP port to 3000.

```
[server]
http_addr = 0.0.0.0
http_port = 3000
```

#### grafana/vars/main.yml ####

Variables for the Grafana role. Currently empty but can be used to store configuration variables if needed.

#### prometheus/ ####
#### prometheus/tasks/main.yml ####

This playbook installs and configures Prometheus on the target servers: 
* Creates Prometheus user and group.
* Creates necessary directories.
* Downloads and installs Prometheus.
* Sets permissions for directories.
* Installs Apache2 utils for htpasswd.
* Configures Prometheus using templates.
* Creates and configures the Prometheus systemd service.
* Starts and enables the Prometheus service.

```
- name: Create Prometheus group and user
  group:
    name: prometheus
    system: yes

- name: Create Prometheus user
  user:
    name: prometheus
    shell: /sbin/nologin
    group: prometheus
    system: yes

- name: Create directories for Prometheus
  file:
    path: "{{ item }}"
    state: directory
    owner: prometheus
    group: prometheus
    mode: 0775
  with_items:
    - /var/lib/prometheus
    - /etc/prometheus
    - /etc/prometheus/rules
    - /etc/prometheus/rules.d
    - /etc/prometheus/files_sd

- name: Download Prometheus
  shell: |
    curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
    tar xvf prometheus*.tar.gz
    mv prometheus*/prometheus prometheus*/promtool /usr/local/bin/
    mv prometheus*/consoles prometheus*/console_libraries prometheus*/prometheus.yml /etc/prometheus/

- name: Set permissions for Prometheus directories
  file:
    path: "{{ item }}"
    owner: prometheus
    group: prometheus
    recurse: yes
  with_items:
    - /etc/prometheus/rules
    - /etc/prometheus/rules.d
    - /etc/prometheus/files_sd
    - /var/lib/prometheus

- name: Install Apache2 utils
  apt:
    name: apache2-utils
    state: present

- name: Set up Prometheus basic auth
  shell: htpasswd -nbB {{ prometheus_basic_auth_user }} {{ prometheus_basic_auth_password }} > /etc/prometheus/.htpasswd

- name: Configure Prometheus
  template:
    src: prometheus.yml.j2
    dest: /etc/prometheus/prometheus.yml

- name: Create systemd service for Prometheus
  template:
    src: prometheus.service.j2
    dest: /etc/systemd/system/prometheus.service

- name: Reload systemd
  systemd:
    daemon_reload: yes

- name: Start and enable Prometheus service
  systemd:
    name: prometheus
    state: started
    enabled: yes
```

#### prometheus/templates/prometheus.yml.j2 ####

This template configures Prometheus, including the global settings, alerting configuration, and scrape configurations. It includes basic authentication for the web interface.

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    monitor: 'gateway'

alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files: []

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
    basic_auth:
      username: '{{ prometheus_basic_auth_user }}'
      password: '{{ prometheus_basic_auth_password }}'
```

#### prometheus/templates/prometheus.service.j2 ####

This template creates the systemd service file for Prometheus, specifying how to start the Prometheus service and which configuration file to use.
```
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
```

#### prometheus/vars/main.yml ####

Variables for the Prometheus role. This includes basic authentication credentials through which Prometheus is exposed.

```
prometheus_basic_auth_user: 'admin'
prometheus_basic_auth_password: 'test1234'
```

#### loki/ ####
#### loki/tasks/main.yml ####

This playbook installs and configures Loki on the target servers.
* Updates the APT cache.
* Downloads and installs Loki.
* Configures Loki using a template.
* Creates and configures the Loki systemd service.
* Starts and enables the Loki service.

```
- name: Update APT cache
  apt:
    update_cache: yes

- name: Download Loki
  shell: |
    LOKI_VERSION=$(curl -s "https://api.github.com/repos/grafana/loki/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    mkdir -p /opt/loki
    wget -qO /opt/loki/loki.gz "https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip"
    gunzip /opt/loki/loki.gz
    chmod a+x /opt/loki/loki
    ln -s /opt/loki/loki /usr/local/bin/loki
    wget -qO /opt/loki/loki-local-config.yaml "https://raw.githubusercontent.com/grafana/loki/v${LOKI_VERSION}/cmd/loki/loki-local-config.yaml"

- name: Configure Loki
  template:
    src: loki-local-config.yaml.j2
    dest: /opt/loki/loki-local-config.yaml

- name: Create systemd service for Loki
  template:
    src: loki.service.j2
    dest: /etc/systemd/system/loki.service

- name: Reload systemd
  systemd:
    daemon_reload: yes

- name: Start and enable Loki service
  systemd:
    name: loki
    state: started
    enabled: yes
```

#### loki/templates/loki-local-config.yaml.j2 ####

This template configures Loki, specifying the server settings, storage paths, and other configurations.

```
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  instance_addr: 0.0.0.0
  path_prefix: /tmp/loki
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
      rules_directory: /tmp/loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

ruler:
  alertmanager_url: http://localhost:9093

# By default, Loki will send anonymous, but uniquely-identifiable usage and configuration
# analytics to Grafana Labs. These statistics are sent to https://stats.grafana.org/
# Statistics help us better understand how Loki is used, and they show us performance
# levels for most users. This helps us prioritize features and documentation.
# For more information on what's sent, look at
# https://github.com/grafana/loki/blob/main/pkg/analytics/stats.go
# Refer to the buildReport method to see what goes into a report.
# If you would like to disable reporting, uncomment the following lines:
#analytics:
#  reporting_enabled: false
```

#### loki/templates/loki.service.j2 ####

This template creates the systemd service file for Loki, specifying how to start the Loki service and which configuration file to use.

```
[Unit]
Description=Loki log aggregation system
After=network.target

[Service]
ExecStart=/opt/loki/loki -config.file=/opt/loki/loki-local-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
```

#### loki/vars/main.yml ####

Variables for the Loki role. Currently empty but can be used to store configuration variables if needed.

## How to Run the Playbooks ##

Ensure Ansible is installed on your control machine:

```
sudo apt update
sudo apt install ansible -y
```

Prepare your inventory file (hosts) with the target servers.

```ansible-playbook -i hosts lpg.yml```

Verify the deployment by checking the status of the services on your target servers:

```
sudo systemctl status grafana-server
sudo systemctl status prometheus
sudo systemctl status loki
```
### Contact ###
Nikos Makris - nimakris@uth.gr 