locals {

  template_files = [
    {
      filename = "envvars.bash.tpl",
      type     = "bash"
    },
    {
      filename = "envvars.ps1.tpl",
      type     = "powershell"
    },
    {
      filename = "inputs.auto.tfvars.tpl",
      type     = "terraform"
    }
  ]

  # Create a local object for the template mapping so that the script files can be generated
  template_items = {
    for template_file in local.template_files : template_file.filename => {
      envname = terraform.workspace
      file    = template_file.filename
      items   = local.outputs
      path    = "${path.module}/../templates/${template_file.filename}"
    }
  }

  # Define the outputs for this module
  outputs = merge(jsondecode(var.outputs), { "module_path" : path.module })

  # Simplify the naming module and extend for unsupported naming types
  naming_map = {
    for comp_k, comp_v in module.azure_naming : comp_k => merge({
      for res_k, res_v in comp_v : res_k => {
        name = res_v.name_unique
      } if can(res_v.name_unique)
    }, lookup(local.extended_naming_map, comp_k, {}))
  }

  extended_naming_map = {
    for comp_k, comp_v in module.azure_naming : comp_k => {
      "fabric_capacity" = {
        name = replace(
          lookup(module.azure_naming[comp_k], "storage_account", {}).name_unique,
          regex("^.{2}", lookup(module.azure_naming[comp_k], "storage_account", {}).name_unique),
          "afc"
        )
      },
      "fabric_workspace" = {
        name = replace(
          lookup(module.azure_naming[comp_k], "resource_group", {}).name_unique,
          regex("^.{2}", lookup(module.azure_naming[comp_k], "resource_group", {}).name_unique),
          "afw"
        )
      },
      "fabric_lakehouse" = {
        name = replace(
          lookup(module.azure_naming[comp_k], "resource_group", {}).name_unique,
          regex("^.{2}", lookup(module.azure_naming[comp_k], "resource_group", {}).name_unique),
          "afl"
        )
      }
    }
  }
}
