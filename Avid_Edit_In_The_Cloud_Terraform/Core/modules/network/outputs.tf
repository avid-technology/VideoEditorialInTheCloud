output "subnet_core_id" {
  description = "Id of subnet Core"  
  value = azurerm_subnet.subnet_core.id
}

output "vnet_id" {
  description = "Id of subnet Core"  
  value = azurerm_virtual_network.vnet.id
}