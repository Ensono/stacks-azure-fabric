variable "processing_workspace_id" {
   type        = string
   default     = ""
   description = "The processing workspace ID."
 }

 variable "processing_lakehouse_id" {
   type        = string
   default     = ""
   description = "The processing lakehouse ID."
 }

 variable "silver_workspace_id" {
   type        = string
   default     = ""
   description = "The silver workspace ID."
 }

 variable "silver_lakehouse_id" {
   type = string
   default = ""
   description = "The silver lakehouse ID."
 }

 variable "gold_workspace_id" {
   type        = string
   default     = ""
   description = "The gold workspace ID."
 }

 variable "gold_lakehouse_id" {
   type = string
   default = ""
   description = "The gold lakehouse ID."
 }
