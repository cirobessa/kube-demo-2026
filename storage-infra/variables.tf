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

variable "ebs_data_size" {
  description = "Size (GiB) of the data EBS volume"
  type        = number
  default     = 20
}

variable "ebs_logs_size" {
  description = "Size (GiB) of the logs EBS volume"
  type        = number
  default     = 10
}

variable "ebs_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "ebs_throughput" {
  description = "Throughput (MB/s) for gp3 volumes"
  type        = number
  default     = 125
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode: bursting | provisioned | elastic"
  type        = string
  default     = "bursting"
}
