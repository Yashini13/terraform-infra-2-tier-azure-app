
# resource "azurerm_virtual_network" "vnet" {
#   name                = "vnet-2tier-demo"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "appgw_subnet" {
#   name                 = "snet-appgw"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# resource "azurerm_subnet" "vmss_subnet" {
#   name                 = "snet-vmss"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

# resource "azurerm_subnet" "db_subnet" {
#   name                 = "snet-db"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.3.0/24"]

#   private_endpoint_network_policies = "Disabled"
# }

# resource "azurerm_network_security_group" "vmss_nsg" {
#   name                = "nsg-vmss"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   security_rule {
#     name                       = "Allow-AppGateway-To-HTTP"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_address_prefix      = "10.0.1.0/24"
#     source_port_range          = "*"
#     destination_address_prefix = "*"
#     destination_port_range     = "80"
#   }

#   security_rule {
#     name                       = "Allow-Azure-LB"
#     priority                   = 110
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_address_prefix      = "AzureLoadBalancer"
#     source_port_range          = "*"
#     destination_address_prefix = "*"
#     destination_port_range     = "*"
#   }

#   security_rule {
#     name                       = "Deny-All-Other-Inbound"
#     priority                   = 4096
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "*"
#     source_address_prefix      = "*"
#     source_port_range          = "*"
#     destination_address_prefix = "*"
#     destination_port_range     = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "vmss_assoc" {
#   subnet_id                 = azurerm_subnet.vmss_subnet.id
#   network_security_group_id = azurerm_network_security_group.vmss_nsg.id
# }

# resource "azurerm_network_security_group" "db_nsg" {
#   name                = "nsg-db"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   security_rule {
#     name                       = "Allow-VMSS-To-SQL"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_address_prefix      = "10.0.2.0/24"
#     source_port_range          = "*"
#     destination_address_prefix = "*"
#     destination_port_range     = "1433"
#   }

#   security_rule {
#     name                       = "Deny-All-Other-Inbound"
#     priority                   = 4096
#     direction                  = "Inbound"
#     access                     = "Deny"
#     protocol                   = "*"
#     source_address_prefix      = "*"
#     source_port_range          = "*"
#     destination_address_prefix = "*"
#     destination_port_range     = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "db_assoc" {
#   subnet_id                 = azurerm_subnet.db_subnet.id
#   network_security_group_id = azurerm_network_security_group.db_nsg.id
# }

# resource "azurerm_private_dns_zone" "sql" {
#   name                = "privatelink.database.windows.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
#   name                  = "sql-dns-link"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.sql.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
#   registration_enabled  = false
# }

# resource "azurerm_private_endpoint" "sql" {
#   name                = "pe-sql"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.db_subnet.id
#   tags                = {}

#   private_service_connection {
#     name                           = "sql-psc"
#     private_connection_resource_id = azurerm_mssql_server.sql.id
#     subresource_names              = ["sqlServer"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "sql-dns-zone-group"
#     private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
#   }
# }


# module "networkmodule" {

#   source  = "app.terraform.io/demo1303/networkmodule/github"
#   version = "1.0.0"
  
#   resource_group_name = azurerm_resource_group.rg.name
#   location           = azurerm_resource_group.rg.location
#   sql_server_id      = azurerm_mssql_server.sql.id

#   credentials "app.terraform.io" {
#   # valid user API token
#   token = "xxxxxx.atlasv1.zzzzzzzzzzzzz"
# }
# }

module "networkmodule" {
  source  = "app.terraform.io/demo1303/networkmodule/github"
  version = "1.0.0"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sql_server_id       = azurerm_mssql_server.sql.id
}
# export TF_TOKEN_app_terraform_io="xxxxxx.atlasv1.zzzzzzzzzzzzz"
# terraform init
