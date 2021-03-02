#########################
# Input Variables       #
#########################

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
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

variable "installers_url" {
  description = "Location of all the installers"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
}

variable "domaincontroller_vm_size" {
  description = "Size of domaincontroller VM"
  default     = "Standard_D4s_v3"
}

variable "domaincontroller_nb_instances" {
  description = "Number of domaincontroller instances"
  default     = 0
}

variable "domainName" {
  description = "Domain Name"
  type        = string
}

variable "domaincontrollerScript" {
  description = "Script name forJumbpox"
  default     = "domaincontroller_v0.1.ps1"
}

variable "domaincontroller_internet_access" {
  description = "Internet access for domaincontroller true or false"
  type        = bool
  default     = false
}

