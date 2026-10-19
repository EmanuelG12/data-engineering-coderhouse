output "data_processing_role_arn" {
  description = "ARN del rol IAM de ejecución para Lambda o Managed Service for Apache Flink"
  value       = aws_iam_role.data_processing.arn
}

output "data_processing_role_name" {
  description = "Nombre del rol IAM de procesamiento"
  value       = aws_iam_role.data_processing.name
}

output "control_plane_audit_role_arn" {
  description = "ARN del rol IAM de solo lectura para auditoría del plano de control"
  value       = aws_iam_role.control_plane_audit.arn
}

output "control_plane_audit_role_name" {
  description = "Nombre del rol IAM de auditoría"
  value       = aws_iam_role.control_plane_audit.name
}
