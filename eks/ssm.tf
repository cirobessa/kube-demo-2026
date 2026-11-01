# ==============================================================================
# AWS Systems Manager (SSM) Parameter Store: Base Cluster Info
# ==============================================================================

resource "aws_ssm_parameter" "cluster_info" {
  name        = "/kube-demo-2026/cluster/info"
  description = "Base EKS cluster infrastructure information, endpoints and OIDC provider"
  type        = "String"
  tier        = "Standard"

  value = jsonencode({
    cluster_name                   = aws_eks_cluster.this.name
    cluster_arn                    = aws_eks_cluster.this.arn
    cluster_endpoint               = aws_eks_cluster.this.endpoint
    cluster_version                = aws_eks_cluster.this.version
    oidc_provider_arn              = aws_iam_openid_connect_provider.eks.arn
    vpc_id                         = aws_vpc.this.id
    public_subnet_ids              = aws_subnet.public[*].id
    private_subnet_ids             = aws_subnet.private[*].id
    route53_domain                 = local.lab_domain
    acm_cert_arn                   = local.has_lab_zone ? aws_acm_certificate.lab_cert[0].arn : ""
    platform_credentials_parameter = "/kube-demo-2026/platform/credentials"
  })

  tags = {
    Name        = "kube-demo-2026-cluster-info"
    Environment = var.environment
    CostCenter  = var.cost_center
    Project     = var.project_name
  }
}
