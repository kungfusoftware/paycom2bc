
locals {
  vnet_dns_servers = length(var.dns_servers) == 0 ? null : {
    dns_servers = toset(var.dns_servers)
  }
}


module "nsg_app" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.4"

  name                = var.nsg_name
  resource_group_name = module.rg.name
  location            = module.rg.resource.location
  tags                = var.tags

  # Optional: define rules (leave empty {} to start)
  security_rules = var.nsg_security_rules
}

# -------------------------
# Virtual Network + Subnets (AVM)
# -------------------------
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.10"
  parent_id = module.rg.resource.id 
  name                = var.vnet_name
 # resource_group_name = module.rg.name
  location            = module.rg.resource.location
  address_space       = var.address_space
  dns_servers         = local.vnet_dns_servers
  tags                = var.tags

  # Translate var.subnets = { snet1 = "10.0.1.0/24", snet2 = "10.0.2.0/24", ... }
  subnets = {
    for name, prefix in var.subnets : name => {
      name             = name
      address_prefixes = [prefix]

      # If this subnet will host Private Endpoints, uncomment:
      # private_endpoint_network_policies = "Disabled"
      #
      # If this is a Logic Apps Standard VNet Integration subnet,
      # keep it dedicated (no NSG/UDR).
    }
  }
}

# Helpful outputs
output "vnet_id"    { value = module.vnet.resource_id }

output "nsg_id"      { value = module.nsg_app.resource_id }
locals {
  subnet_names_sorted = sort(keys(module.vnet.subnets))
}

output "subnets_list" {
  description = "List of subnets with name and id"
  value = [
    for name in local.subnet_names_sorted : {
      name = name
      id   = try(module.vnet.subnets[name].resource_id, module.vnet.subnets[name].id)
    }
  ]
}