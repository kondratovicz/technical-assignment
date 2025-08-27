resource "azurerm_container_app_environment" "main" {
  name                       = "${var.name_prefix}-app-environment"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  internal_load_balancer_enabled = true
  infrastructure_subnet_id = azurerm_subnet.aca.id
}

module "backend" {
  source              = "./container_apps"
  name_prefix         = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  container_app_environment_id = azurerm_container_app_environment.main.id
  app_name            = "backend"
  target_port         = 5000
  envs = {
    NODE_ENV = "production"
    PORT     = "5000"
  }
}

module "frontend" {
  source              = "./container_apps"
  name_prefix         = var.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  container_app_environment_id = azurerm_container_app_environment.main.id
  app_name            = "frontend"
  target_port         = 80
  envs = {
    VITE_BACKEND_URL = "http://${module.backend.container_fqdn}:5000"
  }
  depends_on = [ module.backend ]
}
