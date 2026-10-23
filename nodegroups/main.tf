resource "aws_eks_nodegroup" "this" {
  cluster_name    = var.name
  node_group_name = "${var.name}-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
  instance_types = ["t3.medium"]
}
