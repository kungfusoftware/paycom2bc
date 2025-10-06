

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
  }
}
