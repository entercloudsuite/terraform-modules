# portus

```
module "portus" {
  source        = "github.com/entercloudsuite/terraform-modules//openstack/portus?ref=portus"
  image         = "ecs-portus 1.0"
  region        = "${var.region}"
  network_name  = "${var.network_name}"
  flavor        = "e3standard.x4"
  keypair       = "${var.keypair_name}"
  external      = "true"
  sec_group = ["${module.enable80.sg_id}","${module.internal.sg_id}"]
  consul = "10.2.0.4"
  consul_datacenter = "automium"
  consul_encrypt = "SSfewkvwz5pcrzbdSBgEbQ=="
  portus_fqdn = "portus.example.com"
  registry_fqdn = "registry.example.com"
  letsencrypt_email = "sysadmins@test.com"
  quantity = 1
}
```
