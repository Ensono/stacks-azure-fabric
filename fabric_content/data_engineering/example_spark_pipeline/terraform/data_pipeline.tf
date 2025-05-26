resource "fabric_spark_job_definition" "example_spark_job" {
  display_name              = "example_spark_job"
  description               = "Example Spark Job"
  workspace_id              = var.engineering_workspace_id
  format                    = "SparkJobDefinitionV1"
  definition = {
    "SparkJobDefinitionV1.json" = {
      source = "${path.module}/../definition/example_spark_job_definition.json.tmpl"
      tokens = {
        "engineeringWorkspaceId" = var.engineering_workspace_id
        "engineeringLakehouseId" = var.engineering_lakehouse_id
        "silverWorkspaceId" = var.silver_workspace_id
        "silverLakehouseId" = var.silver_lakehouse_id
        "goldWorkspaceId" = var.gold_workspace_id
        "goldLakehouseId" = var.gold_lakehouse_id
      }
    }
  }
}

resource "fabric_data_pipeline" "example_spark_pipeline" {
  display_name = "example_spark_pipeline"
  description  = "Example data pipeline with a Spark job"
  workspace_id = var.processing_workspace_id
  format       = "Default"
  definition = {
    "pipeline-content.json" = {
      source = "${path.module}/../definition/example_spark_pipeline.json.tmpl"
      tokens = {
        "sparkJobDefinitionId" = fabric_spark_job_definition.example_spark_job.id
        "processingWorkspaceId" = var.processing_workspace_id
      }
    }
  }
  depends_on = [
    fabric_spark_job_definition.example_spark_job
  ]
}
