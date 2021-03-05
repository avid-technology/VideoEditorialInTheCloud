
locals {
  resource_group_name      = "${var.resource_prefix}-rg"
  mcworker_vm_hostname    = "${var.resource_prefix}-mcw"
  mcworkerScriptUrl       = "${var.script_url}${var.mcworkerScript}"
  mcaminstallerUrl        = "${var.installers_url}MediaCentral_Asset_Management_${var.mcamversion}_Win.zip"
}

resource "azurerm_public_ip" "mcworker_ip" {
  count               = var.mcworker_nb_instances
  name                = "${local.mcworker_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "mcworker_nic" {
  count                         = var.mcworker_nb_instances
  name                          = "${local.mcworker_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.mcworker_internet_access ? azurerm_public_ip.mcworker_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "mcworker_vm" {
  count                         = var.mcworker_nb_instances
  name                          = "${local.mcworker_vm_hostname}${format("%02d",count.index)}"
  resource_group_name           = local.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = "${local.mcworker_vm_hostname}${format("%02d",count.index)}"
  size                          = var.mcworker_vm_size
  admin_username                = var.local_admin_username
  admin_password                = var.local_admin_password
  network_interface_ids         = [azurerm_network_interface.mcworker_nic[count.index].id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                          = "${local.mcworker_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching                       = "ReadWrite"
    storage_account_type          = "Premium_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "mcworker_extension" {
  count                 = var.mcworker_nb_instances
  name                  = "mcworker_extension"
  virtual_machine_id    = azurerm_windows_virtual_machine.mcworker_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.mcworker_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.mcworkerScriptUrl}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.mcworkerScript} ${local.mcaminstallerUrl} ${var.domainName} ${var.domain_admin_username} ${var.domain_admin_password}"
    }
  PROTECTED_SETTINGS
}

