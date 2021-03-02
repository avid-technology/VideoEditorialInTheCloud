###############
### Generic ###
###############

variable "local_admin_username" {
    type = string
}

variable "local_admin_password" {
    type = string 
    sensitive = true
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

variable "domainName" {
  description = "Domain Name"
  type        = string
  default     = null
}

######################
### Network Module ###
######################

variable "resource_group_location"{
    type = string
    description = "resource group name"
}

variable "vnet_address_space" {
    type = list(string)
    description = "resource group name"
}

variable "dns_servers" {
    type = list(string)
    description = "resource group name"
}

variable "subnets" {
    type = map
    description = "resource group name"
}

variable "azureTags" {
    type = map
    description = "resource group name"
}

######################
### Nexis          ###
#######################

variable "AvidNexisInstaller" {
    type = string 
}

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

######################
### Teradici       ###
#######################

variable "TeradiciKey" {
    type = string 
}

variable "TeradiciInstaller" {
    type = string 
}

######################
### Domaincontroller      ###
#######################

variable "domaincontroller_nb_instances" {
    type = number
}

######################
### Jumpbox Module ###
#######################

variable "jumpbox_vm_size" {
    type = string 
}

variable "jumpbox_nb_instances" {
    type = number
}

variable "jumpbox_internet_access" {
    type = bool 
}

variable "JumpboxScript" {
    type = string 
}

#######################
### ProTools Module ###
#######################

variable "protools_vm_size" {
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
    type = number 
}

variable "ProToolsVersion" {
    type = string 
}

variable "protoolsScript" {
    type = string 
}

variable "protools_internet_access" {
    type = bool 
}

############################
### MediaComposer Module ###
############################

variable "mediacomposer_vm_size" {
    type = string 
}

variable "mediacomposer_nb_instances" {
    type = number 
}

variable "mediacomposerVersion" {
    type = string 
}

variable "mediacomposer_internet_access" {
    type = bool 
}

variable "mediacomposerScript" {
  description = "Pscript to install MediaComposer"
  default     = "setupMediaComposer_v0.1.ps1"
}

############################
### Zabbix Module ###
############################

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
  default       = "zabbix_v0.1.ps1"
}

variable "zabbix_internet_access" {
  description = "Internet access for Jumpbox true or false"
  type        = bool
  default     = false 
}