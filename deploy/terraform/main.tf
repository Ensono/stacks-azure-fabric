
module "naming" {
  source = "./modules/ensono-stacks-foundation-azure"

  outputs = jsonencode(local.outputs)

  location           = var.location
  company_name_short = local.company_short_name
  project            = [var.project]
  stage_name         = "fabric_infra"
  output_path        = "${path.module}/../../../outputs"
  generate_env_files = var.create_env_files
  environments       = local.environments
}
