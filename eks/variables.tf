variable "name" {
  type    = string
  default = "kube-demo-eks"
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
variable "node_min_size" { type = number default = 1 }
variable "node_max_size" { type = number default = 3 }
variable "node_desired_size" { type = number default = 2 }
