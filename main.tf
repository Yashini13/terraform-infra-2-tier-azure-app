resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_static_web_app" "frontend" {
  name                = "swa-2tier-demo-adhira01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "Central US"
  sku_tier            = "Standard"
  sku_size            = "Standard"
}


resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = "vmss-backend"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  instances                       = var.vmss_instance_count
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  upgrade_mode                    = "Manual"

  sku = "Standard_D2s_v3" # ← change this

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts" # ← back to original x64
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = base64encode(file("${path.module}/cloud-init.sh"))

  identity {
  type = "SystemAssigned"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = azurerm_subnet.vmss_subnet.id

      application_gateway_backend_address_pool_ids = [
        for pool in azurerm_application_gateway.appgw.backend_address_pool :
        pool.id if pool.name == "backend-vmss-pool"
      ]
    }
  }
}


resource "azurerm_application_gateway" "appgw" {
  name                = "agw-2tier-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = filebase64("${path.module}/cert.pfx")
    password = var.ssl_certificate_password
  }

  backend_address_pool {
    name  = "frontend-swa-pool"
    fqdns = [azurerm_static_web_app.frontend.default_host_name]
  }

  backend_address_pool {
    name = "backend-vmss-pool"
  }

  backend_http_settings {
    name                                = "http-setting-swa"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "probe-swa"
  }

  backend_http_settings {
    name                  = "http-setting-vmss"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-vmss"
  }

  probe {
    name                                      = "probe-swa"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                = "probe-vmss"
    protocol            = "Http"
    path                = "/api/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    host                = "127.0.0.1"

    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "listener-https"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
  }

  redirect_configuration {
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "listener-https"
    include_path         = true
    include_query_string = true
  }

  url_path_map {
    name                               = "path-map"
    default_backend_address_pool_name  = "frontend-swa-pool"
    default_backend_http_settings_name = "http-setting-swa"

    path_rule {
      name                       = "api-path"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-vmss-pool"
      backend_http_settings_name = "http-setting-vmss"
    }
  }

  request_routing_rule {
    name                        = "rule-http-redirect"
    rule_type                   = "Basic"
    http_listener_name          = "listener-http"
    redirect_configuration_name = "http-to-https-redirect"
    priority                    = 90
  }

  request_routing_rule {
    name               = "rule-path-based-https"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-https"
    url_path_map_name  = "path-map"
    priority           = 100
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = "agw-2tier-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = filebase64("${path.module}/cert.pfx")
    password = var.ssl_certificate_password
  }

  backend_address_pool {
    name  = "frontend-swa-pool"
    fqdns = [azurerm_static_web_app.frontend.default_host_name]
  }

  backend_address_pool {
    name = "backend-vmss-pool"
  }

  backend_http_settings {
    name                                = "http-setting-swa"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 30
    pick_host_name_from_backend_address = true
    probe_name                          = "probe-swa"
  }

  backend_http_settings {
    name                  = "http-setting-vmss"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-vmss"
  }

  probe {
    name                                      = "probe-swa"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true

    match {
      status_code = ["200-399"]
    }
  }

  probe {
    name                = "probe-vmss"
    protocol            = "Http"
    path                = "/api/health"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    host                = "127.0.0.1"

    match {
      status_code = ["200-399"]
    }
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "listener-https"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
  }

  redirect_configuration {
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "listener-https"
    include_path         = true
    include_query_string = true
  }

  url_path_map {
    name                               = "path-map"
    default_backend_address_pool_name  = "frontend-swa-pool"
    default_backend_http_settings_name = "http-setting-swa"

    path_rule {
      name                       = "api-path"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-vmss-pool"
      backend_http_settings_name = "http-setting-vmss"
    }
  }

  request_routing_rule {
    name                        = "rule-http-redirect"
    rule_type                   = "Basic"
    http_listener_name          = "listener-http"
    redirect_configuration_name = "http-to-https-redirect"
    priority                    = 90
  }

  request_routing_rule {
    name               = "rule-path-based-https"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-https"
    url_path_map_name  = "path-map"
    priority           = 100
  }
}
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "my-appgw-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_mssql_server" "sql" {
  name                          = "sql-2tier-demo"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = var.db_admin_username
  administrator_login_password  = var.db_admin_password
  public_network_access_enabled = false
  tags                          = {}
}

resource "azurerm_mssql_database" "appdb" {
  name      = "appdb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "Basic"
  tags      = {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "terraform_runner" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "Set", "Delete", "List", "Purge", "Recover"]
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-3tier-demo"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
}

resource "azurerm_role_assignment" "vmss_kv_access" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "db-username"
  value        = var.db_admin_username
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "db_connection" {
  name         = "db-connection"
  value        = "Server=tcp:${azurerm_mssql_server.sql.name}.database.windows.net,1433;Database=${azurerm_mssql_database.appdb.name};User ID=${var.db_admin_username};Password=${var.db_admin_password};Encrypt=True;"
  key_vault_id = azurerm_key_vault.kv.id
}