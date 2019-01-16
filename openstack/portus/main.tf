module "portus" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/instance?ref=2.7"
  name = "${var.name}"
  image = "${var.image}"
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
    quantity = "${var.quantity}"
    hostname = "${var.name}-${count.index}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
    portus_fqdn = "${var.portus_fqdn}" 
    registry_fqdn = "${var.registry_fqdn}" 
    letsencrypt_email = "${var.letsencrypt_email}" 
  }
}

module "portus-volume" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/volume?ref=2.7"
  name = "${var.name}"
  size = "${var.portus_volume_size}"
  instance = "${module.portus.instance}"
  quantity = "${module.portus.quantity}"
  region = "${var.region}"
  volume_type = "${var.portus_volume_type}"
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
