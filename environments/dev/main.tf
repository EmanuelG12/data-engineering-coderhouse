# --- 1. Storage del Data Lake (Landing / Raw) ---
data "aws_caller_identity" "current" {}

locals {
  iceberg_table_location = "s3://${aws_s3_bucket.data_lake.id}/warehouse/${var.iceberg_table_name}/"
  iceberg_table_prefix   = "warehouse/${var.iceberg_table_name}/"
}

resource "aws_s3_bucket" "data_lake" {
  bucket        = "datalake-${data.aws_caller_identity.current.account_id}-${var.environment}-coder-data"
  force_destroy = false

  tags = {
    Name        = "datalake-raw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "security" {
  bucket                  = aws_s3_bucket.data_lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- 2. Invocación del Módulo de Red ---
module "network" {
  source = "../../modules/network"

  environment          = var.environment
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# --- 3. Invocación del Módulo de Identidad ---
module "identity" {
  source = "../../modules/identity"

  environment          = var.environment
  data_lake_bucket_arn = aws_s3_bucket.data_lake.arn
  data_lake_prefix     = "raw/"
}

module "kinesis" {
  source = "../../modules/kinesis"

  environment          = var.environment
  data_lake_bucket_arn = aws_s3_bucket.data_lake.arn
}

module "lakehouse" {
  source = "../../infra/lakehouse"

  database_name      = "lakehouse_db"
  environment        = var.environment
  aws_region         = var.aws_region
  warehouse_location = "s3://${aws_s3_bucket.data_lake.id}/warehouse/"
}

module "flink" {
  source = "../../modules/flink"

  environment                = var.environment
  aws_region                 = var.aws_region
  kinesis_stream_arn         = module.kinesis.stream_arn
  kinesis_kms_key_arn        = module.kinesis.stream_kms_key_arn
  data_lake_bucket_name      = aws_s3_bucket.data_lake.id
  data_lake_bucket_arn       = aws_s3_bucket.data_lake.arn
  application_jar_path       = var.flink_application_jar_path
  glue_catalog_arn           = module.lakehouse.catalog_arn
  glue_database_arn          = module.lakehouse.database_arn
  glue_database_name         = module.lakehouse.database_name
  iceberg_table_name         = var.iceberg_table_name
  iceberg_warehouse_location = module.lakehouse.warehouse_location
  iceberg_table_location     = local.iceberg_table_location
  iceberg_table_prefix       = local.iceberg_table_prefix

  depends_on = [
    aws_s3_bucket_versioning.data_lake,
    aws_s3_bucket_server_side_encryption_configuration.data_lake,
    module.lakehouse
  ]
}
