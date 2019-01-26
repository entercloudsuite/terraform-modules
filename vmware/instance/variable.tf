variable "user" {
}

variable "password" {
}

variable "vsphere_server" {
}

variable "quantity" {
  default = 1
}

variable "cpus" {
  default = 1
}

variable "memory" {
  default = 512
}

variable "memory_reservation" {
  default = 0
}

variable "name" {
}

variable "userdata" {
  type = "list"
  default = [""]
}

variable "template" {
}

variable "template_datastore" {
}

variable "datastore" {
}

variable "iso_datastore" {
}

variable "network_name" {
}

variable "datacenter" {
}

variable "folder" {
  default = "automium"
}

variable "keypair" {
}

variable "postdestroy" {
  default = "true"
}

variable "discovery" {
  default = "false"
}

variable "discovery_port" {
  default = 0
}

variable "cluster" {}
