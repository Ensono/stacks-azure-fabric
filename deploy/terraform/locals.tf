locals {

  # Determine if this is a production subscription or the override is being used
  is_prod_subscription = contains(["prod"], data.azurerm_subscription.current.tags) || var.is_prod_subscription
  deploy_all_envs      = contains(["override"], data.azurerm_subscription.current.tags) || var.deploy_all_environments

  # Obtain a list of environments from the variables
  # This is a comma separated list which also has a flag to state if it is for the production subscription or not
  environments_all = { for env_definition in split(",", var.environments) :
    "${split(":", env_definition)[0]}" =>
    {
      is_prod = "${split(":", env_definition)[1]}" == "true" ? true : false
    }
  }

  # Create a list of the envs to deploy
  # This list determines if the environment is for a production subscription or not
  # and returns the appropriate list
  #
  # For example, if the variable `is_prod_subscription` is set to false
  #
  # ["dev", "uat"]
  #
  #
  environments = flatten([for name, detail in local.environments_all : [
    name
  ] if detail.is_prod == var.is_prod_subscription || var.deploy_all_environments])

  # Create an object of the environments and the types of workspaces and lakehouses that
  # are required
  #
  # For example, for environments "dev" and "uat" with the default ws_types, the output
  # would be:
  # {
  #   "dev" = [
  #     "engineering",
  #     "storage-bronze",
  #     "storage-silver",
  #     "storage-finance",
  #     "analytics-finance",
  #   ]
  #   "uat" = [
  #     "engineering",
  #     "storage-bronze",
  #     "storage-silver",
  #     "storage-finance",
  #     "analytics-finance",
  #   ]
  # }
  environment_workspaces = {
    for name in local.environments : name => [
      for type in split(",", var.ws_types) : type
    ]
  }


  # Create a list of the workspaces and lakehouses to be created
  # This so that the resources can just iterate over the list
  # It is made up of the environment name and the envtypes and will produce a list like:
  # [
  #   "dev-engineering",
  #   "dev-storage-bronze",
  #   "dev-storage-silver",
  #   "dev-storage-finance",
  #   "dev-analytics-finance",
  #   "uat-engineering",
  #   "uat-storage-bronze",
  #   "uat-storage-silver",
  #   "uat-storage-finance",
  #   "uat-analytics-finance",
  # ]
  workspaces = flatten([
    for env, types in local.environment_workspaces : [
      for type in types : "${env}-${type}"
    ]
  ])

  # For each of the environments, the IDs of the lakehouse and the workspaces is required
  # These will be added to the outputs for that environment, but the information needs
  # to be collected
  fabric_resources = {
    for envname, detail in local.environment_workspaces : envname => {
      workspaces = { for ws in detail : "${ws}_workspace_id" => fabric_workspace.ws["${envname}-${ws}"].id }
      lakehouses = { for lh in detail : "${lh}_lakehouse_id" => fabric_lakehouse.afl["${envname}-${lh}"].id }
    }
  }

  resource_outputs = { for envname in local.environments : envname => {
    resource_group_name   = azurerm_resource_group.rg.name
    fabric_capacity_name  = local.fabric_capacity_name
    capacity_admins       = local.admin_members
    key_vault_name        = module.key-vault.name
    key_vault_resource_id = module.key-vault.resource_id
    }
  }

  outputs = { for envname in local.environments : envname => merge(local.resource_outputs[envname], local.fabric_resources[envname].lakehouses, local.fabric_resources[envname].workspaces) }

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

  # Get the name of the capacity, this is either generated or has been passed in
  fabric_capacity_name = var.create_fabric_capacity ? azurerm_fabric_capacity.afc[0].name : var.fabric_capacity_name

  # Determine the short name of the company
  company_short_name = lower(substr(var.company_name, 0, 3))
}
