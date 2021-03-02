#########################
# Input Variables       #
#########################

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
  sensitive   = true
}

variable "domain_admin_username" {
  description = "Domain admin user to join domain"
  default     = null
}

variable "domain_admin_password" {
  description = "Domain admin password to join domain"
  default     = null
  sensitive   = true
}

variable "domainName" {
  description = "Domain Name"
  type        = string
  default     = null
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

variable "zabbix_vm_size" {
  description = "Size of Jumpbox VM"
  default     = "Standard_D4s_v3"
}

variable "zabbix_nb_instances" {
  description = "Number of jumpbox instances"
  default     = 0
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
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

variable "installers_url" {
  description = "Location of all the installers"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}