
variable "location" {
  description = "Location that the resources should be deployed to"
  default     = "westeurope"
}

variable "project" {
  description = "Name of the project being worked on"
  default     = "fabric"
}

variable "fabric_sku" {
  description = "The SKU of the fabric capacity to be created"
  default     = "F2"
}

variable "environments" {
  description = "List of environments that need to be created"
  default     = "dev:false,uat:false,prod:true"
}

variable "env_types" {
  description = "List of environment types that need to be created"
  default     = "engineering,storage-bronze,storage-silver,storage-finance,analytics-finance"
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
# Azure Fabric Settings
#######################################################
variable "permissions" {
  description = "Comma separated list of users to be added as administrators to the fabric capacity"
  type        = string
  default     = ""
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
