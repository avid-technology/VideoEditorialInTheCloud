locals {
  ProToolsScriptURL           = "https://raw.githubusercontent.com/avid-technology/VideoEditorialInTheCloud/avid-development/Avid_Edit_In_The_Cloud_Terraform/eitc/scripts/setupProTools_2020.11.0.ps1"
  TeradiciKey                 = "0000"
  TeradiciURL                 = "https://eitcstore01.blob.core.windows.net/installers/pcoip-agent-graphics_20.10.1.exe"
  ProToolsURL                 = "https://eitcstore01.blob.core.windows.net/installers/Pro_Tools_2020.11.0_Win.zip"
  NvidiaURL                   = "https://"
  AvidNexisInstallerUrl       = "https://eitcstore01.blob.core.windows.net/installers/AvidNEXISClient_Win64_20.7.3.10.msi"
}

resource "azurerm_public_ip" "ip" {
  count               = var.protools_vm_instances
  name                = "${var.resource_group_name}-ip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count                         = var.protools_vm_instances
  name                          = "${var.resource_group_name}-nic"
  location                      = var.resource_group_location
  resource_group_name           = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count                         = var.protools_vm_instances
  name                          = "${var.resource_group_name}-vm"
  resource_group_name           = var.resource_group_name
  location                      = var.resource_group_location
  computer_name                 = var.protools_vm_hostname
  size                          = var.protools_vm_size
  admin_username                = var.admin_username
  admin_password                = var.admin_password
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]

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

resource "azurerm_virtual_machine_extension" "protools" {
  name                  = "protools"
  virtual_machine_id    = azurerm_windows_virtual_machine.vm[0].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.9"
  depends_on            = [azurerm_windows_virtual_machine.vm]

  # CustomVMExtension Documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
  settings = <<SETTINGS
    {
        "fileUris": ["${local.ProToolsScriptURL}"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File setupProTools_2020.11.0.ps1 ${local.TeradiciKey} ${local.TeradiciURL} ${local.ProToolsURL} ${local.NvidiaURL} ${local.AvidNexisInstallerUrl}"
    }
  PROTECTED_SETTINGS
}


