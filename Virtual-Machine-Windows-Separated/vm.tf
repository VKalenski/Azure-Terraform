# Virtual Machine
resource "azurerm_windows_virtual_machine" "kalenski_vm" {
  name                = "kalenski-windows-vm"
  resource_group_name = azurerm_resource_group.kalenski_rg.name
  location            = azurerm_resource_group.kalenski_rg.location
  size                = "Standard_F2"

  network_interface_ids = [
    azurerm_network_interface.kalenski_nic.id,
  ]

  admin_username = var.admin_username

  # Use secret from Key Vault for admin password
  admin_password = azurerm_key_vault_secret.admin_password_secret.value

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.kalenski_identity.id]
  }

  tags = {
    environment = "Production"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.kalenski_storage.primary_blob_endpoint
  }
}
