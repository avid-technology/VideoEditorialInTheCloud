############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
  sensitive   = true
}

variable "image_reference" {
  description = "Source image reference for Virtual Machine to be built"
  type = map
}

variable "sas_token" {
  description = "Sas token to access storage account"
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

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

############## MediaComposer Variables ##############

variable "mediacomposer_vm_size" {
  description = "Size of MediaComposer VM. Options available: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3."
  default     = "Standard_NV12s_v3"
  type = string
  validation {
            condition       = (
                var.mediacomposer_vm_size == "Standard_NV8as_v4" || 
                var.mediacomposer_vm_size == "Standard_NV16as_v4" ||
                var.mediacomposer_vm_size == "Standard_NV32as_v4" ||
                var.mediacomposer_vm_size == "Standard_NV12s_v3" ||
                var.mediacomposer_vm_size == "Standard_NV24s_v3" ||
                var.mediacomposer_vm_size == "Standard_NV48s_v3"
            )
            error_message   = "Only the following sku are supported: Standard_NV8as_v4, Standard_NV16as_v4, Standard_NV32as_v4, Standard_NV12s_v3, Standard_NV24s_v3, Standard_NV48s_v3."
        }
}

variable "mediacomposer_nb_instances" {
  description = "Number of MediaComposer instances"
  default     = 0
}

variable "mediacomposer_vm_hostname" {
  description = "Hostname of MediaComposer"
}

variable "mediacomposer_internet_access" {
    type        = bool
    default     = false 
}

variable "mediacomposerScript" {
  description = "Pscript to install MediaComposer"
  default     = "setupMediaComposer_v0.2.ps1"
}



