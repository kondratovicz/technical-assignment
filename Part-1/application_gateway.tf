resource "azurerm_virtual_network" "main" {
  name                = "${var.name_prefix}-network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "aca" {
  name                 = "${var.name_prefix}-aca-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.254.0.0/21"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "${var.name_prefix}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.254.8.0/21"]
}

resource "azurerm_public_ip" "main" {
  name                = "${var.name_prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.main.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.main.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.main.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.main.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.main.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.main.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.main.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.name_prefix}-appgateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.main.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = toset([module.frontend.container_fqdn])
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}