variable "name" {
  type    = string
  default = "kube-demo-eks"
}
variable "vpc_id" {
  type    = string
  default = "vpc-0458b076218d5f15d"
}
variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-0eff32e6678035c1b", "subnet-00982afe357bcc225"]
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
