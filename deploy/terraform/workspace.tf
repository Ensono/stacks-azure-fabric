
resource "fabric_workspace" "ws" {

  # create a workspace for each of the environments and types
  for_each = toset(local.workspaces)

  display_name = "${module.naming.extended_names[var.project].fabric_workspace.name}-${each.key}"
  capacity_id  = data.fabric_capacity.afc.id

  identity = {
    type = "SystemAssigned"
  }
}
