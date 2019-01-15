variable "quantity" {
  default = 1
}

variable "name" {
  default = "portus"
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

variable "sec_group" {
  type = "list"
}

variable "keypair" {
}

variable "image" {
}

variable "flavor" {
  default = "e3standard.x2"
}

variable "external" {
  default = "false"
}

variable "network_name" {
}

variable "discovery" {
  default = "true"
}

variable "region" {
  default = "it-mil1"
}

variable "portus_fqdn" {
}

variable "registry_fqdn" {
}

variable "letsencrypt_email" {
}
