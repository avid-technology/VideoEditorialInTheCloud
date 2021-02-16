locals {
  resource_group_name       = "${var.resource_prefix}-rg"
  mediacomposer_vm_hostname = "${var.resource_prefix}-mc"
}

resource "azurerm_public_ip" "mediacomposer_ip" {
  count               = var.mediacomposer_internet_access ? var.mediacomposer_nb_instances : 0
  name                = "${local.mediacomposer_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "mediacomposer_nic" {
  count                         = var.mediacomposer_nb_instances
  name                          = "${local.mediacomposer_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.mediacomposer_internet_access ? azurerm_public_ip.mediacomposer_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "mediacomposer_vm" {
  count                         = var.mediacomposer_nb_instances
  name                          = "${local.mediacomposer_vm_hostname}-vm-${format("%02d",count.index)}"
  resource_group_name           = local.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = "${local.mediacomposer_vm_hostname}-vm-${format("%02d",count.index)}"
  size                          = var.mediacomposer_vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  network_interface_ids         = [azurerm_network_interface.mediacomposer_nic[count.index].id]

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "rs5-pro"
    version   = "latest"
  }

  os_disk {
    name                  = "${local.mediacomposer_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
  }

}

resource "azurerm_virtual_machine_extension" "mediacomposer_extension" {
  count                 = var.mediacomposer_nb_instances
  name                  = "mediacomposer"
  virtual_machine_id    = azurerm_windows_virtual_machine.mediacomposer_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.mediacomposer_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${var.mediacomposerScript}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File setupMediaComposer_NVIDIA_202.ps1 ${var.TeradiciKey} ${var.TeradiciURL} ${var.mediacomposerURL} ${var.NvidiaURL} ${var.AvidNexisInstallerUrl}"
    }
  PROTECTED_SETTINGS
}


