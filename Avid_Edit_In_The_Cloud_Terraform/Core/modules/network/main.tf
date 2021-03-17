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

resource "azurerm_subnet" "subnet_core" {
  name                                            = "subnet_core"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_core"]]
}

resource "azurerm_subnet" "subnet_mediacentral" {
  count                                           = var.create_subnet_Mediacentral ? 1 : 0
  name                                            = "subnet_mediacentral"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_mediacentral"]]
  service_endpoints                               = ["Microsoft.Storage"]
  enforce_private_link_service_network_policies   = true
}

resource "azurerm_subnet" "subnet_monitor" {
  count                                           = var.create_subnet_Monitor ? 1 : 0
  name                                            = "subnet_monitor"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_monitor"]]
}

resource "azurerm_subnet" "subnet_remote" {
  count                                           = var.create_subnet_Remote ? 1 : 0
  name                                            = "subnet_remote"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_remote"]]
}

resource "azurerm_subnet" "subnet_storage" {
  count                                           = var.create_subnet_Storage ? 1 : 0
  name                                            = "subnet_storage"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_storage"]]
  service_endpoints                               = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies  = true
  enforce_private_link_service_network_policies   = true
}

resource "azurerm_subnet" "subnet_transfer" {
  count                                           = var.create_subnet_Transfer ? 1 : 0
  name                                            = "subnet_transfer"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_transfer"]]
  service_endpoints                               = ["Microsoft.Storage"]
  enforce_private_link_service_network_policies   = true
}

resource "azurerm_subnet" "subnet_workstations" {
  count                                           = var.create_subnet_Workstations ? 1 : 0
  name                                            = "subnet_workstations"
  virtual_network_name                            = azurerm_virtual_network.vnet.name 
  resource_group_name                             = azurerm_resource_group.resource_group.name
  address_prefixes                                = [var.subnets["subnet_workstations"]]
  service_endpoints                               = ["Microsoft.Storage"]
  enforce_private_link_service_network_policies   = true
}

resource "azurerm_network_security_group" "nsg_default" {
  name                  = "${var.resource_group_name}-nsg_default" 
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.resource_group.name
  tags                  = var.tags
}

resource "azurerm_network_security_group" "nsg_remote" {
  count                 = var.create_subnet_Remote ? 1 : 0
  name                  = "${var.resource_group_name}-nsg-remote"  
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.resource_group.name
  tags                  = var.tags
}

resource "azurerm_network_security_rule" "security_rule_rdp" {
  count                       = var.create_subnet_Remote ? 1 : 0
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
  network_security_group_name = azurerm_network_security_group.nsg_remote[count.index].name
}

resource "azurerm_network_security_rule" "security_rule_ssh" {
  count                       = var.create_subnet_Remote ? 1 : 0
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
  network_security_group_name = azurerm_network_security_group.nsg_remote[count.index].name
}

resource "azurerm_network_security_rule" "security_rule_ansible" {
  count                       = var.create_subnet_Remote ? 1 : 0
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
  network_security_group_name = azurerm_network_security_group.nsg_remote[count.index].name
}

resource "azurerm_network_security_rule" "security_rule_https" {
  count                       = var.create_subnet_Remote ? 1 : 0
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
  network_security_group_name = azurerm_network_security_group.nsg_remote[count.index].name
}

resource "azurerm_network_security_rule" "security_rule_teradici_in_tcp" {
  count                       = var.create_subnet_Remote ? 1 : 0
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
  network_security_group_name = azurerm_network_security_group.nsg_remote[count.index].name
}

resource "azurerm_network_security_rule" "security_rule_teradici_in_udp" {
  count                       = var.create_subnet_Remote ? 1 : 0
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
  network_security_group_name = azurerm_network_security_group.nsg_remote[count.index].name
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_storage" {
  count                     = var.create_subnet_Storage ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet_storage[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_monitor" {
  count                     = var.create_subnet_Monitor ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet_monitor[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_core" {
  subnet_id                 = azurerm_subnet.subnet_core.id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_workstations" {
  count                     = var.create_subnet_Workstations ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet_workstations[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_remote" {
  count                     = var.create_subnet_Remote ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet_remote[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_remote[count.index].id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_mediacentral" {
  count                     = var.create_subnet_Mediacentral ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet_mediacentral[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}

resource "azurerm_subnet_network_security_group_association" "associate_subnet_transfer" {
  count                     = var.create_subnet_Transfer ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet_transfer[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg_default.id
}
