output "stream_name" {
  description = "Nombre del Kinesis Data Stream de ingesta"
  value       = aws_kinesis_stream.ingestion.name
}

output "stream_arn" {
  description = "ARN del Kinesis Data Stream de ingesta"
  value       = aws_kinesis_stream.ingestion.arn
}

output "stream_kms_key_arn" {
  description = "ARN de la clave KMS utilizada para cifrar el stream"
  value       = data.aws_kms_key.kinesis.arn
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