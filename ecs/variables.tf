variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Local AWS CLI profile to authenticate with. Set to \"\" in CI."
  type        = string
  default     = "kube-demo"
}

variable "aws_account_id" {
  description = "Optional AWS account id, used only for tagging. Not required."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment tag applied to every resource"
  type        = string
  default     = "demo"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "kube-demo-ecs"
}

variable "container_image" {
  description = "Container image for the demo service"
  type        = string
  default     = "public.ecr.aws/nginx/nginx:stable-alpine"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "Fargate task CPU units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory (MiB)"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of running tasks"
  type        = number
  default     = 2
}
