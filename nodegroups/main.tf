resource "aws_iam_role" "node" {
  name = "${var.name}-node"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}
resource "aws_eks_node_group" "this" {
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
