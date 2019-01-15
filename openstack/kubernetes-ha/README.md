```
module "etcd" {
  source              = "github.com/entercloudsuite/terraform-modules//openstack/etcd?ref=2.7"
  image               = "ecs-etcd 1.0.1"
  region              = "${var.region}"
  network_name      = "${var.network_name}"
  flavor              = "e3standard.x3"
  keyname           = "${var.keypair_name}"
  
  custom_secgroups = ["${module.internal.sg_id}"]
}

module "kubernetes" {
  source         = "github.com/entercloudsuite/terraform-modules//openstack/kubernetes-ha?ref=2.7"
  image         = "ecs-kubernetes 1.13.2-1"
  region         = "${var.region}"
  network_name        = "${var.network_name}"
  master_flavor        = "e3standard.x4"
  worker_flavor        = "e3standard.x5"
  worker_count         = 3
  keyname         = "${var.keypair_name}"
  cloud_os_api_url    = "https://api.entercloudsuite.com/v2.0"
  cloud_os_tenant_name    = "cloud_os_tenant_name"
  cloud_os_username    = "cloud_os_username"
  cloud_os_password    = "cloud_os_password"
  cloud_os_region    = "${var.region}"
  # Configure the variable below for restrict SSH access to Kubernetes master
  access-cidr = "1.1.1.1/32"
  # Configure the variable below for restrict Kubernetes API access
  api-access-cidr = "1.1.1.1/32"
  
  pod-network-cidr = "10.7.0.0/17"
  service-network-cidr = "10.7.128.0/17"

  custom_secgroups_master =["${module.internal.sg_id}"]
  custom_secgroups_workers = ["${module.internal.sg_id}"]
  etcd = "etcd-server"
  master_count = 3
  consul = "consul.service.automium.consul"
  consul_datacenter = "automium"
  consul_encrypt = "SSfewkvr15pczGbdPBgEbQ=="
  
  rancher_url = "127.0.0.1"
  rancher_cluster_token = "abc"

}
```
