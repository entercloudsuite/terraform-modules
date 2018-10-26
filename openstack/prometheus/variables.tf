variable "quantity" {
  default = 1
}

variable "name" {
  default = "prometheus"
}

variable "sec_group" {
  type = "list"
}

variable "keypair" {
}

variable "flavor" {
  default = "e3standard.x2"
}

variable "external" {
  default = "false"
}

variable "network_name" {
}

variable "image" {
  default = "ecs-prometheus 2.4.2.2"
}

variable "prometheus_rule_git_repo" {
  default = "https://github.com/entercloudsuite/prometheus-rules-collections.git"
}
# TODO: add autentication method ( key, user other)
variable "grafna_dashboard_repo" {
  default = "https://github.com/entercloudsuite/grafana-dashboard.git"
}

# TODO: add autentication method ( key, user other)

variable "discovery" {
  default = "true"
}

variable "region" {
  default = "it-mil1"
}

variable "prometheus_prometheus_conf_main" {
  default = <<EOF
global:
  scrape_interval:     10s # By default, scrape targets every 15 seconds.
  evaluation_interval: 10s # By default, scrape targets every 15 seconds.
  # scrape_timeout is set to the global default (10s).

  # The labels to add to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).

  external_labels:
    monitor: 'master'

# Alerting
alerting:
  alertmanagers:
    - static_configs:
      - targets:
        - localhost:9093

# Rule files specifies a list of files from which rules are read.
rule_files:
  - /etc/prometheus/rules/*.rules

# A list of scrape configurations.
scrape_configs:

  - job_name: overide_me
    consul_sd_configs:
      - server: 'consul.service.automium.consul:8500'
    relabel_configs:
    - source_labels: ['__meta_consul_service']
      regex: '(exporter_.*)'
      action: keep
    - source_labels: ['__meta_consul_service']
      regex: 'exporter_(.*)'
      target_label:  'job'
      replacement:   '$1'
    - source_labels: ['__meta_consul_node']
      regex:         '(.*)'
      target_label:  'instance'
      replacement:   '$1'
    - source_labels: ['__meta_consul_tags']
      regex:         ',(production|canary),'
      target_label:  'group'
      replacement:   '$1'
EOF
}

variable "prometheus_alertmanager_conf_main" {
  default = <<EOF
global:
route:
  receiver: 'default-receiver'
  group_wait: 30s
  repeat_interval: 3h
  group_by: [cluster, alertname]

receivers:
  - name: 'default-receiver'
    email_configs:
    - to: myemail_to_alert@example.com
      from: prometheus@example.com
      smarthost: out.example.com:587
      auth_username: "prometheus@example.com"
      auth_identity: "prometheus@example.com"
      auth_password: "VeryVeryS3ctret"
      send_resolved: true
    - to: me@example.com
      from: prometheus@example.com
      smarthost: out.entermail.it:587
      auth_username: "prometheus@example.com"
      auth_identity: "prometheus@example.com"
      auth_password: "VeryVeryS3ctret"
      send_resolved: true
EOF
}

variable "prometheus_blackbox_exporter_main_conf" {
  default = <<EOF
modules:
  http_2xx:
    prober: http
    http:
  http_post_2xx:
    prober: http
    http:
      method: POST
  tcp_connect:
    prober: tcp
  icmp:
    prober: icmp
EOF
}

variable "prometheus_rules" {
  default = <<EOF
EOF
}

variable "consul" {
  default = ""
}

variable "consul_port" {
  default = "8500"
}

variable "consul_datacenter" {
}

variable "consul_encrypt" {
}
