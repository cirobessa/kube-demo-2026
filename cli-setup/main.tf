resource "aws_eks_cluster" "this" { name = var.name role_arn = aws_iam_role.eks_cluster.arn vpc_config { subnet_ids = var.subnet_ids endpoint_public_access = true } }
resource "aws_iam_role" "eks_cluster" { name = "${var.name}-cluster" assume_role_policy = jsonencode({ Version="2012-10-17", Statement=[{Effect="Allow",Principal={Service="eks.amazonaws.com"},Action="sts:AssumeRole"}] }) }
