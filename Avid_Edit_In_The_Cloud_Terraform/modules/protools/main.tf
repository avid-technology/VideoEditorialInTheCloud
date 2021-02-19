locals {
  resource_group_name       = "${var.resource_prefix}-rg"
  protools_vm_hostname      = "${var.resource_prefix}-pt"
  protoolsScripturl         = "${var.script_url}setupProTools_${var.ProToolsVersion}.ps1"
  gpu_driver                = "${var.gpu_type}GpuDriverWindows"
  TeradiciURL               = "${var.installers_url}${var.TeradiciInstaller}"
  ProToolsinstaller         = "${var.installers_url}Pro_Tools_${var.ProToolsVersion}_Win.zip"
  AvidNexisInstallerUrl     = "${var.installers_url}${var.AvidNexisInstaller}"
  protoolsScript            = "setupProTools_${var.ProToolsVersion}.ps1"
}

resource "azurerm_public_ip" "protools_ip" {
  count               = var.protools_internet_access ? var.protools_nb_instances : 0
  name                = "${local.protools_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "protools_nic" {
  count                         = var.protools_nb_instances
  name                          = "${local.protools_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.protools_internet_access ? azurerm_public_ip.protools_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "protools_vm" {
  count                         = var.protools_nb_instances
  name                          = "${local.protools_vm_hostname}-vm-${format("%02d",count.index)}"
  resource_group_name           = local.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = "${local.protools_vm_hostname}-vm-${format("%02d",count.index)}"
  size                          = var.protools_vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  network_interface_ids         = [azurerm_network_interface.protools_nic[count.index].id]

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "rs5-pro"
    version   = "latest"
  }

  os_disk {
    name                  = "${local.protools_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
  }

}

resource "azurerm_virtual_machine_extension" "protools_extension_1" {
  count                 = var.protools_nb_instances
  name                  = "protools1"
  virtual_machine_id    = azurerm_windows_virtual_machine.protools_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.protools_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.protoolsScripturl}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${local.protoolsScript} ${var.TeradiciKey} ${local.TeradiciURL} ${local.ProToolsinstaller} ${local.AvidNexisInstallerUrl}"
    }
  PROTECTED_SETTINGS
}

resource "azurerm_virtual_machine_extension" "protools_extension_2" {
  count                       = var.protools_nb_instances
  name                        = "protools2"
  virtual_machine_id          = azurerm_windows_virtual_machine.protools_vm[count.index].id
  publisher                   = "Microsoft.HpcCompute"
  type                        = local.gpu_driver
  type_handler_version        = "1.0"
  auto_upgrade_minor_version  = true
  depends_on                  = [azurerm_virtual_machine_extension.protools_extension_1]

  settings = <<SETTINGS
    {
    
    }
SETTINGS
}


