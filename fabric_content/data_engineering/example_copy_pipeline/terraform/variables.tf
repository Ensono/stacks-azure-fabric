variable "engineering_workspace_id" {
  type        = string
  default     = ""
  description = "The engineering workspace ID for the data pipeline."
}

variable "bronze_workspace_id" {
  type        = string
  default     = ""
  description = "The bronze workspace ID"
}

variable "bronze_lakehouse_id" {
  type        = string
  default     = ""
  description = "The bronze lakehouse Id"
}

variable "silver_workspace_id" {
  type        = string
  default     = ""
  description = "The silver workspace ID"
}

variable "silver_lakehouse_id" {
  type        = string
  default     = ""
  description = "The silver lakehouse id"
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
