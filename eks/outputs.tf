output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_security_group_id" {
  description = "Security group id attached to the EKS control plane"
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "IRSA OIDC provider ARN (use for IAM Roles for Service Accounts)"
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "Id of the VPC created for the cluster"
  value       = module.vpc.vpc_id
}

output "kubeconfig_command" {
  description = "Command to point kubectl at this cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region} --profile ${var.aws_profile}"
}
