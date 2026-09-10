variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Local AWS CLI profile to authenticate with. Set to \"\" in CI (credentials come from the environment)."
  type        = string
  default     = "kube-demo"
}

variable "aws_account_id" {
  description = "Optional AWS account id, used only for tagging / policy scoping. Not required."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment tag applied to every resource"
  type        = string
  default     = "demo"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "kube-demo-eks"
}

variable "cluster_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR block for the cluster VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum nodes in the managed node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum nodes in the managed node group"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired nodes in the managed node group"
  type        = number
  default     = 2
}
