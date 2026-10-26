output "vnet_id" {
  description = "Virtual Network ID"
  value       = azurerm_virtual_network.vnet.id
}

output "appgw_subnet_id" {
  description = "AppGW Subnet ID"
  value       = azurerm_subnet.appgw_subnet.id
}

output "vmss_subnet_id" {
  description = "VMSS Subnet ID"
  value       = azurerm_subnet.vmss_subnet.id
}

output "db_subnet_id" {
  description = "Database Subnet ID"
  value       = azurerm_subnet.db_subnet.id
}

output "private_dns_zone_id" {
  description = "SQL Private DNS Zone ID"
  value       = azurerm_private_dns_zone.sql.id
}

output "private_endpoint_id" {
  description = "SQL Private Endpoint ID"
  value       = azurerm_private_endpoint.sql.id
}