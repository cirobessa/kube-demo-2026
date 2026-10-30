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
