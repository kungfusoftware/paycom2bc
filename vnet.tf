
locals {
  vnet_dns_servers = length(var.dns_servers) == 0 ? null : {
    dns_servers = toset(var.dns_servers)
  }
}

############################################################
# Public IP for NAT Gateway
############################################################
resource "azurerm_public_ip" "nat_pip" {
  name                = "pip-${var.nat_gateway_name}"
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

############################################################
# NAT Gateway
############################################################
resource "azurerm_nat_gateway" "nat" {
  name                = var.nat_gateway_name
  location            = module.rg.resource.location
  resource_group_name = module.rg.name
  sku_name            = "Standard"
  tags                = var.tags
}

############################################################
# NAT Gateway Public IP Association
############################################################
resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
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
# Virtual Network (AVM)
# -------------------------
module "vnet" {
  source        = "Azure/avm-res-network-virtualnetwork/azurerm"
  version       = "~> 0.10"
  parent_id     = module.rg.resource.id
  name          = var.vnet_name
  location      = module.rg.resource.location
  address_space = var.address_space
  dns_servers   = local.vnet_dns_servers
  tags          = var.tags

  # Empty subnets - will be created as separate modules below
  subnets = {}
}

############################################################
# Subnet: snet-func-integration (AVM)
############################################################
module "subnet_func_integration" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "~> 0.10"

  parent_id        = module.vnet.resource_id
  name             = "snet-func-integration"
  address_prefixes = [var.subnets["snet-func-integration"]]

  # NAT Gateway association
  nat_gateway = {
    id = azurerm_nat_gateway.nat.id
  }

  # Delegation for Container Apps environments
  delegation = [{
    name = "Microsoft.App.environments"
    service_delegation = {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }]
}

############################################################
# Subnet: snet-privatelink (AVM)
############################################################
module "subnet_privatelink" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "~> 0.10"

  parent_id        = module.vnet.resource_id
  name             = "snet-privatelink"
  address_prefixes = [var.subnets["snet-privatelink"]]

  # For Private Endpoints
  private_endpoint_network_policies = "Disabled"
}

############################################################
# Subnet: snet-app (AVM)
############################################################
module "subnet_app" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "~> 0.10"

  parent_id        = module.vnet.resource_id
  name             = "snet-app"
  address_prefixes = [var.subnets["snet-app"]]
}

#
############################################################
# Subnet: Dedicated subnet for Azure Bastion (must be named AzureBastionSubnet)
############################################################
module "azurerm_subnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"
  version = "~> 0.10"

  name             = "AzureBastionSubnet"
  parent_id        = module.vnet.resource_id
  address_prefixes = [var.bastion_subnet_cidr]
}

# Helpful outputs
output "vnet_id" { value = module.vnet.resource_id }

output "nsg_id" { value = module.nsg_app.resource_id }

output "subnets_list" {
  description = "List of subnets with name and id"
  value = [
    {
      name = "snet-func-integration"
      id   = module.subnet_func_integration.resource_id
    },
    {
      name = "snet-privatelink"
      id   = module.subnet_privatelink.resource_id
    },
    {
      name = "snet-app"
      id   = module.subnet_app.resource_id
    }
  ]
}

############################################################
# NSG Association to snet-func-integration
############################################################
resource "azurerm_subnet_network_security_group_association" "func_integration_nsg" {
  subnet_id                 = module.subnet_func_integration.resource_id
  network_security_group_id = module.nsg_app.resource_id
}
