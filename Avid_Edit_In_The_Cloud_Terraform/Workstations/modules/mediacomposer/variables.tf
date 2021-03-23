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

variable "domainName" {
  description = "Domain Name"
  type        = string
  default     = ""
}

variable "domain_admin_username" {
  description = "Domain admin user to join domain"
  default     = ""
}

variable "domain_admin_password" {
  description = "Domain admin password to join domain"
  default     = ""
  sensitive   = true
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
  description = "Path to installer location"
  default     = "https://eitcstore01.blob.core.windows.net/installers/"
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

variable "mediacomposerVersion" {   
    type        = string 
    description = "Options available: 2018.12.14, 2020.12.0, 2021.2.0"
    default     = "2021.2.0"
    validation {
            condition       = (
                var.mediacomposerVersion == "2021.2.0" || 
                var.mediacomposerVersion == "2020.12.0" ||
                var.mediacomposerVersion == "2018.12.14"
            )
            error_message   = "Only the following versions are supported: 2020.12.0, 2020.12.0 and 2018.12.14."
        }
}

############## Teradici Variables ##############

variable "TeradiciKey" {
    type    = string  
    default = "0000"  
}

variable "TeradiciInstaller" {
    type    = string 
    default = "pcoip-agent-graphics_21.01.2.exe"
}

############## Nexis Client Variables ##############

variable "AvidNexisInstaller" {
    type = string 
    default = "AvidNEXISClient_Win64_21.3.0.21.msi"
}



