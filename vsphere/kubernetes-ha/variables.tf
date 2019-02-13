variable "master_name" {
  default = "kubernetes-master"
}

variable "worker_name" {
  default = "kubernetes-workers"
}

variable "master_count" {
   default = "1"
}

variable "worker_count" {
   default = "2"
}

variable "master_cpus" {
   default = "2"
}

variable "master_memory" {
   default = "4096"
}

variable "worker_cpus" {
   default = "2"
}

variable "worker_memory" {
   default = "4096"
}

variable "floating_ip_pool" {
   default = "PublicNetwork"
}

variable "access-cidr" {
   default = "0.0.0.0/0"
}

variable "api-access-cidr" {
   default = "127.0.0.1/32"
}

variable "pod-network-cidr" {
   default = "192.168.0.0/16"
}

variable "service-network-cidr" {
   default = "10.96.0.0/12"
}

variable "keyname" {}

variable "network_name" {}

variable "template" {}

variable "etcd" {
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

variable "rancher_url" {
  default = "consul.service.automium.consul"
}

variable "rancher_cluster_token" {
  default = ""
}

variable "vsphere_user" {}

variable "vsphere_password" {}

variable "vsphere_server" {}

variable "datastore" {}

variable "iso_datastore" {}

variable "template_datastore" {}

variable "datacenter" {}

variable "cluster" {}
