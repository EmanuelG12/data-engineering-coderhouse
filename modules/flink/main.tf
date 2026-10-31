locals {
  application_name = "urban-sensors-${var.environment}"
  artifact_key     = "artifacts/flink/${var.environment}/urban-sensors-flink.jar"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_iam_policy_document" "flink_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:kinesisanalytics:${var.aws_region}:${data.aws_caller_identity.current.account_id}:application/${local.application_name}:*"
      ]
    }
  }
}

resource "aws_iam_role" "flink" {
  name               = "managed-flink-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.flink_trust.json

  tags = {
    Name        = "managed-flink-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "flink" {
  name              = "/aws/kinesis-analytics/${local.application_name}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_stream" "flink" {
  name           = "application"
  log_group_name = aws_cloudwatch_log_group.flink.name
}

data "aws_iam_policy_document" "flink_permissions" {
  statement {
    sid    = "ReadConfiguredKinesisStream"
    effect = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:DescribeStreamSummary",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:ListShards"
    ]
    resources = [var.kinesis_stream_arn]
  }

  statement {
    sid       = "DecryptKinesisRecords"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [var.kinesis_kms_key_arn]
  }

  statement {
    sid    = "ReadApplicationArtifact"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [aws_s3_object.flink_artifact.arn]
  }

  statement {
    sid    = "WriteApplicationLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.flink.arn}:*"]
  }
}

resource "aws_iam_role_policy" "flink" {
  name   = "managed-flink-${var.environment}"
  role   = aws_iam_role.flink.id
  policy = data.aws_iam_policy_document.flink_permissions.json
}

resource "aws_s3_object" "flink_artifact" {
  bucket                 = var.data_lake_bucket_name
  key                    = local.artifact_key
  source                 = var.application_jar_path
  etag                   = filemd5(var.application_jar_path)
  server_side_encryption = "AES256"
  content_type           = "application/java-archive"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_kinesisanalyticsv2_application" "flink" {
  name                   = local.application_name
  runtime_environment    = var.runtime_environment
  service_execution_role = aws_iam_role.flink.arn

  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn     = var.data_lake_bucket_arn
          file_key       = aws_s3_object.flink_artifact.key
          object_version = aws_s3_object.flink_artifact.version_id
        }
      }

      code_content_type = "ZIPFILE"
    }

    environment_properties {
      property_group {
        property_group_id = "FlinkApplicationProperties"

        property_map = {
          KINESIS_STREAM_ARN      = var.kinesis_stream_arn
          WINDOW_MINUTES          = tostring(var.window_minutes)
          WATERMARK_DELAY_SECONDS = tostring(var.watermark_delay_seconds)
        }
      }
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type            = "CUSTOM"
        checkpointing_enabled         = true
        checkpoint_interval           = var.checkpoint_interval_ms
        min_pause_between_checkpoints = var.min_pause_between_checkpoints_ms
      }

      monitoring_configuration {
        configuration_type = "CUSTOM"
        log_level          = "INFO"
        metrics_level      = "APPLICATION"
      }

      parallelism_configuration {
        configuration_type   = "CUSTOM"
        parallelism          = var.parallelism
        parallelism_per_kpu  = var.parallelism_per_kpu
        auto_scaling_enabled = false
      }
    }
  }

  tags = {
    Name        = local.application_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.flink.arn
  }

  depends_on = [aws_iam_role_policy.flink]
}
