# Key Vault
resource "azurerm_key_vault" "kalenski_kv" {
  name                = "kalenski-key-vault"
  location            = azurerm_resource_group.kalenski_rg.location
  resource_group_name = azurerm_resource_group.kalenski_rg.name
  tenant_id           = data.azurerm_client_config.example.tenant_id
  sku_name            = "standard"
}

# Key Vault Secret (for the admin password)
resource "azurerm_key_vault_secret" "admin_password_secret" {
  name         = "vm-admin-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.kalenski_kv.id
}

# Managed Identity for VM
resource "azurerm_user_assigned_identity" "kalenski_identity" {
  name                = "kalenski-identity"
  location            = azurerm_resource_group.kalenski_rg.location
  resource_group_name = azurerm_resource_group.kalenski_rg.name
}

# Key Vault Access Policy for VM Managed Identity
resource "azurerm_key_vault_access_policy" "kalenski_kv_policy" {
  key_vault_id = azurerm_key_vault.kalenski_kv.id
  tenant_id    = data.azurerm_client_config.example.tenant_id
  object_id    = azurerm_user_assigned_identity.kalenski_identity.principal_id

  secret_permissions = ["Get", "List"]
}
