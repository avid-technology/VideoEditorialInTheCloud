#########################
# Input Variables       #
#########################

variable "hostname" {
  description = "Hostname of Cloud Nexis. Maximum 8 characters."
}

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
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

variable "resource_group_name" {
  description = "Name of resource group where to build resources"
  default = "*"
}

variable "nexis_storage_account_public_access" {
  description = "Allow storage account visibility over public internet or restrict to specific subnet"
  type        = bool
  default     = false
}

# variable "nexis_storage_account_subnet_access" {
#   description = "Subnet that can get access to Nexis storage account. Make sure Service Endpoint 'Microsoft.Storage' has been activated on all subnet(s) that need access to storage account."
#   default     = []
# }

variable "nexis_system_director_vm_size" {
  description = "Size of Nexis VM. Should be either Standard_F16s_v2 (recommended) or Standard_DS4_v2 (legacy)"
  default     = "Standard_F16s_v2"
}

variable "nexis_system_director_nb_instances" {
  description = "Number of Nexis instances"
  default     = 0
}

variable "nexis_system_director_vm_script_url" { 
  type = string
  description = "Location of all the powershell and bash scripts" 
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "nexis_system_director_vm_script_name" { 
  type        = string
  description = "Script installer name"
  default     = "installNexis.bash"
}

variable "nexis_system_director_vm_artifacts_location" { 
  type        = string
  description = "Path to installer location"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}

variable "nexis_system_director_vm_build" { 
  type        = string
  description = "Name of Nexis installer"
  default     = "AvidNEXISCloud_20.7.5-23.run"
}

# variable "private_dns_zone_resource_group" { 
#   type        = string
#   description = "Resource group where private dns zone is located. Private DNS zone for storage account must be named: privatelink.blob.core.windows.net."
#   default     = ""
# }

variable "nexis_system_director_image_reference" {
  type = map
  default = {
    publisher = "credativ"
    offer     = "Debian"
    sku       = "8"
    version   = "8.0.201901221"
  }
}

variable "nexis_system_director_vm_part_number" { 
  type        = string
  description = "Type of Cloud Nexis. Should be either 0100-38171-00 (Nearline) or 0100-40109-00 (Online)"
  default     = "0100-38171-00"
}

variable "nexis_system_director_performance" { 
  type        = string
  description = "Storage account performance type. Should be either Standard (Nearline) or Premium (Online)"
  default     = "Standard"
}

variable "nexis_system_director_replication" { 
  type        = string
  description = "Storage account replication type. Should be LRS."
  default     = "LRS"
}

variable "nexis_system_director_account_kind" { 
  type        = string
  description = "Storage account type. Should be either StorageV2 (Nearline) or BlockBlobStorage (Online)"
  default     = "StorageV2"
}

variable "nexis_system_director_internet_access" { 
  type        = bool
  description = "Internet access for Cloud Nexis System Director."
  default     = false
}