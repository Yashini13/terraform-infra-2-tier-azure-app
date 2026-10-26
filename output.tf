output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "app_gateway_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "static_web_app_default_hostname" {
  value = azurerm_static_web_app.frontend.default_host_name
}

output "sql_server_fqdn" {
  description = "SQL Server private FQDN"
  value       = azurerm_mssql_server.sql.fully_qualified_domain_name
}

