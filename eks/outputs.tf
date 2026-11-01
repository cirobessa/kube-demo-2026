output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_arn" { value = aws_eks_cluster.this.arn }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "cluster_version" { value = aws_eks_cluster.this.version }
output "cluster_certificate_authority_data" {
  value     = aws_eks_cluster.this.certificate_authority[0].data
  sensitive = true
}
output "cluster_security_group_id" { value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id }
output "oidc_provider_arn" { value = aws_iam_openid_connect_provider.eks.arn }
output "node_group_arn" { value = aws_eks_node_group.this.arn }
output "node_group_status" { value = aws_eks_node_group.this.status }
output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "fluentd_role_arn" { value = aws_iam_role.fluentd.arn }
output "s3_csi_role_arn" { value = aws_iam_role.s3_csi.arn }
output "monitoring_namespace" { value = kubernetes_namespace.monitoring.metadata[0].name }
output "prometheus_service_url" {
  value = "http://prometheus-server.${kubernetes_namespace.monitoring.metadata[0].name}.svc.cluster.local"
}
output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region ${var.region}"
}

# -----------------------------------------------------------------------------
# Route 53 Auto-Discovery, AWS Account & ACM SSL/TLS Outputs
# -----------------------------------------------------------------------------
output "aws_account_id" {
  description = "Auto-discovered AWS Account ID"
  value       = local.aws_account_id
}

output "route53_lab_domain" {
  description = "Auto-discovered Route 53 ephemeral lab domain"
  value       = local.lab_domain
}

output "route53_lab_zone_id" {
  description = "Auto-discovered Route 53 public hosted zone ID"
  value       = local.lab_zone_id
}

output "acm_certificate_arn" {
  description = "Issued and validated ACM Wildcard SSL/TLS certificate ARN for HTTPS Load Balancers"
  value       = local.has_lab_zone ? aws_acm_certificate.lab_cert[0].arn : ""
}
