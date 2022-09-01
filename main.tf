locals {
  function_path_temp = "${path.root}/temp/${var.function_name}"
  shared_paths = var.shared_paths
  test_paths = var.test_paths
  code_paths = concat([var.function_path], local.shared_paths)
}

resource "null_resource" "lambda_exporter" {
  # (some local-exec provisioner blocks, presumably...)

  triggers = {
    index = jsonencode([for path in local.code_paths : {
    for fn in fileset(path, "**") :
    fn => filesha256("${path}/${fn}")
  }])
  }
}

data "null_data_source" "wait_for_lambda_exporter" {
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    lambda_exporter_id = null_resource.lambda_exporter.id

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    source_dir = local.function_path_temp
  }
}

resource "null_resource" "tests" {
  for_each = toset(local.test_paths)
  provisioner "local-exec" {
    command = "python -m pytest ${each.value}"
  }
}

resource "null_resource" "pip_install" {
  depends_on = [null_resource.tests]
  provisioner "local-exec" {
    command = "${path.module}/pip_install.sh"
    environment = {
      source_dir = var.function_path
      temp_source_dir = local.function_path_temp
    }
  }
}

data "archive_file" "create_dist_pkg" {
  depends_on = [
    null_resource.pip_install
  ]
  type = "zip"
  source_dir = data.null_data_source.wait_for_lambda_exporter.outputs.source_dir
  output_path = "${local.function_path_temp}.zip"
}
