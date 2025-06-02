
module "naming" {
  source = "./modules/ensono-stacks-foundation-azure"

  outputs = jsonencode(local.outputs)

  location           = var.location
  company_name_short = "ens"
  project            = [var.project]
  stage_name         = "fabric_infra"
  output_path        = "${path.module}/../../outputs"
  generate_env_files = false
}
