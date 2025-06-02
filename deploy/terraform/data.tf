
# Get details of the current subscription and tenant
data "azurerm_client_config" "current" {}

# Get data about the current subscription
# This is used to determine if there are any tags to denote if the subscription
# is a prod or nonprod sub or it should be overridden
data "azurerm_subscription" "current" {}
data "fabric_capacity" "afc" {
  display_name = local.fabric_capacity_name
}
