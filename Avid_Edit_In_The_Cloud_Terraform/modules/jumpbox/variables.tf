############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "domain_admin_username" {
  description = "Domain admin user to join domain"
  default     = ""
}

variable "domainName" {
  description = "Domain Name"
  type        = string
  default     = ""
}

variable "domain_admin_password" {
  description = "Domain admin password to join domain"
  default     = ""
  sensitive   = true
}

variable "resource_prefix" {
  description = "4 max characters to prefix each resource built"
}

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "vnet_subnet_id" {
  description = "Subnet where resources will be built"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
}

variable "installers_url" {
  description = "Location of all the installers"
}

############## Jumpbox Variables ##############

variable "jumpbox_vm_size" {
  description = "Size of Jumpbox VM"
  default     = "Standard_D4s_v3"
}

variable "jumpbox_nb_instances" {
  description = "Number of jumpbox instances"
  default     = 0
}

variable "JumpboxScript" {
  description = "Script name forJumbpox"
}

variable "jumpbox_internet_access" {
  description = "Internet access for Jumpbox true or false"
  type        = bool
}

############## Nexis Client Variables ##############

variable "AvidNexisInstaller" {
  description = "Cloud Nexis installer MSI name"
}