############## Environment Variables ##############

variable "local_admin_username" {
  description = "Admin Username for Virtual Machines"
}

variable "local_admin_password" {
  description = "Admin Password for Virtual Machines"
}

# variable "domain_admin_username" {
#   description = "Domain admin user to join domain"
#   default     = ""
# }

variable "resource_group_name" {
  description = "Name of resource group where to build resources"
}

# variable "domainName" {
#   description = "Domain Name"
#   type        = string
#   default     = ""
# }

# variable "domain_admin_password" {
#   description = "Domain admin password to join domain"
#   default     = ""
#   sensitive   = true
# }

variable "resource_group_location" {
  description = "Location of resource group where to build resources"
}

variable "vnet_name" {
  description = "Name of vnet where resource will be built"
}

variable "subnet_name" {
  description = "Name of subnet where resource will be built"
}

variable "script_url" {
  description = "Location of all the powershell and bash scripts"
}

variable "sas_token" {
  description = "Sas token to access storage account"
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

variable "jumpbox_vm_hostname" {
  description = "Jumpbox hostname"
}

variable "JumpboxScript" {
  description = "Script name forJumbpox"
}

variable "jumpbox_internet_access" {
  description = "Internet access for Jumpbox true or false"
  type        = bool
  default     = false
}

############## Nexis Client Variables ##############

#variable "AvidNexisInstaller" {
#  description = "Cloud Nexis installer MSI name"
#}