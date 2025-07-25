variable "engineering_workspace_id" {
  type        = string
  default     = ""
  description = "The engineering workspace ID."
}

variable "engineering_lakehouse_id" {
  type        = string
  default     = ""
  description = "The engineering lakehouse ID."
}

variable "engineering_environment_id" {
  type        = string
  default     = ""
  description = "The engineering Fabric environment ID."
}

variable "silver_workspace_id" {
  type        = string
  default     = ""
  description = "The silver workspace ID."
}

variable "silver_lakehouse_id" {
  type        = string
  default     = ""
  description = "The silver lakehouse ID."
}

variable "gold_workspace_id" {
  type        = string
  default     = ""
  description = "The gold workspace ID."
}

variable "gold_lakehouse_id" {
  type        = string
  default     = ""
  description = "The gold lakehouse ID."
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., test, uat, prod)."
}

variable "data_team_email" {
  type        = string
  description = "List of Email Addresses to send Data Alerts to."
  default     = "example@example.com; example2@example.com"
}
