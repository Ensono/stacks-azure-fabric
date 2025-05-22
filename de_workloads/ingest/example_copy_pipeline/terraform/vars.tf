variable "processing_workspace_id" {
  type        = string
  default     = "8794a888-b6c6-4fe5-8f69-6eb0467f5246"
  description = "The processing workspace ID for the data pipeline."
}

variable "bronze_workspace_id" {
  type        = string
  default     = "168a5923-e2bc-4ba8-a291-e9b77b93598c"
  description = "The bronze workspace ID"
}

variable "bronze_lakehouse_id" {
  type        = string
  default     = "598c73d0-3dc4-4832-8391-be168728c63f"
  description = "The bronze lakehouse Id"
}

variable "silver_workspace_id" {
  type        = string
  default     = "168a5923-e2bc-4ba8-a291-e9b77b93598c"
  description = "The silver workspace ID"
}

variable "silver_lakehouse_id" {
  type = string
  default = "08d36aeb-0278-4700-b2fa-dbaac339793c"
  description = "The silver lakehouse id"
}

