resource "fabric_environment" "ws_envs" {
  # create a workspace for each of the environments and types, excluding storage workspaces
  for_each = toset([
    for ws in local.workspaces : ws
    if !contains(split("-", ws)[1], "storage")
  ])

  display_name = "${module.naming.extended_names[var.project].fabric_workspace.name}-${each.key}"

  workspace_id = fabric_workspace.ws[each.key].id
}

resource "fabric_spark_environment_settings" "env_spark_settings" {
  # create Spark environment settings for each environment
  for_each = toset([
    for ws in local.workspaces : ws
    if !contains(split("-", ws)[1], "storage")
  ])

  environment_id     = fabric_environment.ws_envs[each.key].id
  workspace_id       = fabric_workspace.ws[each.key].id
  publication_status = "Published"
  runtime_version    = "1.3"

  depends_on = [fabric_environment.ws_envs]
}
