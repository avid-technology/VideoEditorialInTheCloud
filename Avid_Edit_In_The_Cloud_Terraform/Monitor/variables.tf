# ############## Environment Variables ##############

# variable "local_admin_username" {
#     type = string
# }

# variable "local_admin_password" {
#     type = string 
#     sensitive = true
# }

# variable "domainName" {
#   description = "Domain Name"
#   type        = string
#   default     = null
# }

# variable "domain_admin_username" {
#     type = string
# }

# variable "domain_admin_password" {
#     type = string 
#     sensitive = true
# }

# variable "resource_prefix" {
#     type = string

#     validation {
#         condition       = length(var.resource_prefix) <= 4
#         error_message   = "Resource prefix must be less than 4 characters."
#     }
# }

# variable "branch"{
#     type = string
# }

# variable "installers_url"{
#     type = string
# }

# variable "resource_group_location"{
#     type = string
#     description = "resource group name"
# }

# ############## Zabbix Variables ##############

# variable "zabbix_vm_size" {
#   description = "Size of Jumpbox VM"
#   default     = "Standard_D4s_v3"
# }

# variable "zabbix_nb_instances" {
#   description = "Number of jumpbox instances"
#   default     = 0
# }

# variable "zabbixScript" {
#   description   = "Script name forJumbpox"
#   default       = "zabbix_v0.1.bash"
# }

# variable "zabbix_internet_access" {
#   description = "Internet access for Jumpbox true or false"
#   type        = bool
#   default     = false 
# }