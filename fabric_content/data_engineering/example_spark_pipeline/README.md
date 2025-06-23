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

# Testing

## Unit tests
Example unit tests are available within `./spark_job/tests/unit`
Tests are written with `pytest`

How to run tests locally:
```shell
cd fabric_content
poetry install
poetry run pytest data_engineering/example_spark_pipeline/spark_job/tests/unit
```

## Component tests
Example component tests are available within `./spark_job/tests/component`
Tests are written using: `pytest`, `pytest-bdd`, `pyspark`

How to run tests locally:
```shell
cd fabric_content
poetry install
PYTHONPATH=. poetry run pytest data_engineering/example_spark_pipeline/spark_job/tests/component
```

## End-to-end tests
Example E2E tests are available within `./spark_job/tests/end_to_end`
Tests are written using: `pytest` and `pytest-bdd`

How to run tests locally:
The following environment variables need to be set:
- FABRIC_TENANT_ID
- FABRIC_CLIENT_ID
- FABRIC_CLIENT_SECRET
- ENGINEERING_WORKSPACE_ID
- GOLD_WORKSPACE_ID
- GOLD_LAKEHOUSE_ID

```shell
cd fabric_content
poetry install
PYTHONPATH=. poetry run pytest data_engineering/example_spark_pipeline/spark_job/tests/end_to_end
```
