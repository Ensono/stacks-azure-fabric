
resource "fabric_workspace" "ws" {

  # create a workspace for each of the environments and types
  for_each = toset(local.workspaces)

  display_name = "${module.naming.extended_names[var.project].fabric_workspace.name}-${each.key}"
  capacity_id  = var.create_fabric_capacity ? azurerm_fabric_capacity.afc[0].id : data.fabric_capacity.afc[0].id

  identity = {
    type = "SystemAssigned"
  }
}
