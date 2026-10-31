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

output "data_processing_role_arn" {
  description = "ARN del rol IAM de ejecución para Lambda o Flink"
  value       = module.identity.data_processing_role_arn
}

output "control_plane_audit_role_arn" {
  description = "ARN del rol de solo lectura para auditoría"
  value       = module.identity.control_plane_audit_role_arn
}

output "kinesis_stream_name" {
  description = "Nombre del Kinesis Data Stream de ingesta"
  value       = module.kinesis.stream_name
}

output "kinesis_stream_arn" {
  description = "ARN del Kinesis Data Stream de ingesta"
  value       = module.kinesis.stream_arn
}

output "firehose_delivery_stream_name" {
  description = "Nombre del delivery stream de Firehose"
  value       = module.kinesis.firehose_name
}

output "firehose_delivery_stream_arn" {
  description = "ARN del delivery stream de Firehose"
  value       = module.kinesis.firehose_arn
}

output "firehose_role_arn" {
  description = "ARN del rol de ejecución de Firehose"
  value       = module.kinesis.firehose_role_arn
}

output "flink_application_name" {
  description = "Nombre de la aplicación Managed Service for Apache Flink"
  value       = module.flink.application_name
}

output "flink_application_arn" {
  description = "ARN de la aplicación Managed Service for Apache Flink"
  value       = module.flink.application_arn
}

output "flink_execution_role_arn" {
  description = "ARN del rol de ejecución de Managed Flink"
  value       = module.flink.execution_role_arn
}

output "flink_artifact_s3_key" {
  description = "Clave S3 del JAR sombreado de Flink"
  value       = module.flink.artifact_s3_key
}

output "flink_cloudwatch_log_group_name" {
  description = "Grupo de CloudWatch Logs de la aplicación Flink"
  value       = module.flink.cloudwatch_log_group_name
}
