###############
### Generic ###
###############

variable "admin_username" {
    type = string
}

variable "admin_password" {
    type = string 
}

variable "resource_prefix" {
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
### Jumpbox Module ###
#######################

variable "jumpbox_vm_size" {
    type = string 
}

variable "jumpbox_vm_instances" {
    type = string 
}

#######################
### ProTools Module ###
#######################

variable "protools_vm_size" {
    type = string 
}

variable "protools_vm_instances" {
    type = string 
}