resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-logs"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "example" {
  name                       = "Example-Environment"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "backend" {
  name                         = "backend"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "backend"
      image  = "acrhelloapp2024.azurecr.io/backend:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "NODE_ENV"
        value = "production"
      }
      env {
        name  = "PORT"
        value = "5000"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 5000
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

resource "azurerm_container_app" "frontend" {
  name                         = "frontend"
  resource_group_name          = azurerm_resource_group.example.name
  container_app_environment_id = azurerm_container_app_environment.example.id
  revision_mode                = "Single"

  template {
    container {
      name   = "frontend"
      image  = "acrhelloapp2024.azurecr.io/frontend:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "VITE_BACKEND_URL"
        value = "http://backend:5000"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = 80
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}