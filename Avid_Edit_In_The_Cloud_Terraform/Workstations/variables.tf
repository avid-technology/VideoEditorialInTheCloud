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
