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
