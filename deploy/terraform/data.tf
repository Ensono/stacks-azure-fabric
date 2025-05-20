
# Get details of the current subscription and tenant
data "azurerm_client_config" "current" {}

# Get data about the current subscription
# This is used to determine if there are any tags to denote if the subscription
# is a prod or nonprod sub or it should be overridden
data "azurerm_subscription" "current" {}

# Retrieve the details of the fabric capacity so the id can be used when
# creating a fabric workspace
data "fabric_capacity" "afc" {
  display_name = azurerm_fabric_capacity.afc.name
}

# data "azapi_resource" "afc" {
#   type      = "Microsoft.Fabric/capacities@2023-11-01"
#   name      = module.naming.extended_names[var.project].fabric_capacity.name
#   parent_id = azurerm_resource_group.rg.id
# }
