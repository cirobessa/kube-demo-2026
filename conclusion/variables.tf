variable "name" {
  type    = string
  default = "conclusion"
}
variable "vpc_id" {
  type    = string
  default = "vpc-0458b076218d5f15d"
}
variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-0eff32e6678035c1b", "subnet-00982afe357bcc225"]
}
