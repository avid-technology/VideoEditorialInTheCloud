output "azurerm_subnet_ids" {
  value       = module.editorial_networking.azurerm_subnet_ids
  description = "The subnet IDs for the VNET"
}