
resource "fabric_lakehouse" "afl" {

  # create a lake house for each of the environments and types
  for_each = var.create_lakehouses ? toset(local.workspaces) : toset([])

  display_name = "${module.naming.extended_names[var.project].fabric_lakehouse.name}${replace(each.key, "-", "")}"

  workspace_id = fabric_workspace.ws[each.key].id
}
