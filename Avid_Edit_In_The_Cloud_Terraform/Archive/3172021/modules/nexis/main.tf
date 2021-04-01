locals{
  #resource_group_name                   = "${var.resource_prefix}-rg"
  hostname                              = var.hostname
  nexis_storage_vm_script_url           = "${var.nexis_storage_vm_script_url}${var.nexis_storage_vm_script_name}"
  nexis_storage_vm_artifacts_location   = trimsuffix(var.nexis_storage_vm_artifacts_location, "/") # remove last forward slash in path
}

resource "random_string" "nexis" {
    count   = var.nexis_storage_nb_instances
    length  = 5
    special = false
    upper   = false
}

#############################
# Storage Account for Nexis #
#############################
resource "azurerm_storage_account" "nexis_storage_account" {
  count                     = var.nexis_storage_nb_instances
  name                      = "${local.hostname}${format("%02d",count.index)}${random_string.nexis[count.index].result}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_kind              = var.nexis_storage_account_kind
  account_tier              = var.nexis_storage_performance
  account_replication_type  = var.nexis_storage_replication
  allow_blob_public_access  = var.storage_account_public_access
}

resource "azurerm_storage_account_network_rules" "nexis_network_rules" {
  count                       = var.storage_account_public_access ? var.nexis_storage_nb_instances : 0
  resource_group_name         = var.resource_group_name
  storage_account_name        = azurerm_storage_account.nexis_storage_account[count.index].name
  default_action              = "Deny"
  virtual_network_subnet_ids  = var.storage_account_subnet_access
}

resource "azurerm_private_endpoint" "nexis_private_endpoint" {
  count               = var.nexis_storage_nb_instances
  name                = "${local.hostname}${format("%02d",count.index)}${random_string.nexis[count.index].result}-pe"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  subnet_id           = var.vnet_subnet_id
  depends_on = [ random_string.nexis]

  private_service_connection {
    name                           = "${local.hostname}${format("%02d",count.index)}${random_string.nexis[count.index].result}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.nexis_storage_account.*.id[0]
    subresource_names              = ["blob"]
  } 
}

resource "azurerm_public_ip" "nexis_ip" {
  count               = var.nexis_internet_access ? var.nexis_storage_nb_instances : 0
  name                = "${local.hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nexis_nic" {
  count                         = var.nexis_storage_nb_instances
  name                          = "${local.hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.nexis_internet_access ? azurerm_public_ip.nexis_ip[count.index].id : ""
  }
}

resource "azurerm_linux_virtual_machine" "nexis_vm" {
  count                         = var.nexis_storage_nb_instances
  name                          = "${local.hostname}${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name
  size                          = var.nexis_storage_vm_size
  network_interface_ids         = [azurerm_network_interface.nexis_nic[count.index].id]
  admin_username                = "avid"
  admin_password                = var.local_admin_password
  computer_name                 = "${local.hostname}${format("%02d",count.index)}"
  disable_password_authentication = false

  source_image_reference {
    publisher = var.nexis_image_reference["publisher"]
    offer     = var.nexis_image_reference["offer"]
    sku       = var.nexis_image_reference["sku"]
    version   = var.nexis_image_reference["version"]
  }

  os_disk {
    name                          = "${local.hostname}-osdisk-${format("%02d",count.index)}"
    caching                       = "ReadWrite"
    storage_account_type          = "Premium_LRS"
    disk_size_gb                  = "1024"
  }
}

resource "azurerm_managed_disk" "nexis_datadisk" {
  count                = var.nexis_storage_nb_instances
  name                 = "${local.hostname}-datadisk-${format("%02d",count.index)}"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 768
}

resource "azurerm_virtual_machine_data_disk_attachment" "nexis_datadisk_attachement" {
  count              = var.nexis_storage_nb_instances
  managed_disk_id    = azurerm_managed_disk.nexis_datadisk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.nexis_vm[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_extension" "nexis_storage_servers" {
  count                 = var.nexis_storage_nb_instances
  name                  = "nexis"
  virtual_machine_id    = azurerm_linux_virtual_machine.nexis_vm[count.index].id
  publisher             = "Microsoft.Azure.Extensions"
  type                  = "CustomScript"
  type_handler_version  = "2.0"
  depends_on            = [azurerm_virtual_machine_data_disk_attachment.nexis_datadisk_attachement]

  settings = <<EOF
    {
    "fileUris": [
          "${local.nexis_storage_vm_script_url}"
        ]
    }
  EOF
  protected_settings = <<PROT
    {
        
        "commandToExecute": "/bin/bash ${var.nexis_storage_vm_script_name} ${azurerm_linux_virtual_machine.nexis_vm[count.index].name} ${local.nexis_storage_vm_artifacts_location} ${var.nexis_storage_vm_build} ${var.nexis_storage_vm_part_number}"
    }
    PROT
}