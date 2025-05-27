# Data Pipeline Spark Example Workload

__Workload Name:__ example_spark_pipeline

__Workload Type:__ Processing

__Description:__ Creates a Delta table with sample data, saves it to a Silver lakehouse, and then transforms the data and saves it to a Gold lakehouse.

Created in Stacks Azure Fabric. Contains resources for:

* Spark Job Definition
* Data Pipeline



# Prerequisites

Currently it is required that the Python module example_spark_job.py is available in the lakehouse Files in the data engineering workspace.

❗️ TODO: 2894 Uploading Python file should be ensured within the deployment pipeline User Story

# Required environment variables

## Terraform

```sh
export TF_VAR_engineering_workspace_id="<ENGINEERING_WORKSPACE_ID>"
export TF_VAR_engineering_lakehouse_id="<ENGINEERING_LAKEHOUSE_ID>"
export TF_VAR_silver_workspace_id="<SILVER_WORKSPACE_ID>"
export TF_VAR_silver_lakehouse_id="<SILVER_LAKEHOUSE_ID>"
export TF_VAR_gold_workspace_id="<GOLD_WORKSPACE_ID>"
export TF_VAR_gold_lakehouse_id="<GOLD_LAKEHOUSE_ID>"
```
