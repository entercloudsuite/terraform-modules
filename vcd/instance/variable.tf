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

variable "template" {
}

variable "vcd_server"{
}

variable "network_name" {
  default = "TerraformNetwork01"
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

variable "name" {
}

variable "userdata" {
  type = "list"
  default = [""]
}

variable "catalog" {
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
