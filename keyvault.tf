data "azurerm_client_config" "current" {}

# --- Private DNS zone for Key Vault Private Link (optional: reuse an existing one instead) ---
resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.rg.name
  tags                = var.tags
}

# Link your VNet so kv FQDN resolves to the PE IP inside the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = "pdnslink-kv"
  resource_group_name   = azurerm_private_dns_zone.kv.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = module.vnet.resource_id # from your earlier VNet resource
  registration_enabled  = false
}

# --- Key Vault (AVM) ---
module "kv" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10.0"

  name                = var.kv_name
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Security hardening
  sku_name                      = "standard"
  public_network_access_enabled = false # no public access
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  network_acls                  = {} # keep firewall 'Deny' (use PE/DNS to reach it)


  # Private Endpoint inside your Private Link subnet
  private_endpoints = {
    kv = {
      subnet_resource_id            = module.vnet.subnets["snet-privatelink"].resource_id
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.kv.id]
      # optional: name, ip_configurations, tags, lock, role_assignments...
    }
  }
}

output "key_vault_id" { value = module.kv.resource_id }
output "key_vault_name" { value = module.kv.name }
