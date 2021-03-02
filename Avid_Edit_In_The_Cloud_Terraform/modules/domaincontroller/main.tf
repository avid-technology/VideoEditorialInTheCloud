
locals {
  resource_group_name           = "${var.resource_prefix}-rg"
  domaincontroller_vm_hostname  = "${var.resource_prefix}-dc"
  domaincontrollerScriptUrl      = "${var.script_url}${var.domaincontrollerScript}"
}

resource "azurerm_public_ip" "domaincontroller_ip" {
  count               = var.domaincontroller_internet_access ? var.domaincontroller_nb_instances : 0
  name                = "${local.domaincontroller_vm_hostname}-ip-${format("%02d",count.index)}"
  location            = var.resource_group_location
  resource_group_name = local.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "domaincontroller_nic" {
  count                         = var.domaincontroller_nb_instances
  name                          = "${local.domaincontroller_vm_hostname}-nic-${format("%02d",count.index)}"
  location                      = var.resource_group_location
  resource_group_name           = local.resource_group_name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.domaincontroller_internet_access ? azurerm_public_ip.domaincontroller_ip[count.index].id : ""
  }
}

resource "azurerm_windows_virtual_machine" "domaincontroller_vm" {
  count                         = var.domaincontroller_nb_instances
  name                          = "${local.domaincontroller_vm_hostname}-vm-${format("%02d",count.index)}"
  resource_group_name           = local.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = "${local.domaincontroller_vm_hostname}-vm-${format("%02d",count.index)}"
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
    name                          = "${local.domaincontroller_vm_hostname}-osdisk-${format("%02d",count.index)}"
    caching                       = "ReadWrite"
    storage_account_type          = "Premium_LRS"
  }
}


