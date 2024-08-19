# Output the VM's public IP address
output "vm_public_ip" {
  value = azurerm_public_ip.example.ip_address
}
