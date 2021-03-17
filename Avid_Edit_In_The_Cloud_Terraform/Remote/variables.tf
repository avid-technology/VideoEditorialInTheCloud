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

variable "azureTags" {
    type = map
    description = "resource group name"
}

############## DomainController Variables ##############

variable "domaincontroller_nb_instances" {
  description = "Number of domaincontroller instances"
  default     = 0
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

