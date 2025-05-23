# Prerequisites

Currently it is required that the Python module example_spark_job.py is available in the lakehouse Files in the processing workspace.

❗️ TODO: 2894 Uploading Python file should be ensured within the deployment pipeline User Story

# Required environment variables

## Terraform

```sh
export TF_VAR_processing_workspace_id="<PROCESSING_WORKSPACE_ID>"
export TF_VAR_processing_lakehouse_id="<PROCESSING_LAKEHOUSE_ID>"
export TF_VAR_silver_workspace_id="<SILVER_WORKSPACE_ID>"
export TF_VAR_silver_lakehouse_id="<SILVER_LAKEHOUSE_ID>"
export TF_VAR_gold_workspace_id="<GOLD_WORKSPACE_ID>"
export TF_VAR_gold_lakehouse_id="<GOLD_LAKEHOUSE_ID>"
```
