variable "processing_workspace_id" {
  type        = string
  default     = "8794a888-b6c6-4fe5-8f69-6eb0467f5246"
  description = "The processing workspace ID for the data pipeline."
}

variable "bronze_storage_workspace_id" {
  type        = string
  default     = "168a5923-e2bc-4ba8-a291-e9b77b93598c"
  description = "The bronze workspace ID"
}

variable "silver_storage_workspace_id" {
  type        = string
  default     = "168a5923-e2bc-4ba8-a291-e9b77b93598c"
  description = "The bronze workspace ID"
}