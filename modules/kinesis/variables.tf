variable "environment" {
  type        = string
  description = "Entorno donde se despliega el stream, por ejemplo dev."
}

variable "data_lake_bucket_arn" {
  type        = string
  description = "ARN del bucket S3 que recibirá los archivos de Firehose."
}

variable "data_lake_prefix" {
  type        = string
  description = "Prefijo de S3 para los archivos de Kinesis."
  default     = "raw/kinesis/"

  validation {
    condition     = length(var.data_lake_prefix) > 0 && endswith(var.data_lake_prefix, "/")
    error_message = "El prefijo debe ser una ruta no vacía terminada en /, por ejemplo raw/kinesis/."
  }
}

variable "shard_count" {
  type        = number
  description = "Cantidad de shards aprovisionados para el Kinesis Data Stream."
  default     = 2

  validation {
    condition     = var.shard_count >= 2 && floor(var.shard_count) == var.shard_count
    error_message = "El stream debe tener al menos 2 shards y el valor debe ser entero."
  }
}