resource "fabric_data_pipeline" "example_ingest_pipeline_gc" {
  display_name = "example_ingest_pipeline_gc"
  description  = "Example data pipeline with a copy activity"
  workspace_id = var.processing_workspace_id
  format       = "Default"
  definition = {
    "pipeline-content.json" = {
      source = "${path.module}/pipeline_content.json.tmpl",
      tokens = {
          bronze_storage_workspace_id = var.bronze_storage_workspace_id,
          silver_storage_workspace_id = var.silver_storage_workspace_id
        }
    }
  }
}