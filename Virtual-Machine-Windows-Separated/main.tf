# Provider configuration
provider "azurerm" {
  features {}
}

# Get current client configuration (used for Key Vault)
data "azurerm_client_config" "example" {}

# Include other Terraform configuration files
module "network" {
  source = "./network"
}

module "vm" {
  source = "./vm"
}

module "keyvault" {
  source = "./keyvault"
}

module "diagnostics" {
  source = "./diagnostics"
}
