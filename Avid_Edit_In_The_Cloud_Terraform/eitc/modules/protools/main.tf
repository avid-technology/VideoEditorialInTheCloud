locals {
  
}

resource "azurerm_public_ip" "protools_ip" {
  count               = var.protools_internet_access ? var.protools_nb_instances : 0
  name                = "${var.protools_vm_hostname}-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "protools_nic" {
  count                         = var.protools_nb_instances
  name                          = "${var.protools_vm_hostname}-nic"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
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
  name                          = "${var.protools_vm_hostname}-vm"
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = var.protools_vm_hostname
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
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
  }

}

resource "azurerm_virtual_machine_extension" "protools_extension" {
  count                 = var.protools_nb_instances
  name                  = "protools"
  virtual_machine_id    = azurerm_windows_virtual_machine.protools_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.protools_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${var.ProToolsScript}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File setupProTools_2020.11.0.ps1 ${var.TeradiciKey} ${var.TeradiciURL} ${var.ProToolsURL} ${var.NvidiaURL} ${var.AvidNexisInstallerUrl}"
    }
  PROTECTED_SETTINGS
}


