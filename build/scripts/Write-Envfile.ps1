<#

.SYNOPSIS
Creates an environment file for the chosen shell which can be used to configure the
Terraform deployment

#>

[CmdletBinding()]
param (
    [string]
    # Path to the stage environment file
    $Path = "$PSScriptRoot/../config/stage_envvars.yml",

    [String]
    # Cloud platform that is being targetted
    $Cloud = "azure",

    [string]
    # Stage to create environment variables for
    $Stage,

    [string]
    # Shell that the script will be run in
    $Shell,

    [string]
    # Target directory to write files to, relative to the location
    # of this script
    $Target = "local"
)

. $PSScriptRoot/functions/Render-Data.ps1

# Read in the environment file
if (!(Test-Path -Path $Path)) {
    Write-Error ("Unable to find environment file: {0}" -f $Path)
    return
}

# Convert the data from the file into an object
$data = Get-Content -Path $Path -Raw | ConvertFrom-Yaml

# Create the configuration for each shell
$config = @{
    powershell = @{
        template  = @"
{0}`$env:{1} = "{2}"

"@
        extension = "ps1"
    }

    bash       = @{
        template  = @"
{0} export {1}="{2}"

"@
        extension = "bash"
    }
}

# Create PSCustomObject to hold the data for each stage, the default details and the cloud credentials
# this is so that data can be updated later in the process
$credentials = [ordered]@{}
$common = [ordered]@{}

# Iterate around the default variables and set the necessary values
foreach ($var in $data.default.variables) {

    # create the item object for the data
    $item = [PSCustomObject]@{
        description = ""
        value       = ""
        required    = $true
    }

    # Only proceed if the variable is required
    if ($var.containskey("required")) {
        $item.required = $var.required
    }

    # Define the value based on the name as in some cases the values can be taken
    # from the current environment
    $value = ""

    if ($var.name -ieq "cloud_platform") {
        $item.value = $Cloud
    }

    # If a description exists add it into the array
    if ($var.containskey("description")) {
        $item.description = $var.description
    }

    # if it contains a default value add it
    if ($var.containskey("default")) {
        $item.value = $var.default
    }

    # Based on the shell, render the template for the variable
    $common[$var.name] = $item
}

# Add in the credentials for the chosen platform
foreach ($param in $data.default.credentials.$Cloud) {
    # create the item object for the data
    $item = [PSCustomObject]@{
        description = ""
        value       = ""
        required    = $true
    }

    # check to see if the value already exists, and if so add that
    if (Test-Path -Path ("env:\{0}" -f $param.name)) {
        $item.value = (Get-Item -Path ("env:\{0}" -f $param.name)).Value
    }

    $credentials[$param.name] = $item
}

# Create a file for the credentials so that they only need to be set once and then
# sourced in each file
$rendered = Render-Data($credentials)
$credfile = "$PSScriptRoot/../../{1}/credentials.{0}" -f $config[$Shell].extension, $Target

# Ensure that the parent path exists
$parent_dir = Split-Path -Path $credfile -Parent
if (!(Test-Path -Path $parent_dir)) {
    New-Item -Path $parent_dir -ItemType Directory | Out-Null
}

Write-Information ("Writing credentials file: " -f $credfile)
Set-Content -Path $credfile -Value ($rendered -join "`n")

# Ensure that the file is writeable
if ($IsLinux) {
    Invoke-Expression ("chmod 666 {0}" -f $credfile)
}


# Set a variable for the Terraform file location template
$template = @{
    "TF_FILE_LOCATION" = $common["TF_FILE_LOCATION"].value
}

# Finally add in the specific variables for the stage
foreach ($itm in $data.stages) {

    # determine the filename for the envfile
    # this is based on the stage name and the shell that has been requested
    $envfile = "$PSScriptRoot/../../{2}/envfile_{0}.{1}" -f $itm.Name.tolower(), $config[$Shell].extension, $Target

    # set the name of the stage for the file
    $common["STAGE"].value = $itm.name.toLower()

    # set the path for the terraform files
    $common["TF_FILE_LOCATION"].value = $template["TF_FILE_LOCATION"] -replace "TF_STAGE", $itm.name.toLower()

    # create hashtable for the stage vars
    $stage_vars = [ordered]@{}

    foreach ($var in $itm.variables) {

        # create the item object for the data
        $data = [PSCustomObject]@{
            description = ""
            value       = ""
            required    = $false
        }

        # Only proceed if the variable is required
        if ($var.containskey("required")) {
            $data.required = $var.required
        }

        # If a description exists add it into the array
        if ($var.containskey("description")) {
            $data.description = $var.description
        }

        # set some default values
        $data.value = ""

        if ($var.containskey("default")) {
            $data.value = $var.default
            $data.required = $true
        }

        # check to see if the value already exists, and if so add that
        if (Test-Path -Path ("env:\{0}" -f $var.name)) {
            $data.value = (Get-Item -Path ("env:\{0}" -f $var.name)).Value
        }


        # Based on the shell, render the template for the variable
        $stage_vars[$var.name] = $data
    }

    # write out the file
    $data = $common + $stage_vars
    $output = Render-Data($data)

    # Ensure that the parent directory exists
    $parent_dir = Split-Path -Path $envfile -Parent
    if (!(Test-Path -Path $parent_dir)) {
        New-Item -Path $parent_dir -ItemType Directory | Out-Null
    }

    # Add in the sourcing of the credentials file in the script
    switch ($shell) {
        "powershell" {
            $source_creds = '. (Split-Path -Parent -Path $PSScriptRoot)/credentials.ps1'
        }
        "bash" {
            $source_creds = '. $(dirname $0)/credentials.bash'
        }
    }

    # Add the source of the creds to the beginning of the output
    $output = , $source_creds + $output

    Write-Information ("Writing environment file for stage: {0} [{1}]" -f $itm.name, $envfile)
    Set-Content -Path $envfile -Value ($output -join "`n")

    # Ensure that the file is writeable
    if ($IsLinux) {
        Invoke-Expression ("chmod 666 {0}" -f $envfile)
    }
}
