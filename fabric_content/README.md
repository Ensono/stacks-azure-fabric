# Required environment variables

## Service Principal credentials for Fabric deployments

All terraform deployments require the Service Principal credentials stored as Environment Variables. The Service Principal name used for Fabric deployments is StacksDeployer.

Please adjust and use the following snippet:

```sh
export FABRIC_CLIENT_ID="<StacksDeployer_SERVICE_PRINCIPAL_ID>"
export FABRIC_CLIENT_SECRET="<StacksDeployer_SERVICE_PRINCIPAL_SECRET>"
export FABRIC_TENANT_ID="<PARENT_SUBSCRIPTION_ID>"
```
