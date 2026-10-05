# 1. Trust Policy: Permite al servicio Kinesis Firehose asumir este rol
data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "kinesis-firehose-delivery-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json

  tags = {
    Name        = "firehose-delivery-role-${var.environment}"
    Environment = var.environment
  }
}

# 2. Permission Policy: Mínimo privilegio estricto sobre el bucket S3
data "aws_iam_policy_document" "firehose_s3_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      var.data_lake_bucket_arn,
      "${var.data_lake_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "firehose_s3_policy" {
  name        = "kinesis-firehose-s3-policy-${var.environment}"
  description = "Permisos de escritura para Firehose hacia el Data Lake"
  policy      = data.aws_iam_policy_document.firehose_s3_permissions.json
}

# 3. Attachment: Vincula la política con el rol
resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_s3_policy.arn
}
