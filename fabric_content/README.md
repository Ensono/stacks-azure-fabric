# Stacks Fabric Content

This directory contains resources and deployment scripts for Microsoft Fabric environments, managed via Azure DevOps pipelines.

The resources are grouped into directories, which correspond to the Fabric workspaces:

- [`analytics`](./analytics/README.md): Contains data analytics and reporting content, specific to a certain business domain, e.g. Power BI report, Semantic Models.
- [`data_engineering`](./data_engineering/README.md): Contains data engineering resources and core data pipelines, e.g. Data Pipelines, Notebooks, Spark job definitions.


## Manual Deployment via Terraform

Fabric contents are meant to be deployed via Azure DevOps pipelines. However, if you need to deploy manually in the development environment, follow these steps:

1. Ensure you have the required Service Principal credentials (see below).
2. Export the credentials as environment variables.
3. In order to store Terraform state locally (not in Azure ADLS), remove the `azurerm` backend blocks from `providers.tf`. Keeping `azurerm` requires additional configuration for remote state (out of scope here).
4. Export any additional environment variables required by the resource (see that resource’s README.md for details).
5. Run the deployment commands (e.g., `terraform init`, `terraform plan`, `terraform apply`) from the appropriate directory.

### Service Principal Credentials for Fabric Deployments

All Terraform deployments require Service Principal credentials, stored as environment variables.
The Service Principal used for Fabric deployments is named **StacksDeployer**.

Set the following environment variables (replace values with your actual credentials):

```sh
export FABRIC_CLIENT_ID="<StacksDeployer_SERVICE_PRINCIPAL_ID>"
export FABRIC_CLIENT_SECRET="<StacksDeployer_SERVICE_PRINCIPAL_SECRET>"
export FABRIC_TENANT_ID="<PARENT_SUBSCRIPTION_ID>"
```

### Example: Running Terraform

```sh
cd fabric_content/<workspace_type>/<fabric_resource>/terraform
terraform init
terraform plan
terraform apply
```
