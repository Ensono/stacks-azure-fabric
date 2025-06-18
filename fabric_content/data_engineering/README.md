# Developing and Deploying Data Pipelines with Stacks

The `data_engineering` module contains example data pipelines. This guide explains how to develop and deploy new data pipelines using the Stacks templates.

---

## Step-by-Step: Creating a New Ingest Data Pipeline

This guide uses [`example_copy_pipeline`](./example_copy_pipeline/) as a reference.

### 1. Prepare Your Development Environment

- **Create a temporary development workspace in Microsoft Fabric:**
  - Go to the Fabric portal and create a new workspace (e.g., `dev-yourname-temp`).

- **Clone this repository and navigate to the `data_engineering` directory:**
  ```sh
  git clone <your-repo-url>
  cd fabric_content/data_engineering
  ```

### 2. Understand the Example Pipeline Structure

The [`example_copy_pipeline`](./example_copy_pipeline/) directory contains:
- `ado/pipeline.yml`: Azure DevOps pipeline definition for CI/CD.
- `terraform/`: Terraform code to deploy the pipeline and related resources.
- `definition/`: JSON template for the Fabric Data Pipeline (including Copy activity).
- `README.md`: Documentation for the example.

### 3. Copy the Example as a Starting Point

- Duplicate the example directory:
  ```sh
  cp -r example_copy_pipeline my_ingest_pipeline
  ```
- Rename files and update references from `example_copy_pipeline` to your new pipeline name (`my_ingest_pipeline`) in:
  - File and folder names
  - Terraform files (resource names, variables)
  - Pipeline YAML files
  - Any scripts or documentation

### 4. Develop Your Pipeline

1. **Edit the pipeline definition:**
   - **Manually create your pipeline in the Fabric UI** within your temporary development workspace.
   - Test the pipeline until it works as expected.
   - When satisfied, use **View → Edit JSON code** in the Fabric UI to copy the pipeline definition.
   - Paste the JSON into your new pipeline’s `definition/` directory in the repo.
   - Parameterize artifact identifiers (e.g., `workspaceId`, `artifactId`) as shown in the example pipeline. This ensures your pipeline can be deployed to different environments without hardcoding IDs.
2. **Update Terraform code:**
   - Go to `my_ingest_pipeline/terraform/`
   - Update variables and resource definitions to match your new pipeline and workspace.
3. **Update the pipeline README:**
   - Document any specific configuration, variables, or steps required for your pipeline.

### 5. Prepare Your Changes for Deployment

- Ensure all code changes (pipeline definition, Terraform, documentation) are committed to a new branch.
- Double-check that all identifiers are parameterized and that your code matches the tested pipeline in your dev workspace.

### 6. Create a Pull Request

- Open a Pull Request (PR) with your proposed changes.
- The PR will trigger the Azure DevOps pipeline, which will:
  - Validate your changes.
  - Deploy the pipeline and resources to the **TEST environment**.

### 7. Test and Iterate in the Test Environment

- After the PR pipeline completes, verify the deployment in the test Fabric workspace.
- If further changes are needed, update your branch and the PR; the pipeline will re-run.

### 8. Clean Up

- When finished, delete your temporary development workspace and any resources you created manually to avoid unnecessary costs.
