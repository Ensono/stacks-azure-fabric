


<#

.SYNOPSIS
    Set the Azure Fabric to paused or unpaused

.DESCRIPTION
    This script is used to suspend or resume the Azure Fabric capacity.

    It uses direct API access rather than any PowerSHell modules or CLI commands so that it
    can be used in a CI/CD pipeline or other automated environments, without the least
    amount of dependencies.

#>

[CmdletBinding()]
param (

    [string]
    # Name of the resource group that contains the Azure Container App environment
    $ResourceGroupName = $env:RESOURCE_GROUP_NAME,

    [string]
    # Set the name of the capacity that is to be suspended or resumed
    $CapacityName = $env:FABRIC_CAPACITY_NAME,

    [bool]
    # State that the commands is going to use User Assigned Identity authentication
    $Identity,

    [bool]
    # State if using an SPN for authentication,
    $SPN,

    [string]
    # Subscription ID
    $SubscriptionId = $env:ARM_SUBSCRIPTION_ID,

    [string]
    # Service Principal Client ID
    $ClientId = $env:ARM_CLIENT_ID,

    [string]
    # Service Principal Client Secret
    $ClientSecret = $env:ARM_CLIENT_SECRET,

    [string]
    # Tenant ID
    $TenantId = $env:ARM_TENANT_ID,

    [bool]
    # Pause the fabric capacity
    $Suspend = $false,

    [bool]
    # Resume the fabric capacity
    $Resume = $false,

    [string]
    # Set the version for the API to use in the call to Azure
    $ApiVersion = "2023-11-01"

)

# Check that SPn and Identity have not both been set
if ($SPN -and $Identity) {
    Write-Error "You must specify either -SPN or -Identity, not both."
    return
}

# Ensure that one of Identity or SPN has been set
if (-not $SPN -and -not $Identity) {
    Write-Error "You must specify either -SPN or -Identity."
    return
}

# Setup the parameters that are required for each parameter set
$requiredVariables = @(
    "ResourceGroupName",
    "CapacityName",
    "SubscriptionId"
)

switch ($SPN) {
    "spn" {
        $requiredVariables += @("ClientId", "ClientSecret", "TenantId")
    }
}

$missing = @()
# Iterate through the required variables and check that they are set
foreach ($var in $requiredVariables) {
    $value = Get-Variable -Name $var -ErrorAction SilentlyContinue
    if ([String]::IsNullOrEmpty($value.Value)) {
        $missing += $var
    }
}

if ($missing.Count -gt 0) {
    Write-Error "The following required variables are not set: $($missing -join ', ')."
    return
}


# Check that either Suspend or Resume is set, but not both
if ($Suspend -and $Resume) {
    Write-Error "You must specify either -Suspend or -Resume not both."
    return
}

# Get a bearer token to use with calls to the Azure API, the way this is done depends on whether
# using a User Assigned Identity or a Service Principal
if ($Identity) {

    # Get the automation variable
    $uai = Get-AutomationVariable -Name "UserAssignedIdentity"
    Connect-AzAccount -Identity -AccountId $uai

    $token = Get-AzAccessToken -ResourceUrl "https://management.azure.com/"

    $bearerToken = $token.Token
}

if ($SPN) {
    # Build up the body to be used when authenticating
    $body = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
        resource      = "https://management.azure.com/"
    }


    # Create the hashtable to be used to authenticate
    $splat = @{
        Method      = "POST"
        Uri         = "https://login.microsoftonline.com/$TenantId/oauth2/token"
        Body        = $body
        ContentType = "application/x-www-form-urlencoded"
        Headers     = @{}
    }

    # Perform the request to get the access token
    $response = Invoke-RestMethod @splat
    $bearerToken = $response.access_token
}

Write-Information "Authenticating with Azure"

# Create the header that is to be used with subsequent calls, that carries the access token
$headers = @{
    Authorization = "Bearer {0}" -f $($bearerToken)
}

# Create the URI object which can be updated to perform the necessary actions
$uri = [System.UriBuilder]::New()
$uri.Scheme = "https"
$uri.Host = "management.azure.com"
$uri.Query = "api-version={0}" -f $ApiVersion

# Set the path to get the status of the capacity
$uri.Path = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Fabric/capacities/{2}" -f $SubscriptionId, $ResourceGroupName, $CapacityName

# Get the status of the capacity, and use this to determine if an action needs to be performed or not
$stateResponse = Invoke-RestMethod -Uri $uri.ToString() -Headers $headers -Method Get

# Get the state of the capacity
$state = $stateResponse.properties.state

# if the state is not paused or running no action can be performed
if ($state -ine "paused" -and $state -ine "active") {
    Write-Error "The capacity is in an invalid state: $state. It must be either 'paused' or 'running' to perform a Suspend or Resume action."
    return
}

# Define if the fabric is being suspended or resumed
if ($Suspend) {
    $action = "suspend"
}
elseif ($Resume) {
    $action = "resume"
}

# Based ont he action check to see if the state is already correct
if ($action -eq "suspend" -and $state -eq "paused") {
    Write-Host "The fabric capacity is already suspended. No action required."
    return
}

if ($action -eq "resume" -and $state -eq "active") {
    Write-Host "The fabric capacity is already running. No action required."
    return
}

Write-Host ("Attempting to {0} the Fabric Capacity" -f $action)

# Set the path that is required to perform the action
$uri.Path = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Fabric/capacities/{2}/{3}" -f $SubscriptionId, $ResourceGroupName, $CapacityName, $action

# Create the parameter splat for the rest method
$splat = @{
    Method  = "POST"
    Uri     = $uri.ToString()
    Headers = $headers
}

Invoke-RestMethod @splat
