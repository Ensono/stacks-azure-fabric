
resource "local_file" "variable_output" {

  for_each = var.generate_env_files ? { for item in local.template_items : "${item.envname}-${item.file}" => item } : {}

  content  = templatefile("templates/${each.value.file}", { items = each.value.items })
  filename = "${path.module}/${var.output_path}/terraform/${each.value.envname}-networking-${trimsuffix(each.value.file, ".tpl")}"

}
