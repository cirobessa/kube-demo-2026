# S3 Mountpoint CSI Driver IRSA
data "aws_iam_policy_document" "s3_csi_assume" {
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
      values   = ["system:serviceaccount:kube-system:s3-csi-driver-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_csi" {
  name               = "${var.cluster_name}-s3-csi-role"
  assume_role_policy = data.aws_iam_policy_document.s3_csi_assume.json
}

resource "aws_iam_role_policy_attachment" "s3_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.s3_csi.name
}

# Fluentd IRSA role for log shipping to CloudWatch
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
  name               = "${var.cluster_name}-fluentd-role"
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
    resources = ["arn:aws:logs:*:*:log-group:/eks/${var.cluster_name}/*"]
  }
}

resource "aws_iam_role_policy" "fluentd_cloudwatch" {
  name   = "${var.cluster_name}-fluentd-cloudwatch"
  role   = aws_iam_role.fluentd.id
  policy = data.aws_iam_policy_document.fluentd_cloudwatch.json
}
