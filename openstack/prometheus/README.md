==== BASE ====
# ECS Module for create HAproxy Standalone NO ha

Simple example

```
module "promethes" {
  source = "github.com/attiliogreco/terraform-modules//openstack/prometheus?ref=master"
  name = "prometheus"
  region = "${var.region}"
  keypair = "${var.keyname}"
  external = "false"
  quantity = "1"
  network_name = "${var.network_name}"
  sec_group = ["${module.allow_local.sg_id}"]
  consul = "consul.service.automium.consul"
  consul_datacenter = "automium"
  consul_encrypt = "aYzkQAFaY5sDh6fMSAEu3Q=="
}

```
