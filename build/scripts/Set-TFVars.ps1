<#

    .SYNOPSIS
    Read prefixed variables from the environment and output them in a key value form

    .DESCRIPTION
    Terraform can read variables that are prefixed with `TF_VAR_`. Whenever a Terraform
    command is run, this needs to be set.

    To avoid having to set these variables each time, this script will read any variable
    that is prefixed with `TF_VAR_` and output them in a key value form.

    SO that other prefixes can be used, that may have been created by other scripts,
    the prefix can be changed.

    If an environment contained the following variables:

        NAME="fred"
        TF_VAR_location="westeurope"
        TF_VAR_resource_group="rg-fred"

    The resultant file would be:

        location = "westeurope"
        resource_group = "rg-fred"

    .EXAMPLE

    PS> .\Set-TFVars.ps1 | Set-Content -Path ./vars.tfvars

    Check the environment for TF_VAR variables and set in a file called vars.tfvars
#>

[CmdletBinding()]
param (

    [string]
    # Prefix to look for in enviornment variables
    $prefix = "TF_VAR_*"
)

# configure hashtable of found variables
$tfvars = @{}

# Output the values of the enviornment variables
Get-ChildItem -Path env: | Where-Object name -like $prefix | ForEach-Object {

    # Get th name of the variable, without the prefix
    $name = $_.name -replace $prefix, ""

    # set the value
    $value = $_.value

    if (!($value -is [int]) -and !($value.StartsWith("{")) -and !($value.StartsWith("["))) {
        $value = "`"{0}`"" -f $value
    }

    $tfvars[$name.ToLower()] = $value

}

foreach ($item in $tfvars.GetEnumerator()) {
    Write-Output ("{0} = {1}" -f $item.name, $item.value)
}
