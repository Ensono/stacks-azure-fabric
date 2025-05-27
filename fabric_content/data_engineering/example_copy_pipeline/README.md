# Data Pipeline Copy Example Workload

__Workload Name:__ example_ingest_pipeline

__Workload Type:__ Ingest

__Description:__ Ingest data into a LakeHouse using a copy activity in a data pipeline.

Created in Stacks Azure Data Platform. Contains resources for:

* Data Pipeline resources


# Required environment variables

## Terraform

```sh
export TF_VAR_engineering_workspace_id="<ENGINEERING_WORKSPACE_ID>"
export TF_VAR_bronze_workspace_id="<BRONZE_WORKSPACE_ID>"
export TF_VAR_bronze_lakehouse_id="<BRONZE_LAKEHOUSE_ID>"
export TF_VAR_silver_workspace_id="<SILVER_WORKSPACE_ID>"
export TF_VAR_silver_lakehouse_id="<SILVER_LAKEHOUSE_ID>"
```
