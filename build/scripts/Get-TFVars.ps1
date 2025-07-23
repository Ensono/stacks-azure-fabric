
[CmdletBinding()]
param (

    [string]
    # Path to the Terraform templates
    $path,

    [string[]]
    # Stage that the variables pertain to
    $stagenames,

    [string]
    # Name of the variable file
    $file = "variables.tf"
)

# Add null to the stagenames if it is not set
if ($stagenames.length -eq 0) {
    $stagenames = @($nul)
}

# create the stages
$stages = @()

# iterate around the stage names
foreach ($stage in $stagenames) {

    # Create hashtable in which to hold the variables
    $vars = @()

    # build up the path to look for the vars file
    $filepath = [IO.Path]::Join($path, $stage, $file)

    if (!(Test-Path -Path $filepath)) {
        Write-Error ("Unable to find Terraform variables file: {0}" -f $filepath)
        continue
    }

    # Read in the HCL variables file as a Json Object
    $tf_vars = ConvertFrom-Hcl -Path $filepath

    # Get all the the names of the variables
    $names = $tf_vars.variable.psobject.properties | Foreach-Object { $_.Name }

    # iterate around the names
    foreach ($name in $names) {

        # get the information about the variable
        $info = $tf_vars.variable.$name

        # Create object to add to the vars
        $var = @{
            name     = "TF_VAR_{0}" -f $name
            required = $true
        }

        # determine what the description value should be
        $description = ""

        # if a description has been set add it to the object
        if (![string]::IsNullOrEmpty($info.description)) {
            $description = $info.description
        }

        if ($name -eq "attributes") {
            Write-Host ("'{0}'" -f $info.default)
        }

        # If a default value has been set, state that the variable is not required
        # and add a comment after it which states the default value
        if (![string]::IsNullOrEmpty($info.default)) {
            $var.required = $false
            $description += " (Default: {0})" -f $info.default
        }

        if (![string]::IsNullOrEmpty($description)) {
            $var.description = $description
        }

        # Add to the vars array
        $vars += , $var
    }

    # Ensure that the required variables are the top of the list
    # and that all vars are alphabetically sorted within the group
    $ordered = @()
    $ordered += $vars | Where-Object { $_.required -eq $true } | Sort-Object Name
    $ordered += $vars | Where-Object { $_.required -eq $false } | Sort-Object Name

    $stages += @{name = $stage; variables = $ordered }
}

# Build up the object for the final file
$stage_envvars = @{
    stages = $stages
}

$stage_envvars | ConvertTo-Yaml
