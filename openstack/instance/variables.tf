variable "name" {
}

variable "network_name" {
}

variable "flavor" {
}

variable "allowed_address_pairs" {
  default = "127.0.0.1/32"
}

variable "external" {
  default = "false"
}

variable "discovery" {
  default = "false"
}

variable "quantity" {
  default = 1
}

variable "tags" {
  type = "map"
  default = {
    role = "generic"
    status = "generic"
  }
}

variable "role" {
  default = "generic"
}

variable "status" {
  default = "generic"
}

variable "region" {
  default = "it-mil1"
}

variable "image" {
  default = "GNU/Linux Ubuntu Server 16.04 Xenial Xerus x64"
}

variable "floating_ip_pool" {
  default = "PublicNetwork"
}

variable "sec_group" {
  type = "list"
}

variable "keypair" {
}

variable "userdata" {
  type = "list"
  default = [""]
}

variable "discovery_port" {
  default = 0
}

variable "postdestroy" {
  default = "true"
}
