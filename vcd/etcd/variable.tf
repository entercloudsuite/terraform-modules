variable "vcd_username" {
}

variable "vcd_password" {
}

variable "vcd_url" {
}

variable "vcd_org" {
}

variable "vcd_vdc" {
}

variable "quantity" {
  default = 3
}

variable "name" {
  default = "etcd-server"
}

variable "network_name" {}

variable "template" {}

variable "keypair" {}

variable "catalog" {
  default = "Privato"
}

variable "cpus" {
  default = 2
}

variable "memory" {
  default = 4096
}
