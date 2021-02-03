#########################
# Input Variables       #
#########################

variable "admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "resource_group_name" {
  description = ""
}

variable "resource_group_location" {
  description = ""
}

variable "vnet_subnet_id" {
  description = ""
}

variable "base_index" {
  description = "Base index"
  default = 0
}

variable "jumpbox_vm_hostname" {
  description = "description"
}

variable "jumpbox_vm_size" {
  description = "description"
}

variable "jumpbox_vm_instances" {
  description = "description"
}