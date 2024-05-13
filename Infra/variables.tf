variable "resource_group_name" {
  type    = string
  default = "sa1_test_eic_MaazPatel"
}

variable "username" {
  type = string
  default = "adminuser-maaz"
}

variable "virtual_network_name" {
  type    = string
  default = "example-vm-vnet"
}

variable "subnet_name" {
  type    = string
  default = "example-vm-subnet"
}
variable "public_ip_name" {
  type = string
  default = "example-public-ip"
}

variable "network_interface_name" {
  type    = string
  default = "maaz_terraform-nic"
}

