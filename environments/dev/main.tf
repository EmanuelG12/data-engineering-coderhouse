# --- 1. Storage del Data Lake (Landing / Raw) ---
data "aws_caller_identity" "current" {}

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
