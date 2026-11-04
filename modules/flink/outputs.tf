output "application_name" {
  description = "Nombre de la aplicación Managed Service for Apache Flink"
  value       = aws_kinesisanalyticsv2_application.flink.name
}

output "application_arn" {
  description = "ARN de la aplicación Managed Service for Apache Flink"
  value       = aws_kinesisanalyticsv2_application.flink.arn
}

output "execution_role_arn" {
  description = "ARN del rol de ejecución limitado para Kinesis, KMS, S3 y CloudWatch"
  value       = aws_iam_role.flink.arn
}

output "artifact_s3_key" {
  description = "Clave S3 del JAR de la aplicación"
  value       = aws_s3_object.flink_artifact.key
}

output "cloudwatch_log_group_name" {
  description = "Grupo de CloudWatch Logs asociado a la aplicación"
  value       = aws_cloudwatch_log_group.flink.name
}
