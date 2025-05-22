variable "processing_workspace_id" {
  type        = string
  default     = ""
  description = "The processing workspace ID for the data pipeline."
}

variable "bronze_storage_workspace_id" {
  type        = string
  default     = ""
  description = "The bronze storage workspace ID"
}

variable "bronze_storage_artifact_id" {
  type        = string
  default     = ""
  description = "The bronze storage artifact ID"
}

variable "silver_storage_workspace_id" {
  type        = string
  default     = ""
  description = "The silver storage workspace ID"
}

variable "silver_storage_artifact_id" {
  type = string
  default = ""
  description = "The silver storage artifact id"
}

variable "data_pipeline_objectid" {
  type        = string
  default     = ""
  description = "The data pipeline objectid"
}

