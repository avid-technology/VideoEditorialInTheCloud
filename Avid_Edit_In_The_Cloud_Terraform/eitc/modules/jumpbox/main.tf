resource "azurerm_public_ip" "jumpbox_ip" {
  count               = var.jumpbox_vm_instances
  name                = "${var.jumpbox_vm_hostname}-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "jumpbox_nic" {
  count                         = var.jumpbox_nb_instances
  name                          = "${var.jumpbox_vm_hostname}-nic"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.jumpbox_internet_access ? azurerm_public_ip.ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "jumpbox_vm" {
  count                         = var.jumpbox_nb_instances
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
    name                  = "${var.jumpbox_vm_hostname}-osdisk"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "jumpbox_extension" {
  count                 = var.jumpbox_nb_instances
  name                  = "jumbpox_extension"
  virtual_machine_id    = azurerm_windows_virtual_machine.jumpbox_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.jumpbox_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${var.JumpboxScriptURL}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File jumpbox_v0.1.ps1"
    }
  PROTECTED_SETTINGS
}

