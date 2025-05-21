
resource "fabric_workspace_role_assignment" "ws_ra" {

  # Configure the access for each of the workspaces
  # for_each = toset(local.workspaces)
  for_each = { for role in local.workspace_roles : role.wsname => role }

  # workspace_id = fabric_workspace.ws[each.key].id
  workspace_id = fabric_workspace.ws[each.key].id

  principal = {
    # id   = "b1db9c19-4aad-4cec-8c56-d3d2bb682e5c"
    # type = "User"
    id   = each.value.id
    type = each.value.type
  }

  # role = "Contributor"
  role = each.value.role
}
