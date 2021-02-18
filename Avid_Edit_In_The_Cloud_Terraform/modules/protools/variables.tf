#########################
# Input Variables       #
#########################

variable "admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "admin_password" {
  description = "Admin Password for Virtual Machines"
}

variable "resource_prefix" {
  description = "4 max characters to prefix each resource built"
}

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "github_url" {
  description = "Path to scripts location"
}

variable "vnet_subnet_id" {
  description = "Subnet where resources will be built"
}

variable "protools_vm_size" {
  description = "Size of ProTools VM"
}

variable "protools_nb_instances" {
  description = "Nb of Protools instances"
}

variable "ProToolsScript" {
  description = "Name of ProTools script"
  type = string 
}

variable "ProToolsinstaller" {
    type = string 
}

variable "protools_internet_access" {
    type = bool 
}

variable "TeradiciKey" {
    type = string 
}

variable "TeradiciURL" {
    type = string 
}

variable "AvidNexisInstaller" {
    type = string 
}

variable "gpu_type" {
    type = string 
}

