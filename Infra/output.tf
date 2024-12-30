output "rg_name" {
  value       = data.azurerm_resource_group.maaz_rg.id
  description = "Record the value of resourse-group name, given by the data source"
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.testingEvn_linux_vm.public_ip_address
}

# output "id" {
  # value = data.azurerm_ssh_public_key.maaz_pubic_key.id
# }