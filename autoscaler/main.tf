resource "aws_iam_policy" "autoscaler" {
  name = "${var.name}-autoscaler-policy"
  policy = file("autoscaler-policy.json")
}
