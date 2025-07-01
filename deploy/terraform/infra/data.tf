
# Get details of the current subscription and tenant
data "azurerm_client_config" "current" {}

# Get data about the current subscription
# This is used to determine if there are any tags to denote if the subscription
# is a prod or nonprod sub or it should be overridden
data "azurerm_subscription" "current" {}
data "fabric_capacity" "afc" {
  count        = var.create_fabric_capacity ? 0 : 1
  display_name = local.fabric_capacity_name
}

# Get details about the ADO project, this is required so that Terraform
# can create the variable group in the correct project and an ID is required for that
data "azuredevops_project" "project" {
  count = var.create_ado_variable_group ? 1 : 0
  name  = var.ado_project_name
}
