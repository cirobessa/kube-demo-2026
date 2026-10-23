variable "name" { type = string default = "kube-demo-eks" }
variable "vpc_id" { type = string default = "" }
variable "subnet_ids" { type = list(string) default = [] }
variable "aws_profile" { type = string default = "" }
