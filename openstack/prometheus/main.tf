module "haproxy" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/instance?ref=2.7"
  name = "${var.name}"
  quantity = "${var.quantity}"
  external = "${var.external}"
  region = "${var.region}"
  flavor = "${var.flavor}"
  network_name = "${var.network_name}"
  sec_group = "${var.sec_group}"
  discovery = "${var.discovery}"
  keypair = "${var.keypair}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  image = "${var.image}"
  tags = {
    "server_group" = "${var.name}"
  }
}
data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.yml")}"
  count = "${var.quantity}"
  vars {
    name = "${var.name}"
    number = "${count.index}"
    hostname = "${var.name}-${count.index}"
    prometheus_alertmanager_conf_main = "${var.prometheus_alertmanager_conf_main}"
    prometheus_prometheus_conf_main = "${var.prometheus_prometheus_conf_main}"
    prometheus_blackbox_exporter_main_conf = "${var.prometheus_blackbox_exporter_main_conf}"
    prometheus_rules = "${var.prometheus_rules}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}
