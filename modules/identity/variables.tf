variable "environment" {
  type        = string
  description = "Ambiente de despliegue (ej. dev, prod)"
}

variable "data_lake_bucket_arn" {
  type        = string
  description = "ARN del bucket S3 del Data Lake para otorgar permisos de escritura"
}
