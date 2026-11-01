provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project           = var.project_name
      SourceProject     = var.project_name
      Environment       = var.environment
      ManagedBy         = "terraform"
      ResourceGenerator = "terraform"
      CostCenter        = var.cost_center
      CloudProvider     = var.cloud_provider
      Owner             = var.owner
      Repository        = var.repository
      Lifecycle         = "ephemeral-7h"
      Provisioner       = "github-actions"
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this.name, "--region", var.region]
    }
  }
}
