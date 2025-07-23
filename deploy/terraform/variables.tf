variable "company_name" {
  description = "The name of the company, used for naming resources"
  type        = string
  default     = "ensono"
}

variable "location" {
  description = "Location that the resources should be deployed to"
  default     = "westeurope"
}

variable "project" {
  description = "Name of the project being worked on"
  default     = "fabric"
}


variable "create_fabric_capacity" {
  description = "Whether to create the Azure Fabric Capacity resource"
  type        = bool
  default     = false
}

variable "fabric_capacity_name" {
  description = "Name of the existing Fabric Capacity to look up"
  type        = string
  default     = null
}

variable "fabric_sku" {
  description = "The SKU of the fabric capacity to be created"
  default     = "F2"
}

variable "environments" {
  description = "List of environments that need to be created"
  default     = "test:false,uat:false,prod:true"
}

variable "ws_types" {
  description = "List of environment types that need to be created"
  default     = "engineering,storage-bronze,storage-silver,storage-goldexample,analytics-example"
}

variable "is_prod_subscription" {
  type        = bool
  default     = false
  description = "Flag to state if the subscription being deployed to is the production subscription or not. This so that the environments are created properly."
}

variable "deploy_all_environments" {
  type        = bool
  default     = false
  description = "If true, all environments will be deployed regardless of subscription type, e.g. nonprod or prod"
}

#######################################################
# Azure DevOps Settings
#######################################################

variable "ado_org_service_url" {
  description = "The URL of the Azure DevOps organization service"
  type        = string
}

variable "ado_project_name" {
  description = "The name of the Azure DevOps project"
  type        = string
}

variable "create_ado_variable_group" {
  description = "Flag to indicate if a variable group should be created in Azure DevOps"
  type        = bool
  default     = true
}


#######################################################
# Azure Fabric Settings
#######################################################
variable "permissions" {
  description = "Comma separated list of users to be added as administrators to the fabric capacity"
  type        = string
  default     = ""
}

variable "enable_suspend" {
  description = "Flag to indicate if the suspend functionality should be enabled for the Fabric capacity"
  type        = bool
  default     = true
}

#######################################################
# Azure Automation Settings
#######################################################

variable "automation_sku" {
  description = "The SKU of the Azure Automation account. Possible values are 'Basic' or 'Free'."
  type        = string
  default     = "Basic"
}

variable "automation_suspend_schedule" {
  description = "The schedule for suspending the Fabric capacity. This is in the format of <TIME>:<DAYS_OF_WEEK>"
  type        = string
  default     = "17:00;Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday"
}

variable "automation_resume_schedule" {
  description = "The schedule for resuming the Fabric capacity. This is in the format of <TIME>:<DAYS_OF_WEEK>"
  type        = string
  default     = "07:00;Monday,Tuesday,Wednesday,Thursday,Friday"
}

variable "automation_timezone" {
  description = "The timezone to use for the automation schedules. This is in the format of 'Europe/London'."
  type        = string
  default     = "Europe/London"
}

#######################################################
# Key Vault Settings
#######################################################

variable "key_vault_sku" {
  description = "The SKU of the Key Vault. Possible values are 'standard' or 'premium'."
  type        = string
  default     = "standard"
}

variable "key_vault_public_network_enabled" {
  description = "The SKU of the Key Vault. Possible values are 'standard' or 'premium'."
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "Retention days for soft delete."
  type        = number
  default     = 7
}

variable "key_vault_enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "key_vault_purge_protection_enabled" {
  description = "Boolean flag to specify whether purge protection is enabled for the key vault."
  type        = bool
  default     = true
}

#######################################################
# Local development settings
#######################################################

variable "create_env_files" {
  description = "Flag to indicate if environment files should be created for local development"
  type        = bool
  default     = false
}
