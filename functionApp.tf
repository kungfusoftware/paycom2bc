

############################################################
# App Service Plan (Flex Consumption)
############################################################
resource "azurerm_service_plan" "fc" {
  name                = "${var.function_app_name}-fcplan"
  location            = var.location
  resource_group_name = module.rg.name
  os_type             = "Linux"
  sku_name            = "FC1" # Flex Consumption
  tags                = var.tags
}

############################################################
# Linux Function App (Flex, Python)
############################################################
# Create a function app
resource "azurerm_function_app_flex_consumption" "func" {
  name                = var.function_app_name
  resource_group_name = module.rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.fc.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${module.sa.resource.primary_blob_endpoint}${var.funcDeploymentContainerName}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = module.sa.resource.primary_access_key
  runtime_name                = var.runtime_name
  runtime_version             = var.runtime_version
  maximum_instance_count      = 50
  instance_memory_in_mb       = 2048

  site_config {
    cors {
      allowed_origins     = var.function_app_cors_allowed_origins
      support_credentials = var.function_app_cors_support_credentials
    }
  }

  # virtual_network_subnet_id = module.vnet.subnets["snet-func-integration"].resource_id

}

############################################################
# Private Endpoint for Function App
############################################################
resource "azurerm_private_endpoint" "func_pe" {
  name                = "pe-${var.function_app_name}"
  location            = var.location
  resource_group_name = module.rg.name
  subnet_id           = module.vnet.subnets["snet-privatelink"].resource_id

  private_service_connection {
    name                           = "${var.function_app_name}-psc"
    private_connection_resource_id = azurerm_function_app_flex_consumption.func.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  tags = var.tags
}
