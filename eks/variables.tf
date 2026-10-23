variable "name" {
  type    = string
  default = "kube-demo-eks"
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_id" {
  type    = string
  default = ""
}
variable "subnet_ids" {
  type    = list(string)
  default = []
}
variable "aws_profile" {
  type    = string
  default = ""
}
