# Resource Group
resource "azurerm_resource_group" "kalenski_rg" {
  name     = "kalenski-resources"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "kalenski_vnet" {
  name                = "kalenski-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalenski_rg.location
  resource_group_name = azurerm_resource_group.kalenski_rg.name
}

# Subnet
resource "azurerm_subnet" "kalenski_subnet" {
  name                 = "kalenski-subnet"
  resource_group_name  = azurerm_resource_group.kalenski_rg.name
  virtual_network_name = azurerm_virtual_network.kalenski_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "kalenski_nsg" {
  name                = "kalenski-nsg"
  location            = azurerm_resource_group.kalenski_rg.location
  resource_group_name = azurerm_resource_group.kalenski_rg.name

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
resource "azurerm_network_interface" "kalenski_nic" {
  name                = "kalenski-nic"
  location            = azurerm_resource_group.kalenski_rg.location
  resource_group_name = azurerm_resource_group.kalenski_rg.name

  ip_configuration {
    name                          = "kalenski-ip-config"
    subnet_id                     = azurerm_subnet.kalenski_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Attach NSG to NIC (Network Interface)
resource "azurerm_network_interface_security_group_association" "kalenski_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.kalenski_nic.id
  network_security_group_id = azurerm_network_security_group.kalenski_nsg.id
}
