resource "fabric_data_pipeline" "example_copy_pipeline" {
  display_name = "example_copy_pipeline"
  description  = "Example data pipeline with a copy activity"
  workspace_id = var.engineering_workspace_id
  format       = "Default"
  definition = {
    "pipeline-content.json" = {
      source = "${path.module}/../definition/pipeline_content.json.tmpl",
      tokens = {
        bronze_workspace_id = var.bronze_workspace_id
        bronze_lakehouse_id = var.bronze_lakehouse_id
        silver_workspace_id = var.silver_workspace_id
        silver_lakehouse_id = var.silver_lakehouse_id
        environment         = var.environment
        data_team_email     = var.data_team_email
      }
    }
  }
}
