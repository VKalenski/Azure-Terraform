# Storage Account for Boot Diagnostics
resource "azurerm_storage_account" "kalenski_storage" {
  name                     = "kalenskistorage"
  resource_group_name      = azurerm_resource_group.kalenski_rg.name
  location                 = azurerm_resource_group.kalenski_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create Log Analytics Workspace for diagnostics
resource "azurerm_log_analytics_workspace" "kalenski_law" {
  name                = "kalenski-law"
  location            = azurerm_resource_group.kalenski_rg.location
  resource_group_name = azurerm_resource_group.kalenski_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
