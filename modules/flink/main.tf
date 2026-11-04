locals {
  application_name = "urban-sensors-${var.environment}"
  artifact_key     = "artifacts/flink/${var.environment}/urban-sensors-flink.jar"
  glue_table_arn   = "${replace(var.glue_database_arn, ":database/", ":table/")}/${var.iceberg_table_name}"
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
    sid    = "UseGlueLakehouseCatalog"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:CreateTable",
      "glue:UpdateTable"
    ]
    resources = [
      var.glue_catalog_arn,
      var.glue_database_arn,
      local.glue_table_arn
    ]
  }

  statement {
    sid    = "ReadWriteIcebergWarehouse"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject"
    ]
    resources = ["${var.data_lake_bucket_arn}/${var.iceberg_table_prefix}*"]
  }

  statement {
    sid    = "ListIcebergWarehouse"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [var.data_lake_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.iceberg_table_prefix}*"]
    }
  }

  statement {
    sid       = "GetLakehouseBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [var.data_lake_bucket_arn]
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
          AWS_REGION                 = var.aws_region
          GLUE_DATABASE_NAME         = var.glue_database_name
          ICEBERG_TABLE_NAME         = var.iceberg_table_name
          ICEBERG_TABLE_LOCATION     = var.iceberg_table_location
          ICEBERG_WAREHOUSE_LOCATION = var.iceberg_warehouse_location
          KINESIS_STREAM_ARN         = var.kinesis_stream_arn
          WINDOW_MINUTES             = tostring(var.window_minutes)
          WATERMARK_DELAY_SECONDS    = tostring(var.watermark_delay_seconds)
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
