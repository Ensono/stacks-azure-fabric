
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "computed_outputs" {
  value = module.naming.computed_outputs
}

output "extended_names" {
  value = module.naming.extended_names
}

output "encoded_outputs" {
  value = module.naming.encoded_outputs
}

output "workspaces" {
  value = local.workspaces
}

output "environments" {
  value = local.environments_all
}

output "admin_members" {
  value = local.admin_members
}

output "workspace_roles" {
  value = local.workspace_roles
}

output "fabric_capacity" {
  value = var.create_fabric_capacity ? azurerm_fabric_capacity.afc[0] : data.fabric_capacity.afc[0]
}
