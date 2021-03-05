
locals {
  resource_group_name        = "${var.resource_prefix}-rg"
  mccentersql_vm_hostname    = "${var.resource_prefix}-mamsql"
  mccentersqlScriptUrl       = "${var.script_url}${var.mccentersqlScript}"
}

resource "azurerm_public_ip" "mccentersql_ip" {
  count               = var.mmccentersql_internet_access ? var.mccentersql_nb_instances : 0
  name                = "${local.mccentersql_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "mccentersql_nic" {
  count                         = var.mccentersql_nb_instances
  name                          = "${local.mccentersql_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.mccentersql_internet_access ? azurerm_public_ip.mccentersql_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "mccentersql_vm" {
  count                 = var.mccentersql_nb_instances
  name                  = "${local.mccentersql_vm_hostname}-${format("%02d",count.index)}"
  location              = var.resource_group_location
  resource_group_name   = local.resource_group_name
  network_interface_ids = [azurerm_network_interface.mccentersql_nic[count.index].id]
  size                  = var.mccentersql_vm_size
  computer_name         = "${local.mccentersql_vm_hostname}-${format("%02d",count.index)}"
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2017-ws2019"
    sku       = "Standard"
    version   = "latest"
  }

  os_disk {
    name                  = "${local.mccentersql_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching               = "ReadOnly"
    storage_account_type  = "Premium_LRS"
  }
}

resource "azurerm_mssql_virtual_machine" "mccentermsql_vm" {
  count                            = var.mccentersql_nb_instances
  virtual_machine_id               = azurerm_windows_virtual_machine.mccentersql_vm[count.index].id
  sql_license_type                 = "PAYG"
  sql_connectivity_update_password = var.local_admin_password
  sql_connectivity_update_username = var.local_admin_username
}

resource "azurerm_virtual_machine_extension" "mccentersql_extension" {
  count                 = var.mccentersql_nb_instances
  name                  = "mccenter_extension"
  virtual_machine_id    = azurerm_windows_virtual_machine.mccentersql_vm[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_mssql_virtual_machine.mccentermsql_vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.mccentersqlScriptUrl}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.mccentersqlScript} ${var.domainName} ${var.domain_admin_username} ${var.domain_admin_password}"
    }
  PROTECTED_SETTINGS
}



