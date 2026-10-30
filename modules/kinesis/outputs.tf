output "stream_name" {
  description = "Nombre del Kinesis Data Stream de ingesta"
  value       = aws_kinesis_stream.ingestion.name
}

output "stream_arn" {
  description = "ARN del Kinesis Data Stream de ingesta"
  value       = aws_kinesis_stream.ingestion.arn
}

output "firehose_name" {
  description = "Nombre del delivery stream de Firehose"
  value       = aws_kinesis_firehose_delivery_stream.s3.name
}

output "firehose_arn" {
  description = "ARN del delivery stream de Firehose"
  value       = aws_kinesis_firehose_delivery_stream.s3.arn
}

output "firehose_role_arn" {
  description = "ARN del rol de ejecución de Firehose"
  value       = aws_iam_role.firehose.arn
}