
resource "azurerm_fabric_capacity" "afc" {
  name                = module.naming.extended_names[var.project].fabric_capacity.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = var.fabric_sku
    tier = "Fabric"
  }

  administration_members = [data.azurerm_client_config.current.object_id]
}

# Use the azapi resource to get the details about the fabric capacity
# resource "azapi_resource" "afc" {
#   type      = "Microsoft.Fabric/capacities@2925-01-15-preview"
#   name      = module.naming.extended_names[var.project].fabric_capacity.name
#   location  = azurerm_resource_group.rg.location
#   parent_id = azurerm_resource_group.rg.id

#   body = {
#     properties = {
#       administration = {
#         members = [data.azurerm_client_config.current.object_id]
#       }
#       sku = {
#         name = var.fabric_sku
#         tier = "Fabric"
#       }
#     }
#   }
# }
