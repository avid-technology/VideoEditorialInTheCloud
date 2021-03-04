#Create resource group
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags     = var.tags
}

#Create Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name  
  location            = var.resource_group_location
  address_space       = var.address_space
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_servers         = var.dns_servers
}

#Create subnet
resource "azurerm_subnet" "subnet" {
  for_each = var.subnets
  name                                            = each.key
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [each.value]
  enforce_private_link_endpoint_network_policies  = true
}

locals {
  subnet_ids = [for v in azurerm_subnet.subnet : v.id]
}

resource "azurerm_network_security_group" "security_group" {
  name                  = var.sg_name 
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.resource_group.name
  tags                  = var.tags
}

resource "azurerm_network_security_rule" "security_rule_rdp" {
  name                        = "Rdp"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

resource "azurerm_network_security_rule" "security_rule_ssh" {
  name                        = "Ssh"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

resource "azurerm_network_security_rule" "security_rule_ansible" {
  name                        = "Ansible_Winrm"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5986"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet" {
  for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.security_group.id
}