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

variable "vnet_subnet_id" {
  description = "Subnet where resources will be built"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "installers_url" {
  description = "Location of all the installers"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}

############## Zabbix Variables ##############

variable "zabbix_vm_size" {
  description = "Size of Jumpbox VM"
  default     = "Standard_D4s_v3"
}

variable "zabbix_nb_instances" {
  description = "Number of jumpbox instances"
  default     = 0
}

variable "zabbix_vm_hostname" {
  description   = "Zabbix hostname"
}

variable "zabbixScript" {
  description   = "Script name forJumbpox"
  default       = "zabbix_v0.1.bash"
}

variable "zabbix_internet_access" {
  description = "Internet access for Jumpbox true or false"
  type        = bool
  default     = false 
}

