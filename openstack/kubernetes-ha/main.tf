# Kubernetes join token 
resource "random_string" "kube-first-token-part" {
  length = 6
  upper = false
  special = false
}

resource "random_string" "kube-second-token-part" {
  length = 16
  upper = false
  special = false
}

# Network data
data "openstack_networking_network_v2" "network" {
  name = "${var.network_name}"
  region = "${var.region}"
}

data "openstack_networking_subnet_v2" "subnet" {
  network_id = "${data.openstack_networking_network_v2.network.id}"
  region = "${var.region}"
}

# Security groups
module "kubernetes-ssh_sg" {
  source = "github.com/entercloudsuite/terraform-modules//security?ref=2.6"
  name = "kubernetes-ssh"
  region = "${var.region}"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  allow_remote = "${var.access-cidr}"
}

module "kubernetes-api_sg" {
  source = "github.com/entercloudsuite/terraform-modules//security?ref=2.6"
  name = "kubernetes-api"
  region = "${var.region}"
  protocol = "tcp"
  port_range_min = 6443
  port_range_max = 6443
  allow_remote = "${var.api-access-cidr}"
}

module "kubernetes-all-from-internal_sg" {
  source = "github.com/entercloudsuite/terraform-modules//security?ref=2.6"
  name = "kubernetes-all-from-internal"
  region = "${var.region}"
  protocol = ""
  allow_remote = "${data.openstack_networking_subnet_v2.subnet.cidr}"
}

# Cloud init scripts
data "template_file" "cloud-config-master" {
  template = "${file("${path.module}/kube-master.yml")}"
  vars {
    name = "${var.master_name}"
    public-ip  = "${element(module.kubernetes_master.public-instance-address,0)}"
    kube-token = "${format("%s.%s", random_string.kube-first-token-part.result, random_string.kube-second-token-part.result)}"
    os_api_url = "${var.cloud_os_api_url}"
    os_tenant_name = "${var.cloud_os_tenant_name}"
    os_username = "${var.cloud_os_username}"
    os_password = "${var.cloud_os_password}"
    os_region = "${var.cloud_os_region}"
    pod-network-cidr = "${var.pod-network-cidr}"
    service-network-cidr = "${var.service-network-cidr}"
    dns-service-addr = "${cidrhost(var.service-network-cidr, 10)}"
    etcd = "${var.etcd}"
    master_count = "${var.master_count}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}

data "template_file" "cloud-config-worker" {
  template = "${file("${path.module}/kube-worker.yml")}"
  vars {
    master-ip  = "${element(module.kubernetes_master.instance-address,0)}"
    kube-token = "${format("%s.%s", random_string.kube-first-token-part.result, random_string.kube-second-token-part.result)}"
    os_api_url = "${var.cloud_os_api_url}"
    os_tenant_name = "${var.cloud_os_tenant_name}"
    os_username = "${var.cloud_os_username}"
    os_password = "${var.cloud_os_password}"
    os_region = "${var.cloud_os_region}"
    dns-service-addr = "${cidrhost(var.service-network-cidr, 10)}"
  }
}

# Kubernetes master node
module "kubernetes_master" {
  source = "github.com/entercloudsuite/terraform-modules//instance?ref=2.6"
  name = "${var.master_name}"
  region = "${var.region}"
  image = "${var.image}"
  quantity = "${var.master_count}"
  external = "true"
  discovery = "true"
  flavor = "${var.master_flavor}"
  network_name = "${var.network_name}"
  sec_group = "${concat(var.custom_secgroups_master, list("${module.kubernetes-ssh_sg.sg_id}","${module.kubernetes-api_sg.sg_id}","${module.kubernetes-all-from-internal_sg.sg_id}"))}"
  keypair = "${var.keyname}"
  userdata = "${data.template_file.cloud-config-master.rendered}"
  allowed_address_pairs = "0.0.0.0/0"
  tags = {
    "server_group" = "KUBERNETES"
  }
}

# Kubernetes worker nodes
module "kubernetes_workers" {
  source = "github.com/entercloudsuite/terraform-modules//instance?ref=2.6"
  name = "kubernetes-workers"
  region = "${var.region}"
  image = "${var.image}"
  quantity = "${var.worker_count}"
  external = "false"
  discovery = "true"
  flavor = "${var.worker_flavor}"
  network_name = "${var.network_name}"
  sec_group = "${concat(var.custom_secgroups_workers, list("${module.kubernetes-all-from-internal_sg.sg_id}"))}"
  keypair = "${var.keyname}"
  userdata = "${data.template_file.cloud-config-worker.rendered}"
  allowed_address_pairs = "0.0.0.0/0"
  tags = {
    "server_group" = "KUBERNETES"
  }
}
