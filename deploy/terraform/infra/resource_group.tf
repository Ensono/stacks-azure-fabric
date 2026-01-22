
# Create the resource group based on the naming convention
resource "azurerm_resource_group" "rg" {
  name     = module.naming.names[var.project].resource_group.name
  location = var.location

  tags = local.common_tags
}
