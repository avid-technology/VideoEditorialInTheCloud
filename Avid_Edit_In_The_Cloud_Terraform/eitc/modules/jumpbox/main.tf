resource "azurerm_public_ip" "ip" {
  count               = var.jumpbox_vm_instances
  name                = "${var.resource_group_name}-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count                         = var.jumpbox_vm_instances
  name                          = "${var.resource_group_name}-nic"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "jumpbox_vm" {
  count                         = var.jumpbox_vm_instances
  name                          = "${var.jumpbox_vm_hostname}-vm"
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = var.jumpbox_vm_hostname
  size                          = var.jumpbox_vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "rs5-pro"
    version   = "latest"
  }

  os_disk {
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
  }

}

