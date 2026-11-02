data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

output "database_name" {
  description = "Nombre de la base de datos del catálogo Glue"
  value       = aws_glue_catalog_database.lakehouse.name
}

output "database_arn" {
  description = "ARN de la base de datos del catálogo Glue"
  value       = aws_glue_catalog_database.lakehouse.arn
}

output "catalog_arn" {
  description = "ARN del catálogo Glue"
  value       = "arn:${data.aws_partition.current.partition}:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog"
}

output "warehouse_location" {
  description = "Ubicación raíz S3 del warehouse de tablas Iceberg"
  value       = aws_glue_catalog_database.lakehouse.location_uri
}
