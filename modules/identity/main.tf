data "aws_iam_policy_document" "processing_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "data_processing" {
  name               = "data-processing-execution-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.processing_assume_role.json

  tags = {
    Name        = "data-processing-execution-role-${var.environment}"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "data_processing_s3_permissions" {
  statement {
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:GetObject"]

    resources = [
      "${var.data_lake_bucket_arn}/${var.data_lake_prefix}*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.data_lake_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [var.data_lake_prefix, "${var.data_lake_prefix}*"]
    }
  }
}

resource "aws_iam_policy" "data_processing_s3" {
  name        = "data-processing-s3-policy-${var.environment}"
  description = "Permite listar y leer/escribir objetos solo bajo el prefijo configurado"
  policy      = data.aws_iam_policy_document.data_processing_s3_permissions.json
}

resource "aws_iam_role_policy_attachment" "data_processing_s3" {
  role       = aws_iam_role.data_processing.name
  policy_arn = aws_iam_policy.data_processing_s3.arn
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "control_plane_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "control_plane_audit" {
  name               = "control-plane-audit-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.control_plane_assume_role.json

  tags = {
    Name        = "control-plane-audit-role-${var.environment}"
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "control_plane_audit_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcs",
      "iam:GetAccountAuthorizationDetails",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListPolicies",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicyStatus",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketVersioning",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "control_plane_audit_read_only" {
  name        = "control-plane-audit-read-only-${var.environment}"
  description = "Acciones explícitas de lectura para auditoría de infraestructura"
  policy      = data.aws_iam_policy_document.control_plane_audit_read_only.json
}

resource "aws_iam_role_policy_attachment" "control_plane_audit_read_only" {
  role       = aws_iam_role.control_plane_audit.name
  policy_arn = aws_iam_policy.control_plane_audit_read_only.arn
}
