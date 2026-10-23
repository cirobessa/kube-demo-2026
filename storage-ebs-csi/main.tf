resource "aws_ebs_volume" "this" { availability_zone = var.az size = 10 encrypted = true tags = { Name = var.name } }
