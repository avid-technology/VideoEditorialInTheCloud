data "azurerm_subnet" "data_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  mediacomposerScripturl    = "${var.script_url}${var.mediacomposerScript}${var.sas_token}"
}

resource "azurerm_public_ip" "mediacomposer_ip" {
  count               = var.mediacomposer_internet_access ? var.mediacomposer_nb_instances : 0
  name                = "${var.mediacomposer_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "mediacomposer_nic" {
  count                         = var.mediacomposer_nb_instances
  name                          = "${var.mediacomposer_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.data_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.mediacomposer_internet_access ? azurerm_public_ip.mediacomposer_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "mediacomposer_vm" {
  count                         = var.mediacomposer_nb_instances
  name                          = "${var.mediacomposer_vm_hostname}-vm-${format("%02d",count.index)}"
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = "${var.mediacomposer_vm_hostname}-vm-${format("%02d",count.index)}"
  size                          = var.mediacomposer_vm_size
  admin_username                = var.local_admin_username
  admin_password                = var.local_admin_password
  network_interface_ids         = [azurerm_network_interface.mediacomposer_nic[count.index].id]

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  os_disk {
    name                          = "${var.mediacomposer_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching                       = "ReadWrite"
    storage_account_type          = "Premium_LRS"
  }

}

resource "azurerm_virtual_machine_extension" "mediacomposer_extension_1" {
  count                 = var.mediacomposer_nb_instances
  name                  = "mediacomposer1"
  virtual_machine_id    = azurerm_windows_virtual_machine.mediacomposer_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.mediacomposer_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.mediacomposerScripturl}"]
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.mediacomposerScript}"
    }
  PROTECTED_SETTINGS
}

# "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.mediacomposerScript} ${var.TeradiciKey} ${local.TeradiciURL} ${local.MediacomposerURL} ${local.AvidNexisInstallerUrl} ${var.domainName} ${var.domain_admin_username} ${var.domain_admin_password}"

# resource "azurerm_virtual_machine_extension" "mediacomposer_extension_2" {
#   count                       = var.mediacomposer_nb_instances
#   name                        = "mediacomposer2"
#   virtual_machine_id          = azurerm_windows_virtual_machine.mediacomposer_vm[count.index].id
#   publisher                   = "Microsoft.HpcCompute"
#   type                        = local.gpu_driver
#   type_handler_version        = "1.0"
#   auto_upgrade_minor_version  = true
#   depends_on                  = [azurerm_virtual_machine_extension.mediacomposer_extension_1]
# }


