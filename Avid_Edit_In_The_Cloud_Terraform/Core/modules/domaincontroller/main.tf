data "azurerm_subnet" "data_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

locals {
  domaincontrollerScripturl    = "${var.script_url}${var.domaincontrollerScript}${var.sas_token}"
}

resource "azurerm_public_ip" "domaincontroller_ip" {
  count               = var.domaincontroller_internet_access ? var.domaincontroller_nb_instances : 0
  name                = "${var.domaincontroller_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "domaincontroller_nic" {
  count                         = var.domaincontroller_nb_instances
  name                          = "${var.domaincontroller_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = data.azurerm_subnet.data_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.domaincontroller_internet_access ? azurerm_public_ip.domaincontroller_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "domaincontroller_vm" {
  count                         = var.domaincontroller_nb_instances
  name                          = "${var.domaincontroller_vm_hostname}-vm-${format("%02d",count.index)}"
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = "${var.domaincontroller_vm_hostname}-vm-${format("%02d",count.index)}"
  size                          = var.domaincontroller_vm_size
  admin_username                = var.local_admin_username
  admin_password                = var.local_admin_password
  network_interface_ids         = [azurerm_network_interface.domaincontroller_nic[count.index].id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                          = "${var.domaincontroller_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching                       = "ReadWrite"
    storage_account_type          = "Premium_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "domaincontroller_extension" {
  count                 = var.domaincontroller_nb_instances
  name                  = "domaincontrollerextension"
  virtual_machine_id    = azurerm_windows_virtual_machine.domaincontroller_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.domaincontroller_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.domaincontrollerScripturl}"]
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.domaincontrollerScript}"
    }
  PROTECTED_SETTINGS
}


