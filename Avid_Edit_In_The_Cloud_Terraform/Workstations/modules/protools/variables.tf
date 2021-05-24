############## Environment Variables ##############

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "vnet_name" {
  description = "Name of vnet where resource will be built"
}

variable "image_reference" {
  description = "Source image reference for Virtual Machine to be built"
  type = map
}

variable "subnet_name" {
  description = "Name of subnet where resource will be built"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "resource_group_name" {
  description = "Name of resource group where to build resources"
}

variable "sas_token" {
  description = "Sas token to access storage account"
}

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
  sensitive   = true
}

############## ProTools Variables ##############

variable "protools_vm_size" {
  description = "Size of ProTools VM"
  default     = "Standard_NV12s_v3"
  type = string
  validation {
            condition       = (
                var.protools_vm_size == "Standard_NV8as_v4" || 
                var.protools_vm_size == "Standard_NV16as_v4" ||
                var.protools_vm_size == "Standard_NV32as_v4" ||
                var.protools_vm_size == "Standard_NV12s_v3" ||
                var.protools_vm_size == "Standard_NV24s_v3" ||
                var.protools_vm_size == "Standard_NV48s_v3"
            )
            error_message   = "Only the following sku are supported: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3."
        }
}

variable "protools_nb_instances" {
  description = "Number of Protools instances"
  default     = 0
}

variable "protools_internet_access" {
    type        = bool
    default     = false 
}

variable "protoolsScript" {
  description = "Script to install ProTools"
  default     = "setupProTools_2020.11.0.ps1"
}

variable "protools_vm_hostname" {
  description = "ProTools hostname"
}


