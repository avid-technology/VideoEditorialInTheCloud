############## Environment Variables ##############

variable "resource_group_name" {
  description = "Resource group name that the network will be created in."
}

variable "resource_group_location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  default = {
    tag1 = ""
    tag2 = ""
  }
}

############## Network Variables ##############

variable "vnet_name" {
  description = "Name of the vnet to create"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.0.0.0/16"
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}

variable "subnets" {
  description = "all subnets with their name = address space"
  default     = {default = "10.1.0.0/24"}
}

# variable "whitelist_ip" {
#   description = "Give a name to security group"
#   type        = list(string)
# }

variable "build_network" {
  description = "Create Subnet Core"
  type        = bool
}

