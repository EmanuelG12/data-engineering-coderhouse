resource "aws_kinesis_stream" "ingestion" {
  name             = "data-ingestion-${var.environment}"
  shard_count      = var.shard_count
  retention_period = 24

  encryption_type = "KMS"
  kms_key_id      = "alias/aws/kinesis"

  tags = {
    Name        = "data-ingestion-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_kms_key" "kinesis" {
  key_id = aws_kinesis_stream.ingestion.kms_key_id
}

data "aws_iam_policy_document" "firehose_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose" {
  name               = "firehose-delivery-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.firehose_trust.json

  tags = {
    Name        = "firehose-delivery-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesisfirehose/data-ingestion-${var.environment}"
  retention_in_days = 1

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

data "aws_iam_policy_document" "firehose_permissions" {
  statement {
    sid    = "ReadKinesisStream"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:ListShards"
    ]
    resources = [aws_kinesis_stream.ingestion.arn]
  }

  statement {
    sid       = "DecryptKinesisRecords"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [data.aws_kms_key.kinesis.arn]
  }

  statement {
    sid    = "WriteToDataLakePrefix"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${var.data_lake_bucket_arn}/${var.data_lake_prefix}*"]
  }

  statement {
    sid       = "GetDataLakeBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [var.data_lake_bucket_arn]
  }

  statement {
    sid       = "ListDataLakeBucketPrefix"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:ListBucketMultipartUploads"]
    resources = [var.data_lake_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.data_lake_prefix}*"]
    }
  }

  statement {
    sid    = "WriteDeliveryLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.firehose.arn}:*"]
  }
}

resource "aws_iam_role_policy" "firehose" {
  name   = "firehose-delivery-${var.environment}"
  role   = aws_iam_role.firehose.id
  policy = data.aws_iam_policy_document.firehose_permissions.json
}

resource "aws_kinesis_firehose_delivery_stream" "s3" {
  name        = "data-ingestion-${var.environment}-to-s3"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.ingestion.arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose.arn
    bucket_arn         = var.data_lake_bucket_arn
    prefix             = var.data_lake_prefix
    buffering_size     = 5
    buffering_interval = 60

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose.name
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_iam_role_policy.firehose]
}
