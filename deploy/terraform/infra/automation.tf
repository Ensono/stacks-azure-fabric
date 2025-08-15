# This file contains the resources that are required to deploy azure automation to
# ensure that the Fabric capacity is suspended when not in use

# Get the current time using the Hashicorp provider
# This is so that the schedules can be set to start from a time that is
# set in the state and does not change on every apply
resource "time_static" "current_time" {}

# Create a user identity that the automation will use
resource "azurerm_user_assigned_identity" "automation" {
  count = var.enable_suspend ? 1 : 0

  name                = module.naming.names[var.project].user_assigned_identity.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a custom role that allows the uai to suspend and resume the fabric capacity
# resource "azurerm_role_definition" "fabric_suspend_resume" {
#   count = var.enable_suspend ? 1 : 0

#   name        = "Fabric Capacity Suspend and Resume Operator"
#   scope       = data.azurerm_subscription.current.id
#   description = "Custom tole with permissions to suspend and resume the Fabric Capacity"

#   permissions {
#     actions = [
#       "Microsoft.Fabric/capacities/read",
#       "Microsoft.Fabric/capacities/suspend/action",
#       "Microsoft.Fabric/capacities/resume/action",
#     ]
#     not_actions = []
#   }

#   assignable_scopes = [
#     azurerm_fabric_capacity.afc[0].id
#   ]
# }

# Assign this role to the user
resource "azurerm_role_assignment" "fabric_role_assignment" {
  count = var.enable_suspend ? 1 : 0

  scope = azurerm_fabric_capacity.afc[0].id
  # role_definition_id = azurerm_role_definition.fabric_suspend_resume[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.automation[0].principal_id
}


# Create the automation account
resource "azurerm_automation_account" "fabric" {
  count = var.enable_suspend ? 1 : 0

  name                = module.naming.names[var.project].automation_account.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = var.automation_sku

  # Ensure the account runs as the user assigned identity
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.automation[0].id
    ]
  }
}

# Set the identity of the User Assigned Identity as an automation variable
resource "azurerm_automation_variable_string" "uai_identity" {
  count = var.enable_suspend ? 1 : 0

  name                    = "UserAssignedIdentity"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name
  value                   = azurerm_user_assigned_identity.automation[0].client_id
}

# Create the runbooks for suspend and resume
resource "azurerm_automation_runbook" "suspend" {
  count = var.enable_suspend ? 1 : 0

  name                    = "SuspendFabricCapacity"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell72"

  content = file("../../../build/scripts/Set-FabricState.ps1")

}

resource "azurerm_automation_runbook" "resume" {
  count = var.enable_suspend ? 1 : 0

  name                    = "ResumeFabricCapacity"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell72"

  content = file("../../../build/scripts/Set-FabricState.ps1")
}

# Create the schedule for the runbooks
resource "azurerm_automation_schedule" "suspend" {
  count = var.enable_suspend ? 1 : 0

  name                    = "PauseSchedule"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name

  frequency = "Week"
  week_days = local.suspend_schedule_details.days
  interval  = 1

  timezone = var.automation_timezone

  # Set the start time based on the current time and the time offset specified
  start_time = local.suspend_schedule_details.time

}

resource "azurerm_automation_schedule" "resume" {
  count = var.enable_suspend ? 1 : 0

  name                    = "ResumeSchedule"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name

  frequency = "Week"
  week_days = local.resume_schedule_details.days
  interval  = 1

  timezone = var.automation_timezone

  # Set the start time based on the current time and the time offset specified
  start_time = local.resume_schedule_details.time

}

# Now set the job by linking everything together
resource "azurerm_automation_job_schedule" "suspend" {
  count = var.enable_suspend ? 1 : 0

  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name
  runbook_name            = azurerm_automation_runbook.suspend[0].name
  schedule_name           = azurerm_automation_schedule.suspend[0].name

  # set the parameters for the runbook
  parameters = {
    subscriptionid    = data.azurerm_subscription.current.subscription_id
    resourcegroupname = azurerm_resource_group.rg.name
    capacityname      = azurerm_fabric_capacity.afc[0].name
    identity          = "true"
    suspend           = "true"
  }
}

resource "azurerm_automation_job_schedule" "resume" {
  count = var.enable_suspend ? 1 : 0

  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.fabric[0].name
  runbook_name            = azurerm_automation_runbook.resume[0].name
  schedule_name           = azurerm_automation_schedule.resume[0].name

  # set the parameters for the runbook
  parameters = {
    subscriptionid    = data.azurerm_subscription.current.subscription_id
    resourcegroupname = azurerm_resource_group.rg.name
    capacityname      = azurerm_fabric_capacity.afc[0].name
    identity          = "true"
    resume            = "true"
  }
}
