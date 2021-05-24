############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
 description = "Admin Password for Virtual Machines"
 sensitive   = true
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

############## Cloud Nexis Client Variables ##############

variable "nexis_client_vm_hostname" {
  description = "Cloud Nexis Client hostname"
}

variable "nexis_client_vm_size" {
  description = "Size of Cloud Nexis Client VM"
  default     = "Standard_DS1_v2"
}

variable "nexis_client_nb_instances" {
  description = "Number of Cloud Nexis Client instances"
  default     = 0
}

variable "nexis_client_internet_access" {
  description = "Internet access for Cloud Nexis Client true or false"
  type        = bool
  default     = true 
}

