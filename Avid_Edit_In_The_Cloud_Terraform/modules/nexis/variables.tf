#########################
# Input Variables       #
#########################

variable "hostname" {
  description = "Hostname of Cloud Nexis"
}

variable "admin_username" {
  description = "Admin Username to administrate Virtual Machines OS. Avid user is default Cloud Nexis administrator"
}

variable "admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "resource_group_location" {
  description = ""
}

variable "vnet_subnet_id" {
  description = ""
}

variable "resource_prefix" {
  description = "CIDR or source IP range or * to match any IP. Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used."
  default = "*"
}

variable "nexis_storage_vm_size" {
  description = "description"
}

variable "nexis_storage_nb_instances" {
  description = "description"
}

variable "nexis_storage_vm_script_url" { 
  type = string
}

variable "nexis_storage_vm_script_name" { 
  type = string
}

variable "nexis_storage_vm_artifacts_location" { 
  type = string
}

variable "nexis_storage_vm_build" { 
  type = string
}

variable "nexis_storage_vm_part_number" { 
  type = string
}

variable "nexis_storage_performance" { 
  type = string
}

variable "nexis_storage_replication" { 
  type = string
}

variable "nexis_storage_account_kind" { 
  type = string
}