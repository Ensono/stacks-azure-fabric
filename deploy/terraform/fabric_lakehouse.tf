
resource "fabric_lakehouse" "afl" {

  # create a lake house for each of the environments and types
  for_each = toset(local.workspaces)

  display_name = "${module.naming.extended_names[var.project].fabric_lakehouse.name}-${each.key}"

  workspace_id = fabric_workspace.ws[each.key].id
}
