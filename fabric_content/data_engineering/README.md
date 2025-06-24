# Developing and Deploying Data Pipelines with Stacks

The `data_engineering` module contains example data pipelines for Microsoft Fabric, including both ingest (copy) pipelines and Spark job pipelines. This guide explains how to develop and deploy new data pipelines using the Stacks templates, referencing both [`example_copy_pipeline`](./example_copy_pipeline/) and [`example_spark_pipeline`](./example_spark_pipeline/) as starting points.

---

## Step-by-Step: Creating a New Data Pipeline

This guide covers the development process for Data Pipelines containing:
 - Data Pipeline Copy Activities (data ingestion)
 - Spark Jobs (data processing)

 Additional workload types (e.g. Notebooks) will be added in future.

### 1. Prepare Your Development Environment

- **Create a temporary development workspace in Microsoft Fabric:**
  - Go to the Fabric portal and create a new workspace (e.g., `dev-yourname-temp`).

- **Clone this repository and navigate to the `data_engineering` directory:**
  ```sh
  git clone <your-repo-url>
  cd fabric_content/data_engineering
  ```

### 2. Understand the Example Pipeline Structure

Each example pipeline directory (e.g., [`example_copy_pipeline`](./example_copy_pipeline/), [`example_spark_pipeline`](./example_spark_pipeline/)) contains:
- `ado/pipeline.yml`: Azure DevOps pipeline definition for CI/CD.
- `definition/`: JSON template for the Fabric Data Pipeline (e.g., Copy activity or Spark activity).
- `spark_job/`: (Spark pipelines only) Python scripts for Spark jobs.
- `terraform/`: Terraform code to deploy the pipeline and related resources.
- `README.md`: Documentation for the example.

### 3. Copy the Example as a Starting Point

- Duplicate the example directory:

  ```sh
  cp -r example_copy_pipeline my_ingest_pipeline
  # or for Spark jobs:
  cp -r example_spark_pipeline my_spark_pipeline
  ```

- Rename files and update references from the example name to your new pipeline name (e.g., `my_ingest_pipeline` or `my_spark_pipeline`) in:
  - File and folder names
  - Terraform files (resource names, variables)
  - Pipeline YAML files
  - Any scripts or documentation

### 4. Develop Your Pipeline

1. **Edit the pipeline definition:**
   - **Manually create your pipeline in the Fabric UI** within your temporary development workspace.
   - For ingest pipelines, define your sources, sinks, and transformations (Copy activity).
   - For Spark pipelines, add a Spark Job Definition and configure it to reference your Spark job script.
   - Test the pipeline until it works as expected.
   - When satisfied, use **View → Edit JSON code** in the Fabric UI to copy the pipeline definition.
   - Paste the JSON into your new pipeline’s `definition/` directory in the repo.
   - Parameterize artifact identifiers (e.g., `workspaceId`, `artifactId`, `lakehouseId`, `notebookId`, `sparkJobId`) as shown in the example pipelines. This ensures your pipeline can be deployed to different environments without hardcoding IDs.

2. **(For Spark pipelines) Add or update Spark job scripts:**
   - Place your Python scripts in the `spark_job/` directory.
   - Ensure the pipeline definition references the correct script name.
   - Write appropriate unit, component and end-to-end tests as in the example pipelines.

3. **Update Terraform code:**
   - Go to your pipeline’s `terraform/` directory.
   - Update variables and resource definitions to match your new pipeline and workspace.

4. **(For Spark pipelines) Update ADO YAML pipeline definition**
   - Ensure the Azure DevOps pipeline code uploads the Spark job scripts to the Lakehouse as required.

5. **Update the pipeline README:**
   - Document any specific configuration, variables, or steps required for your pipeline.

### 5. Prepare Your Changes for Deployment

- Ensure all code changes (pipeline definition, Spark job scripts, Terraform, documentation) are committed to a new branch.
- Double-check that all identifiers are parameterized and that your code matches the tested pipeline in your dev workspace.

### 6. Configure Azure DevOps pipeline

- **Create a new Azure DevOps pipeline for your data pipeline:**
  1. In Azure DevOps, navigate to your project and go to **Pipelines** > **New Pipeline**.
  2. Select your repository and choose to configure the pipeline using existing YAML.
     > Note: in case of Stacks the code is in GitHub.
  3. When prompted, provide the path to your new pipeline YAML file (e.g., `fabric_content/data_engineering/my_ingest_pipeline/ado/pipeline.yml`).
  4. Save and the pipeline to ensure it is set up correctly.
  5. Rename your pipeline and give it a clear and descriptive name that matches your new pipeline (e.g., `my_ingest_pipeline` or `my_spark_pipeline`).
  6. Run the pipeline to test it.

### 7. Create a Pull Request

- Open a Pull Request (PR) with your proposed changes.
- The PR will trigger the Azure DevOps pipeline, which will:
  - Validate your changes.
  - Deploy the pipeline and resources to the **TEST environment**.

### 8. Test and Iterate in the Test Environment

- After the PR pipeline completes, verify the deployment in the test Fabric workspace.
- If the pipeline contains an **Office 365 Outlook** or **Teams** activity, you need to manually sign in to an Office account the first time the pipeline is deployed to a workspace, as explained in [Add an Office 365 Outlook activity to your pipeline](https://learn.microsoft.com/en-us/fabric/data-factory/tutorial-end-to-end-integration#add-an-office-365-outlook-activity-to-your-pipeline).
- If further changes are needed, update your branch and the PR; the pipeline will re-run.

### 9. Clean Up

- When finished, delete your temporary development workspace and any resources you created manually to avoid unnecessary costs.

---

## Reference

- See [`example_copy_pipeline`](./example_copy_pipeline/) for a working ingest pipeline example.
- See [`example_spark_pipeline`](./example_spark_pipeline/) for a working Spark job pipeline example.
- For more details on required variables and structure, refer to the `README.md` inside each pipeline directory.
