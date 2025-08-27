  resource "azurerm_container_app" "main" {
  name                         = var.app_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  template {
    container {
      name   = var.app_name
      image  = "acrhelloapp2024.azurecr.io/${var.app_name}:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      dynamic "env" {
        for_each = var.envs
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  ingress {
    external_enabled = false
    target_port      = var.target_port
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}