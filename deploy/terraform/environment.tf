resource "fabric_environment" "ws_envs" {
  # create a workspace for each of the environments and types, excluding storage workspaces
  for_each = toset([
    for ws in local.workspaces : ws
    if !contains(split("-", ws), "storage")
  ])

  display_name = "${module.naming.extended_names[var.project].fabric_environment.name}-${each.key}"

  workspace_id = fabric_workspace.ws[each.key].id
}

resource "fabric_spark_environment_settings" "env_spark_settings" {
  # create Spark environment settings for each environment
  for_each = toset([
    for ws in local.workspaces : ws
    if !contains(split("-", ws), "storage")
  ])

  environment_id     = fabric_environment.ws_envs[each.key].id
  workspace_id       = fabric_workspace.ws[each.key].id
  publication_status = "Published"
  runtime_version    = "1.3"

  depends_on = [fabric_environment.ws_envs]
}

resource "fabric_spark_workspace_settings" "env_spark_workspace_settings" {
  # create Spark workspace settings for each environment
  for_each = toset([
    for ws in local.workspaces : ws
    if !contains(split("-", ws), "storage")
  ])
  workspace_id = fabric_workspace.ws[each.key].id

  environment = {
    name = fabric_environment.ws_envs[each.key].display_name
  }
}
