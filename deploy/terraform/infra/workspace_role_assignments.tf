
resource "fabric_workspace_role_assignment" "ws_ra" {

  # Configure the access for each of the workspaces
  for_each = { for index, role in local.workspace_roles : index => role }

  # workspace_id = fabric_workspace.ws[each.key].id
  workspace_id = fabric_workspace.ws[each.value.wsname].id

  principal = {
    id   = each.value.id
    type = each.value.type
  }

  # role = "Contributor"
  role = each.value.role
}
