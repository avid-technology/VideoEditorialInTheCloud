############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "resource_group_name" {
  description = "Name of resource group where to build resources"
}

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "vnet_name" {
  description = "Name of vnet where resource will be built"
}

variable "subnet_name" {
  description = "Name of subnet where resource will be built"
}

variable "installers_url" {
  description = "Location of all the installers"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
}

############## DomainController Variables ##############

variable "domaincontroller_vm_hostname" {
  description = "Hostname of Domain Controller"
}

variable "domaincontroller_vm_size" {
  description = "Size of domaincontroller VM"
  default     = "Standard_D4s_v3"
}

variable "domainName" {
  description = "Domain Name"
  type        = string
}

variable "domaincontroller_internet_access" {
  description = "Internet access for domaincontroller true or false"
  type        = bool
  default     = false
}

variable "domaincontroller_nb_instances" {
  description = "Number of domaincontroller instances"
  default     = 0
}



