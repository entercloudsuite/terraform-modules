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
  default = "ecs-prometheus master"
}

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
  
    - job_name: 'prometheus'
      scrape_interval: 10s
      scrape_timeout:  10s
      static_configs:
        - targets: ['localhost:9090']
          labels:
            instance: prometheus
  
    - job_name: linux
      static_configs:
        - targets: ['localhost:9100']
          labels:
            instance: prometheus
    
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
  groups:
  - name: default
    rules:
    # Alert for any instance that is unreachable for >5 minutes.
    - alert: InstanceDown
      expr: up == 0
      for: 30s
      labels:
        severity: critical
      annotations:
        summary: "Instance {{ $labels.instance }} down"
        description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 30 seconds."
   
   - record: instance:node_cpu:rate:sum  
      expr: sum(rate(node_cpu{mode!="idle",mode!="iowait",mode!~"^(?:guest.*)$"}[3m]))
        BY (instance)
    - record: instance:node_filesystem_usage:sum
      expr: sum((node_filesystem_size{mountpoint="/"} - node_filesystem_free{mountpoint="/"}))
        BY (instance)
    - record: instance:node_network_receive_bytes:rate:sum
      expr: sum(rate(node_network_receive_bytes[3m])) BY (instance)
    - record: instance:node_network_transmit_bytes:rate:sum
      expr: sum(rate(node_network_transmit_bytes[3m])) BY (instance)
    - record: instance:node_cpu:ratio
      expr: sum(rate(node_cpu{mode!="idle"}[5m])) WITHOUT (cpu, mode) / ON(instance)
        GROUP_LEFT() count(sum(node_cpu) BY (instance, cpu)) BY (instance)
    - record: cluster:node_cpu:sum_rate5m
      expr: sum(rate(node_cpu{mode!="idle"}[5m]))
    - record: cluster:node_cpu:ratio
      expr: cluster:node_cpu:rate5m / count(sum(node_cpu) BY (instance, cpu))
   
   - alert: NodeDiskRunningFullIn24Hours  
      expr: predict_linear(node_filesystem_free{device=~"/dev/.*",mountpoint!~"/var/lib/docker.*"}[6h], 24 * 3600) < 0
      for: 30m
      labels:
        severity: warning
      annotations: 
        summary: "Disk will be Full in 24 hours"
        description: Mount point {{$labels.mountpoint}} on device {{$labels.device}} on node {{$labels.instance}} is running full within the next 24 hours.
   
   - alert: NodeDiskRunningFullIn2Hours  
      expr: predict_linear(node_filesystem_free{device=~"/dev/.*",mountpoint!~"/var/lib/docker.*"}[3h], 2 * 3600) < 0
      for: 10m
      labels:
        severity: critical
      annotations: 
        summary: "Disk will be Full in 2 hours"
        description: Mount point {{$labels.mountpoint}} on device {{$labels.device}} on node {{$labels.instance}} is running full within the next 2 hours.
   
   - alert: NodeDiskRunningFull  
      expr: node_filesystem_avail{mountpoint!~"/var/lib/docker.*"} / node_filesystem_size{mountpoint!~"/var/lib/docker.*"} * 100 < 3 
      for: 10m
      labels:
        severity: critical
        annotations: 
        summary: "Disk Full at {{ $value }} %"
        description: device {{$labels.device}} on node {{$labels.instance}} is full at {{ $value }} %
   
   - alert: ram_full_more_than_80  
      expr: 100 - ((node_memory_MemAvailable * 100) / node_memory_MemTotal) > 80
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "ram full {{ humanize $value}}%"
        description: "{{$labels.instance}} ram is full at {{$value | humanize }}%."
  groups:
  - name: memcache
    rules:
    - alert: Probe-down
      expr: probe_success == 0
      for: 30s
      labels:
        severity: warning
      annotations:
        summary: "Instance probe {{ $labels.instance }} is down"
        description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 30 seconds."
   
   - alert: backendDown75%  
      expr: sum(probe_success{job="blackbox-http_check"}) / count(probe_success{job="blackbox-http_check"}) * 100 < 75
      for: 30s
      labels:
        severity: warning
      annotations:
        summary: "{{ $value }} of backend are down"
        description: "{{ $value }} of backend are down"
   
   - alert: backendDown50%  
      expr: sum(probe_success{job="blackbox-http_check"}) / count(probe_success{job="blackbox-http_check"}) * 100 < 75
      for: 30s
      labels:
        severity: warning
      annotations:
        summary: "{{ $value }} of backend are down"
        description: "{{ $value }} of backend are down"
   
   - alert: ssl_certificate  
      expr: probe_ssl_earliest_cert_expiry-time() < 604800
      for: 30s
      labels:
        severity: weekly
      annotations:
        summary: "ssl certificate expiring in {{ $value | humanizeDuration }}"
        description: "ssl certificate expiring in {{ $value | humanizeDuration }}"
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
