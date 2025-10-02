locals {
  function_app_name              = var.function_app_name
  function_app_plan_name         = var.function_app_plan_name
  function_app_flex_workers      = var.function_app_flex_consumption_workers
  function_app_worker_runtime    = var.function_app_worker_runtime
  function_app_additional_config = var.function_app_additional_app_settings
}

data "azurerm_storage_account" "function" {
  name                = var.function_app_storage_account_name
  resource_group_name = module.rg.name
}

resource "azurerm_service_plan" "function_flex" {
  name                = local.function_app_plan_name
  resource_group_name = module.rg.name
  location            = module.rg.resource.location
  os_type             = "Linux"
  sku_name            = "FC1"
  tags                = var.tags
}

resource "azurerm_linux_function_app" "function" {
  name                       = local.function_app_name
  location                   = module.rg.resource.location
  resource_group_name        = module.rg.name
  service_plan_id            = azurerm_service_plan.function_flex.id
  storage_account_name       = data.azurerm_storage_account.function.name
  storage_account_access_key = data.azurerm_storage_account.function.primary_access_key
  https_only                 = true
  virtual_network_subnet_id  = module.vnet.subnets["snet-func-integration"].resource_id
  functions_extension_version = "~4"
  flex_consumption_worker_count = local.function_app_flex_workers

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      use_dotnet_isolated = true
    }
  }

  app_settings = merge({
    FUNCTIONS_WORKER_RUNTIME = local.function_app_worker_runtime
    AzureWebJobsStorage      = data.azurerm_storage_account.function.primary_connection_string
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }, local.function_app_additional_config)

  tags = var.tags
}

output "function_app_id" {
  description = "Resource ID of the Azure Function App."
  value       = azurerm_linux_function_app.function.id
}

output "function_app_hostname" {
  description = "Default hostname of the Azure Function App."
  value       = azurerm_linux_function_app.function.default_hostname
}
