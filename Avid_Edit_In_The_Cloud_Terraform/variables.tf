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

variable "gpu_type" {
    type = string 

    validation {
            condition       = (
                var.gpu_type == "Nvidia" || 
                var.gpu_type == "Amd" 
            )
            error_message   = "Only the following gpu are supported: Nvidia, Amd."
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

variable "azureTags" {
    type = map
    description = "resource group name"
}

############## DomainController Variables ##############

variable "domaincontroller_nb_instances" {
  description = "Number of domaincontroller instances"
  default     = 0
}

############## Jumpbox Variables ##############

variable "jumpbox_vm_size" {
  description = "Size of Jumpbox VM"
  default     = "Standard_D4s_v3"
}

variable "jumpbox_nb_instances" {
  description = "Number of jumpbox instances"
  default     = 0
}

variable "JumpboxScript" {
  description = "Script name forJumbpox"
}

variable "jumpbox_internet_access" {
  description = "Internet access for Jumpbox true or false"
  type        = bool
}

############## Network Variables ##############

variable "vnet_address_space" {
    type = list(string)
    description = "resource group name"
}

variable "dns_servers" {
    type = list(string)
    description = "resource group name"
}

variable "whitelist_ip" {
    type = list(string)
    description = "List of whitelist ip addresses"
}

variable "subnets" {
    type = map
    description = "resource group name"
}

############## Nexis Client Variables ##############

variable "AvidNexisInstaller" {
    type = string 
    default = "AvidNEXISClient_Win64_20.7.5.23.msi"
}

############## Nexis System Director Variables ##############

variable "nexis_vm_size" {
    type = string 
}

variable "nexis_nearline_nb_instances" {
    type = number
}

variable "nexis_online_nb_instances" {
    type = number
}

variable "nexis_storage_vm_script_name" {
    type = string
}

variable "nexis_storage_vm_build" {
    type = string
}

variable "nexis_internet_access" {
    type = bool
}

variable "nexis_storage_vm_part_number_nearline" {
    type = string
}

variable "nexis_storage_vm_part_number_online" {
    type = string
}

variable "nexis_storage_performance_nearline" {
    type = string
}

variable "nexis_storage_replication_nearline" {
    type = string
}

variable "nexis_storage_account_kind_nearline" {
    type = string
}

variable "nexis_storage_performance_online" {
    type = string
}

variable "nexis_storage_replication_online" {
    type = string
}

variable "nexis_storage_account_kind_online" {
    type = string
}

variable "nexis_image_reference" {
  type = map
  default = {
    publisher = "credativ"
    offer     = "Debian"
    sku       = "8"
    version   = "8.0.201901221"
  }
}

############## MediaCentral Variables ##############

variable "mccenter_nb_instances" {
    type = number
}

variable "mccentersql_nb_instances" {
    type = number
}

variable "mcworker_nb_instances" {
    type = number
}

variable "mccloudux_nb_instances" {
    type = number
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

############## Teradici Variables ##############

variable "TeradiciKey" {
    type    = string  
    default = "0000"  
}

variable "teradicicac_nb_instances" {
    type    = number  
    default = 0  
}

variable "TeradiciInstaller" {
    type    = string 
    default = "pcoip-agent-graphics_21.01.2.exe"
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

variable "zabbixScript" {
  description   = "Script name forJumbpox"
  default       = "zabbix_v0.1.bash"
}

variable "zabbix_internet_access" {
  description = "Internet access for Jumpbox true or false"
  type        = bool
  default     = false 
}