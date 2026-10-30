variable "name" {
  type    = string
  default = "kube-demo-eks"
}
variable "aws_profile" {
  type    = string
  default = ""
}
variable "node_min_size" {
  type    = number
  default = 1
}
variable "node_max_size" {
  type    = number
  default = 3
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "cluster_version" {
  type    = string
  default = "1.29"
}
variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}
variable "cluster_name" {
  type    = string
  default = "kube-demo-eks"
}
