locals {
  function_path_temp = "${path.root}/temp/${var.function_name}"
  shared_paths = var.shared_paths
  test_paths = var.test_paths
  code_paths = concat([var.function_path], local.shared_paths)
}

resource "null_resource" "tests" {
  triggers = {
    always_run = timestamp()
  }
  for_each = toset(local.test_paths)
  provisioner "local-exec" {
    command = "python -m pytest ${each.value}"
  }
}

resource "null_resource" "pip_install" {
  triggers = {
    always_run = timestamp()
  }
  depends_on = [null_resource.tests]
  provisioner "local-exec" {
    command = "${path.module}/pip_install.sh"
    environment = {
      source_dir = var.function_path
      temp_source_dir = local.function_path_temp
    }
  }
}

resource "null_resource" "copy_resources" {
  depends_on = [null_resource.pip_install]
  for_each = toset(local.shared_paths)
  provisioner "local-exec" {
    command = "cp -r ${each.value} ${local.function_path_temp}"
  }
}

data "archive_file" "create_dist_pkg" {
  depends_on = [
    null_resource.pip_install,
    null_resource.copy_resources
  ]
  type = "zip"
  source_dir = local.function_path_temp
  output_path = "${local.function_path_temp}.zip"
}
