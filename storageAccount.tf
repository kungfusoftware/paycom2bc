# -----------------------------
# Storage account for Functions
# -----------------------------

module "sa" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.2" # pin as you prefer

  # Core
  name                = var.storage_account_name
  location            = var.location
  resource_group_name = module.rg.name

  # SKU / replication / tier
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Security / network / encryption
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  public_network_access_enabled     = true
  network_rules                     = null # or { default_action = "Allow" }
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = false
  default_to_oauth_authentication   = true
  shared_access_key_enabled         = true
  allow_nested_items_to_be_public   = true
  allowed_copy_scope                = "PrivateLink"
  is_hns_enabled                    = false
  large_file_share_enabled          = true
  #local_user_enabled                 = true
  sftp_enabled  = false
  nfsv3_enabled = false

  # Blob service properties
  blob_properties = {
    change_feed_enabled = false
    # change_feed_retention_in_days   = 7
    default_service_version  = null
    last_access_time_enabled = false
    versioning_enabled       = false
    container_delete_retention_policy = {
      days = 7
    }
    delete_retention_policy = {
      days                     = 7
      permanent_delete_enabled = false
    }
  }



  # File share service properties
  share_properties = {
    retention_policy = {
      days = 7
    }
  }

  # Create the container used by Flex Consumption deployments
  containers = {
    deploymentpackage = {
      name          = var.funcDeploymentContainerName
      public_access = "None"
    }
  }

  # Tags
  tags = var.tags
}


module "pe_sa_blob" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "~> 0.2"

  name                   = "pe-${var.storage_account_name}--blob"
  location               = var.location
  resource_group_name    = var.rg_name
  network_interface_name = "pe-${var.storage_account_name}-blob-nic"
  # Use the module output and the correct input name
  subnet_resource_id             = module.vnet.subnets["snet-privatelink"].resource_id
  private_connection_resource_id = module.sa.resource_id

  # Blob subresource (add "dfs" too if you enabled HNS/ADLS)
  subresource_names = ["blob"]

  # DNS group params
  private_dns_zone_group_name = "blob-dns"

  tags = var.tags
}


# module "blob_container" {
#   source  = "Azure/avm-res-storage-blobcontainer/azurerm"
#   version ">=0.2.0"

#   name               = var.container_name
#   storage_account_id = module.storage_account.resource_id
#   metadata           = var.container_metadata
#   public_access      = var.container_public_access
#   immutability_policy = var.container_immutability_policy
# }
# resource "azurerm_storage_container" "func_storage" {
#   name               = var.container_name
#   storage_account_id = module.sa_paycom2BCIntegration.resource_id  # or module.sa.resource_id
#   container_access_type = "private"
# }
# # Queue
# resource "azurerm_storage_queue" "jobs" {
#   name               = "jobs"
#   storage_account_id = module.sa_paycom2BCIntegration.resource_id    # or module.sa.resource_id
# }

# output "storage_account_id" {
#   description = "Resource ID of the storage account."
#   value       = module.sa_paycom2BCIntegration.resource_id
# }

# output "storage_account_name" {
#   description = "Name of the created storage account."
#   value       = module.sa_paycom2BCIntegration.name
# }
