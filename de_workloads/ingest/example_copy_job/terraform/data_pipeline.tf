resource "fabric_data_pipeline" "example_ingest_pipeline" {
  display_name = "example_ingest_pipeline"
  description  = "Example data pipeline with a copy activity"
  workspace_id = var.processing_workspace_id
  format       = "Default"
  definition = {
    "pipeline-content.json" = {
      source = "${path.module}/pipeline_content.json.tmpl",
      tokens = {
          bronze_storage_workspace_id = var.bronze_storage_workspace_id
          bronze_storage_artifact_id = var.bronze_storage_artifact_id
          silver_storage_workspace_id = var.silver_storage_workspace_id
          silver_storage_artifact_id = var.silver_storage_artifact_id
          data_pipeline_objectid = var.data_pipeline_objectid

        }
    }
  }
}