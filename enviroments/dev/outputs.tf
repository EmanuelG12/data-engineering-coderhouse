output "vpc_id" {
  description = "ID de la VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas de procesamiento"
  value       = module.network.private_subnet_ids
}

output "s3_endpoint_id" {
  description = "ID del Gateway Endpoint hacia S3"
  value       = module.network.s3_endpoint_id
}

output "data_lake_bucket_arn" {
  description = "ARN del bucket S3 del Data Lake"
  value       = aws_s3_bucket.data_lake.arn
}

output "firehose_role_arn" {
  description = "ARN del rol IAM para Kinesis Firehose"
  value       = module.identity.firehose_role_arn
}
