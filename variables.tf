variable "rg_name" {
  type    = string
  default = "rg-paycom-bc-Integration-eus-staging"
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "vnet_name" {
  type = string
}
variable "kv_name" {
  type    = string
  default = "kv-paycom-bc-intgr-stg" # 3-24 chars, letters/digits/hyphens
}

variable "address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.7.200.0/24"]
}

variable "subnets" {
  description = "Map of subnet_name => CIDR"
  type        = map(string)
  default = {
    "snet-func-integration" = "10.7.200.0/26"   # for Function Apps Standard VNet integration (no NSG/UDR), IPs .0 - .63 usable .4 -.62
    "snet-privatelink"      = "10.7.200.64/26"  # for Private Endpoints,  IPs .64 - .127 usable .68 -.126
    "snet-app"              = "10.7.200.128/26" # general workloads,  IPs .128 -191 .63 usable .132 -.190
  }
}

variable "dns_servers" {
  type    = list(string)
  default = [] # e.g., ["10.0.0.4","10.0.0.5"]
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "staging"
    Owner       = "cloud-team@teamcenturion.com"
    CostCenter  = "Finance"
    Application = "PaycomEmployee-to-BC-Integration"
  }
}

variable "nsg_name" {
  type    = string
  default = "nsg-app"
}

variable "nat_gateway_name" {
  type    = string
  default = "ngw-app"
}
# Names of subnets that should have the NSG associated
variable "nsg_subnets" {
  type    = list(string)
  default = [] # e.g., ["snet-app", "snet-backend"]
}

# Keep schema flexible; start empty and add rules as needed
variable "nsg_security_rules" {
  type    = any
  default = {}
}

variable "client_id" {
  type      = string
  sensitive = true
}
variable "client_secret" {
  type      = string
  sensitive = true
}
variable "tenant_id" { type = string }
variable "subscription_id" { type = string }

variable "location_short" {
  description = "Short code for region (eus|wus|cus)"
  type        = string
  default     = "eus"
}

variable "law_name" {
  description = "Log Analytics workspace name"
  type        = string
  default     = "law-paycom2bc-staging-eus"
}
variable "law_retention_days" {
  description = "Retention in days (30–730)"
  type        = number
  default     = 30
}

#storage account
variable "storage_account_name" {
  description = "Storage account name for Function App (3-24 chars, lowercase, letters/digits)"
  type        = string
  default     = "st0paycom2bc0stg"
}


variable "account_tier" {
  description = "Defines the Tier to use for this storage account."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Type of replication to use for this storage account."
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Default access tier for blob data."
  type        = string
  default     = "Hot"
}

variable "min_tls_version" {
  description = "Minimum supported TLS version."
  type        = string
  default     = "TLS1_2"
}

variable "enable_https_traffic_only" {
  description = "Specifies whether only HTTPS traffic should be permitted to access data in the storage account."
  type        = bool
  default     = true
}

variable "allow_nested_items_to_be_public" {
  description = "Allow or disallow nested items in the storage account to be public."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable or disable public network access to the storage account."
  type        = bool
  default     = true
}

variable "storage_account_identity" {
  description = "Optional managed identity configuration for the storage account."
  type        = any
  default     = null
}

variable "blob_properties" {
  description = "Optional blob service properties applied to the storage account."
  type        = any
  default     = null
}

variable "container_name" {
  description = "Name of the blob container to create."
  type        = string
}

variable "container_public_access" {
  description = "Specifies the level of public access to the blob container."
  type        = string
  default     = "None"
}

variable "container_metadata" {
  description = "Metadata key/value pairs to assign to the container."
  type        = map(string)
  default     = {}
}

variable "container_immutability_policy" {
  description = "Optional immutability policy configuration for the blob container."
  type        = any
  default     = null
}

variable "function_app_name" {
  description = "Name of the Azure Function App."
  type        = string
  default     = "func-paycom2bc-prd"
}

variable "function_app_plan_name" {
  description = "Name of the Function App flexible consumption plan."
  type        = string
  default     = "plan-func-paycom2bc-prd"
}

variable "function_app_storage_account_name" {
  description = "Existing storage account to associate with the Function App."
  type        = string
  default     = "st0func0paycomm2bc0prd"
}

variable "function_app_worker_runtime" {
  description = "Language worker runtime for the Function App."
  type        = string
  default     = "dotnet-isolated"
}

variable "function_app_flex_consumption_workers" {
  description = "Number of pre-warmed workers for the flexible consumption plan."
  type        = number
  default     = 1
}

variable "function_app_additional_app_settings" {
  description = "Additional application settings to merge into the Function App configuration."
  type        = map(string)
  default     = {}
}
variable "runtime_name" {
  description = "The name of the language worker runtime."
  type        = string
  default     = "node" # Allowed: dotnet-isolated, java, node, powershell, python
}

variable "runtime_version" {
  description = "The version of the language worker runtime."
  type        = string
  default     = "20" # Supported versions: see https://aka.ms/flexfxversions
}

variable "funcDeploymentContainerName" {
  description = "the name of the function app deployment container"
  type        = string
  default     = "deploymentpackage"
}
