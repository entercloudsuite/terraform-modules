# Create instance
module "wordpress" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/instance?ref=2.7"
  name = "${var.name}"
  image = "ecs-docker 1.0.1"
  quantity = "${var.quantity}"
  flavor = "${var.flavor}"
  network_name = "${var.network_name}"
  sec_group = "${var.sec_group}"
  keypair = "${var.keypair}"
  tags = {
    "server_group" = "WEB"
  }
  userdata = "${data.template_file.cloud-config.*.rendered}"
  discovery = "${var.discovery}"
  external = "${var.external}"
  region = "${var.region}"
  postdestroy = "${data.template_file.cleanup.rendered}"
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.yml")}"
  vars {
    name = "${var.name}"
    db_user = "${var.db_user}"
    db_password = "${var.db_password}"
    db_host = "${var.db_host}"
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
