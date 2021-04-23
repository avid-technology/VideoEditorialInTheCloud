data "azurerm_subnet" "data_core" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  ansiblecontrollerScripturl = "${var.script_url}${var.ansiblecontrollerScript}"
}

resource "azurerm_public_ip" "ansiblecontroller_ip" {
  count               = var.ansiblecontroller_internet_access ? var.ansiblecontroller_nb_instances : 0
  name                = "${var.ansiblecontroller_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ansiblecontroller_nic" {
  count                         = var.ansiblecontroller_nb_instances
  name                          = "${var.ansiblecontroller_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  #enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.data_core.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.ansiblecontroller_internet_access ? azurerm_public_ip.ansiblecontroller_ip[count.index].id : ""
  }
}

resource "azurerm_linux_virtual_machine" "ansiblecontroller_vm" {
  count                             = var.ansiblecontroller_nb_instances
  name                              = "${var.ansiblecontroller_vm_hostname}-vm-${format("%02d",count.index)}"
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  size                              = var.ansiblecontroller_vm_size
  admin_username                    = var.local_admin_username
  admin_password                   = var.local_admin_password
  computer_name                     = "${var.ansiblecontroller_vm_hostname}-vm-${format("%02d",count.index)}"
  disable_password_authentication   = false
  network_interface_ids             = [azurerm_network_interface.ansiblecontroller_nic[count.index].id]

 source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                  = "${var.ansiblecontroller_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
    disk_size_gb          = "1024"
  }

}

resource "azurerm_virtual_machine_extension" "ansiblecontroller_extension" {
  count                = var.ansiblecontroller_nb_instances
  name                 = "ansiblecontroller1"
  virtual_machine_id   = azurerm_linux_virtual_machine.ansiblecontroller_vm[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.ansiblecontrollerScripturl}"]
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "./${var.ansiblecontrollerScript} ${var.local_admin_username}"
    }
  PROTECTED_SETTINGS

}
