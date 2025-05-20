
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
