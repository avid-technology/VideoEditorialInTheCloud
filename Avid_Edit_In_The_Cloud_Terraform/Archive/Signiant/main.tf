terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "= 2.33.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "admin_username" {
    type = string
    description = "Administrator user name for virtual machine"
}

variable "admin_password" {
    type = string
    description = "Password must meet Azure complexity requirements"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "sigrgtest"
  location = "westus2"
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "rgVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "sigSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "sig-vm-01-ip"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "sig-vm-01-nsg"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                      = "sig-vm-01-nic"
  location                  = "westus2"
  resource_group_name       = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "sigNICConfg"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "sig-vm-01"
  location              = "westus2"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_D8s_v4"

  storage_os_disk {
    name              = "sig-OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "sig-vm-01"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_virtual_machine.vm.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm]
}
