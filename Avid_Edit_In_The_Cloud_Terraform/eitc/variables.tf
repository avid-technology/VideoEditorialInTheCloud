###############
### Generic ###
###############

variable "admin_username" {
    type = string
}

variable "admin_password" {
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

variable "NvidiaURL" {
    type = string 
}

variable "branch"{
    type = string
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

variable "AvidNexisInstallerUrl" {
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

variable "nexis_storage_configuration" {
    type = map
}

variable "nexis_storage_account_configuration" {
    type = map
}

######################
### Teradici       ###
#######################

variable "TeradiciKey" {
    type = string 
}

variable "TeradiciURL" {
    type = string 
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
}

variable "protools_nb_instances" {
    type = number 
}

variable "ProToolsScript" {
    type = string 
}

variable "ProToolsURL" {
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

variable "mediacomposerScript" {
    type = string 
}

variable "mediacomposerVersion" {
    type = string 

    validation {
            condition       = (
                var.mediacomposerVersion == "2021.2.0" || 
                var.mediacomposerVersion == "2020.12.0" ||
                var.mediacomposerVersion == "2018.12.14"
            )
            error_message   = "Only the following versions are supported: 2020.12.0, 2020.12.0 and 2018.12.14."
        }
}

variable "mediacomposer_internet_access" {
    type = bool 
}