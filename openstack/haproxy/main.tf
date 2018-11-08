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
  postdestroy = "${data.template_file.cleanup.rendered}"
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
    haproxy_user = "${var.haproxy_user}"
    haproxy_pass = "${var.haproxy_pass}"
    haproxy_global = "${var.haproxy_global}"
    haproxy_defaults = "${var.haproxy_defaults}"
    haproxy_stats = "${var.haproxy_stats}"
    haproxy_conf = "${indent(14,var.haproxy_conf)}"
    haproxy_cert = "${indent(14,var.haproxy_cert)}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}

data "template_file" "cleanup" {
  template = "${file("${path.module}/cleanup.sh")}"
  vars {
    name = "${var.name}"
    quantity = "${var.quantity}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}
