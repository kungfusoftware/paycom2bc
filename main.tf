
module "rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2.0"

  name     = var.rg_name
  location = var.location
  tags     = var.tags

  # Optional extras:
  # enable_telemetry = false
  # lock = { kind = "CanNotDelete" }
  # role_assignments = {
  #   reader = {
  #     role_definition_id_or_name = "Reader"
  #     principal_id               = "00000000-0000-0000-0000-000000000000"
  #   }
  # }
}

output "rg_id"   { value = module.rg.resource_id }
output "rg_name" { value = module.rg.name }

