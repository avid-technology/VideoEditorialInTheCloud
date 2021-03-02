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

variable "gpu_type" {
  description = "Gpu type either Nvidia or Amd"
  type = string
  default = "Nvidia" 
  validation {
            condition       = (
                var.gpu_type == "Nvidia" || 
                var.gpu_type == "Amd" 
            )
            error_message   = "Only the following gpu are supported: Nvidia, Amd."
        }
}

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

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
  default     = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/master/Avid_Edit_In_The_Cloud_Terraform/scripts/"
}

variable "TeradiciKey" {
    type    = string 
    default = "0000"
}

variable "TeradiciInstaller" {
    type    = string 
    default = "pcoip-agent-graphics_21.01.2.exe"
}

variable "installers_url" {
  description = "Path to scripts location"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
}

variable "ProToolsVersion" {
    type    = string 
    description = "Options available: 2020.11.0"
    default = "2020.11.0"
    validation {
            condition       = (
                var.ProToolsVersion == "2020.11.0"
            )
            error_message   = "Only the following versions are supported: 2020.11.0."
        }
}

variable "AvidNexisInstaller" {
    type    = string 
    default = "AvidNEXISClient_Win64_20.7.5.23.msi"
}



