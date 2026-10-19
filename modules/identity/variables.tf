variable "environment" {
  type        = string
  description = "Ambiente de despliegue (ej. dev, prod)"
}

variable "data_lake_bucket_arn" {
  type        = string
  description = "ARN del bucket S3 del Data Lake para otorgar permisos de escritura"
}

variable "data_lake_prefix" {
  type        = string
  description = "Prefijo dentro del bucket al que puede acceder el rol de procesamiento"
  default     = "raw/"

  validation {
    condition     = length(var.data_lake_prefix) > 0 && endswith(var.data_lake_prefix, "/")
    error_message = "data_lake_prefix debe ser una ruta no vacía terminada en /, por ejemplo raw/."
  }
}
