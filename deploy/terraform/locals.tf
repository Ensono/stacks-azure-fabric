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
    resource_group_name  = azurerm_resource_group.rg.name
    fabric_capacity_name = azurerm_fabric_capacity.afc.name
    workspaces           = flatten([for ws in fabric_workspace.ws : [ws.id]])
    lakehouses           = flatten([for lh in fabric_lakehouse.afl : [lh.id]])
  }
}
