############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

#variable "local_admin_password" {
#  description = "Admin Password for Virtual Machines"
#  sensitive   = true
#}

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
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "installers_url" {
  description = "Location of all the installers"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}

############## Teradici Variables ##############

variable "teradicicac_vm_size" {
  description = "Size of Teradici cac VM"
  default     = "Standard_D2s_v3"
}

variable "teradicicac_nb_instances" {
  description = "Number of Teradici cac instances"
  default     = 0
}

variable "teradicicacScript" {
  description   = "Script name for Teradici cac"
  default       = "teradicicac_v0.1.bash"
}

variable "teradicicac_internet_access" {
  description = "Internet access for Teradici cac true or false"
  type        = bool
  default     = true 
}

