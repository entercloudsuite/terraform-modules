variable "flavor" {}

variable "keyname" {}

variable "network_name" {}

variable "image" {}

variable "region" {}

variable "custom_secgroups" {
   default = []
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
