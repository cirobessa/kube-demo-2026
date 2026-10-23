resource "aws_efs_file_system" "this" { creation_token = var.name encrypted = true tags = merge({Name=var.name}, var.tags) }
