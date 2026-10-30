# IRSA role for the Fluentd DaemonSet (deployed from backstate-infra, via
# ArgoCD) to ship container logs to CloudWatch Logs without granting the
# permission to every node via the node's own instance profile.
data "aws_iam_policy_document" "fluentd_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:logging:fluentd"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fluentd" {
  name               = "${var.name}-fluentd-role"
  assume_role_policy = data.aws_iam_policy_document.fluentd_assume.json
}

data "aws_iam_policy_document" "fluentd_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
    ]
    resources = ["arn:aws:logs:*:*:log-group:/eks/${var.name}/*"]
  }
}

resource "aws_iam_role_policy" "fluentd_cloudwatch" {
  name   = "${var.name}-fluentd-cloudwatch"
  role   = aws_iam_role.fluentd.id
  policy = data.aws_iam_policy_document.fluentd_cloudwatch.json
}
