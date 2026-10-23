output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_arn" { value = aws_eks_cluster.this.arn }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "vpc_id" { value = var.vpc_id }
output "subnet_ids" { value = var.subnet_ids }
