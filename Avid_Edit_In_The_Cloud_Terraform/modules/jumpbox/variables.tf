#########################
# Input Variables       #
#########################

variable "admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "resource_prefix" {
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

variable "jumpbox_vm_size" {
  description = "description"
}

variable "jumpbox_nb_instances" {
  description = "description"
}

variable "jumpbox_internet_access" {
  description = "Internet access for Jumpbox"
}

variable "JumpboxScript" {
  description = "Script forJumbpox"
}

variable "AvidNexisInstallerUrl" {
  description = "Script forJumbpox"
}