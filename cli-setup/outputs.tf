output "cluster_name" { value=data.aws_eks_cluster.existing.name }
output "vpc_id" { value=data.aws_eks_cluster.existing.resources_vpc_config[0].vpc_id }
output "subnet_ids" { value=data.aws_eks_cluster.existing.resources_vpc_config[0].subnet_ids }
output "cluster_arn" { value=data.aws_eks_cluster.existing.arn }
