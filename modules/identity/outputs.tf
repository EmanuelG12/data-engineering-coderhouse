output "firehose_role_arn" {
  description = "ARN del rol IAM para Kinesis Firehose"
  value       = aws_iam_role.firehose_role.arn
}

output "firehose_role_name" {
  description = "Nombre del rol IAM creado"
  value       = aws_iam_role.firehose_role.name
}
