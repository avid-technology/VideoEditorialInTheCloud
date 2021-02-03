output "vnet_id" {
  description = "The id of the newly created vNet"  
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The Name of the newly created vNet"  
  value = azurerm_virtual_network.vnet.name
}

output "vnet_location" {
  description = "The location of the newly created vNet"    
  value = azurerm_virtual_network.vnet.location
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"    
  value = azurerm_virtual_network.vnet.address_space
}

output "security_group_id" {
  description = "The id of the security group attached to subnets inside the newly created vNet. Use this id to associate additional network security rules to subnets."    
  value = azurerm_network_security_group.security_group.id
}
output "azurerm_resource_group_name" {
  value       = azurerm_resource_group.resource_group.name
  description = "The name of resource group created"
}
output "azurerm_resource_group_location" {
  value       = azurerm_resource_group.resource_group.location
  description = "The location/region of resource group created"
}

output "azurerm_subnet_ids" {
  value       = local.subnet_ids
  description = "The subnet IDs for the VNET"
}