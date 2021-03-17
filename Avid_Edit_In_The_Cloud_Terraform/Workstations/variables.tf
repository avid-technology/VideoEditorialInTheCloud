############## Environment Variables ##############

variable "local_admin_username" {
    type = string
}

variable "local_admin_password" {
    type = string 
    sensitive = true
}

variable "domainName" {
  description = "Domain Name"
  type        = string
  default     = null
}

variable "domain_admin_username" {
    type = string
}

variable "domain_admin_password" {
    type = string 
    sensitive = true
}

variable "resource_prefix" {
    type = string

    validation {
        condition       = length(var.resource_prefix) <= 4
        error_message   = "Resource prefix must be less than 4 characters."
    }
}

variable "branch"{
    type = string
}

variable "installers_url"{
    type = string
}

variable "resource_group_location"{
    type = string
    description = "resource group name"
}

############## DomainController Variables ##############

variable "domaincontroller_nb_instances" {
  description = "Number of domaincontroller instances"
  default     = 0
}


############## Nexis Client Variables ##############

variable "AvidNexisInstaller" {
    type = string 
    default = "AvidNEXISClient_Win64_20.7.5.23.msi"
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

variable "mediacomposer_internet_access" {
    type        = bool
    default     = false 
}

variable "mediacomposerScript" {
  description = "Pscript to install MediaComposer"
  default     = "setupMediaComposer_v0.1.ps1"
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