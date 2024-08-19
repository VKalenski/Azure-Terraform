# Terraform script for creation Windows VM

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "example" {}

# Resource Group
resource "azurerm_resource_group" "kalenski-rg" {
  name     = "kalenski-resources"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "kalenski-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalenski-rg.location
  resource_group_name = azurerm_resource_group.kalenski-rg.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalenski-rg.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "example" {
  name                = "kalenski-nsg"
  location            = azurerm_resource_group.kalenski-rg.location
  resource_group_name = azurerm_resource_group.kalenski-rg.name

  security_rule {
    name                       = "allow_rdp"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface (NIC)
resource "azurerm_network_interface" "example" {
  name                = "kalenski-nic"
  location            = azurerm_resource_group.kalenski-rg.location
  resource_group_name = azurerm_resource_group.kalenski-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }

}

# Attach NSG to NIC (Network Interface)
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Key Vault
resource "azurerm_key_vault" "example" {
  name                = "kalenski-key-vault"
  location            = azurerm_resource_group.kalenski-rg.location
  resource_group_name = azurerm_resource_group.kalenski-rg.name
  tenant_id           = data.azurerm_client_config.example.tenant_id
  sku_name            = "standard"
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.kalenski-rg.name
  location            = azurerm_resource_group.kalenski-rg.location
  size                = "Standard_F2"
  # admin_username      = "adminuser"
  # admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  admin_username = "adminuser"

  # Use secret from Key Vault for admin password
  admin_password = azurerm_key_vault_secret.example.value

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
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  tags = {
    environment = "Production"
  }
}

# Key Vault Secret
resource "azurerm_key_vault_secret" "example" {
  name         = "vm-admin-password"
  value        = "P@$$w0rd1234!"
  key_vault_id = azurerm_key_vault.example.id
}

# Managed Identity for VM
resource "azurerm_user_assigned_identity" "example" {
  name                = "kalenski-identity"
  location            = azurerm_resource_group.kalenski-rg.location
  resource_group_name = azurerm_resource_group.kalenski-rg.name
}

# Key Vault Access Policy for VM Managed Identity
resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.example.tenant_id
  object_id    = azurerm_user_assigned_identity.example.principal_id

  secret_permissions = ["Get", "List"]
}

# Create Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "kalenski-law"
  location            = azurerm_resource_group.kalenski-rg.location
  resource_group_name = azurerm_resource_group.kalenski-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# # Configure diagnostics using Log Analytics Workspace
# resource "azurerm_monitor_diagnostic_setting" "example" {
#   name               = "vm-diagnostics"
#   target_resource_id = azurerm_windows_virtual_machine.example.id

#   log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

#   # Categories for logs
#   log {
#     category = "Administrative"
#     enabled  = true
#   }

#   log {
#     category = "Security"
#     enabled  = true
#   }

#   log {
#     category = "ServiceHealth"
#     enabled  = true
#   }

#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }
