example

```
module "etcd" {
  source = "github.com/entercloudsuite/terraform-modules//vmware/etcd?ref=2.7"
  quantity = "3"
  cpus = 2
  memory = 2048
  network_name = "yournetwork"
  datastore = "yourdatastorecluster"
  iso_datastore = "yourisodatastore"
  template_datastore = "yourtemplatedatastore"
  datacenter = "yourdatacenter"
  cluster = "yourcluster"
  template = "yourtemplate"
  vsphere_user = "vsphere_user"
  vsphere_password = "vsphere_password"
  vsphere_server = "${var.vsphere_server}"
  keypair = "${file("id_rsa.pub")}"
}
```
