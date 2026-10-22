# Module modules/autoscaler - English reusable
variable "name" { default = "course" }
resource "aws_eks_cluster" "this" {
  name = var.name
}
