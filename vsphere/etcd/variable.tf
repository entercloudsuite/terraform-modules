variable "quantity" {
  default = 3
}

variable "name" {
  default = "etcd-server"
}

variable "network_name" {}

variable "datastore" {}

variable "iso_datastore" {}

variable "datacenter" {}

variable "template" {}

variable "keypair" {}

variable "vsphere_user" {}

variable "vsphere_password" {}

variable "vsphere_server" {}

variable "cluster" {}

variable "template_datastore" {}

variable "cpus" {
  default = 2
}

variable "memory" {
  default = 4096
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
