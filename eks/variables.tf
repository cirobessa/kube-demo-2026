variable "cluster_name" {
  type    = string
  default = "kube-demo-eks"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}
variable "aws_profile" {
  type    = string
  default = ""
}
variable "node_min_size" {
  type    = number
  default = 2
}
variable "node_max_size" {
  type    = number
  default = 2
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "cluster_version" {
  type    = string
  default = "1.30"
}
variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

# -----------------------------------------------------------------------------
# Enterprise Tagging & Governance Standards (FinOps & Observability)
# -----------------------------------------------------------------------------
variable "environment" {
  description = "Deployment environment (sandbox, dev, staging, prod)"
  type        = string
  default     = "sandbox"
}

variable "project_name" {
  description = "Source project name for tracking and cost allocation"
  type        = string
  default     = "kube-demo-2026"
}

variable "cost_center" {
  description = "Cost center for financial accountability and billing categorization"
  type        = string
  default     = "devops-platform-cloud"
}

variable "cloud_provider" {
  description = "Target cloud provider identifier"
  type        = string
  default     = "aws"
}

variable "owner" {
  description = "Team or individual accountable for the resource lifecycle"
  type        = string
  default     = "platform-team"
}

variable "repository" {
  description = "Source code Git repository URL"
  type        = string
  default     = "https://github.com/cirobessa/kube-demo-2026"
}
