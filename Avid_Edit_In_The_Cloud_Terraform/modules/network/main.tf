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

resource "azurerm_network_security_group" "nsg_default" {
  name                  = "${var.resource_group_name}-nsg_default" 
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.resource_group.name
  tags                  = var.tags
}

resource "azurerm_network_security_group" "nsg_remote" {
  name                  = "${var.resource_group_name}-nsg-remote"  
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.resource_group.name
  tags                  = var.tags
}

resource "azurerm_network_security_rule" "security_rule_rdp" {
  name                        = "RDP_Remote"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = var.whitelist_ip
  destination_port_range      = "3389"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_remote.name
}

resource "azurerm_network_security_rule" "security_rule_ssh" {
  name                        = "SSH_Remote"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = var.whitelist_ip
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_remote.name
}

resource "azurerm_network_security_rule" "security_rule_ansible" {
  name                        = "Ansible_Winrm"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = var.whitelist_ip
  destination_port_range      = "5986"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_remote.name
}

resource "azurerm_network_security_rule" "security_rule_https" {
  name                        = "HTTPS_In"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = var.whitelist_ip
  destination_port_range      = "443"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_remote.name
}

resource "azurerm_network_security_rule" "security_rule_teradici_in_tcp" {
  name                        = "Teradici_In_TCP"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = var.whitelist_ip
  destination_port_ranges     = ["4172","60443"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_remote.name
}

resource "azurerm_network_security_rule" "security_rule_teradici_in_udp" {
  name                        = "Teradici_In_UDP"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  source_address_prefixes     = var.whitelist_ip
  destination_port_range      = "4172"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg_remote.name
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_storage" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_storage"].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_monitor" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_monitor"].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_core2" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_core"].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_workstations" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_workstations"].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_remote" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_remote"].id
  network_security_group_id = azurerm_network_security_group.nsg_remote.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_mediacentral" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_mediacentral"].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_transfer" {
  #for_each = var.subnets
  subnet_id                 = azurerm_subnet.subnet["subnet_transfer"].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}
