
resource "azurerm_fabric_capacity" "afc" {
  count               = var.create_fabric_capacity ? 1 : 0
  name                = module.naming.extended_names[var.project].fabric_capacity.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = var.fabric_sku
    tier = "Fabric"
  }

  administration_members = toset(local.admin_members)
}
