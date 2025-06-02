locals {

  # Obtain a list of environments from the variables
  # This is a comma separated list which also has a flag to state if it is for the production subscription or not
  environments_all = { for env_definition in split(",", var.environments) :
    "${split(":", env_definition)[0]}" =>
    {
      is_prod = "${split(":", env_definition)[1]}" == "true" ? true : false
    }
  }

  # Determine if this is a production subscription or the override is being used
  is_prod_subscription = contains(["prod"], data.azurerm_subscription.current.tags) || var.is_prod_subscription
  deploy_all_envs      = contains(["override"], data.azurerm_subscription.current.tags) || var.deploy_all_environments

  # Create a list of the fabric workspaces that need to be created
  # This is based on the environments that are passed in and the types of workspace that are required
  workspaces = flatten([
    for name, detail in local.environments_all : [
      for type in split(",", var.env_types) : [
        "${name}-${type}"
      ]
    ] if detail.is_prod == local.is_prod_subscription || local.deploy_all_envs
  ])

  outputs = {
    resource_group_name   = azurerm_resource_group.rg.name
    fabric_capacity_name  = local.fabric_capacity_name
    workspaces            = flatten([for ws in fabric_workspace.ws : [ws.id]])
    lakehouses            = flatten([for lh in fabric_lakehouse.afl : [lh.id]])
    capacity_admins       = local.admin_members
    key_vault_name        = module.key-vault.name
    key_vault_resource_id = module.key-vault.resource_id

  }

  # Create an object that contains all of the required permissions that have been defined
  perms = flatten([
    for permission in split(",", var.permissions) : [
      for detail in split(":", permission) : {
        fabric_admin = split(":", permission)[1] == "true" ? (split(":", permission)[0] == "" ? split(":", permission)[2] : split(":", permission)[0]) : ""
        workspace = {
          id   = split(":", permission)[2]
          role = split(":", permission)[3]
          type = split(":", permission)[0] == "" ? "ServicePrincipal" : "User"
        }
      }
    ]
  ])

  # Create the list of admin_members from the perms object and ensure that the current SP has
  # is assigned as an admin of the fabric capacity
  admin_members = distinct(concat(flatten([
    for permission in local.perms : [
      for detail in permission : [
        permission.fabric_admin
      ]
    ]
  ]), [data.azurerm_client_config.current.object_id]))

  # Create an object that combines the local workspaces and the workspace permissions to that
  # a workspace_roles object can be created
  workspace_roles = distinct(flatten([
    for ws in local.workspaces : [
      for permission in local.perms : {
        wsname = ws
        id     = permission.workspace.id
        role   = permission.workspace.role
        type   = permission.workspace.type
      } if permission.workspace.role != "" && lower(permission.workspace.role) != "none"
    ]
  ]))

  fabric_capacity_name = var.create_fabric_capacity ? azurerm_fabric_capacity.afc[0].name : var.fabric_capacity_name
}
