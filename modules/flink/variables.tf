variable "environment" {
  type        = string
  description = "Nombre del entorno que identifica los recursos de Flink"
}

variable "aws_region" {
  type        = string
  description = "Región AWS donde existen el stream y la aplicación Flink"
}

variable "kinesis_stream_arn" {
  type        = string
  description = "ARN del Kinesis Data Stream que consumirá la aplicación"
}

variable "kinesis_kms_key_arn" {
  type        = string
  description = "ARN de la clave KMS que cifra el Kinesis Data Stream"
}

variable "data_lake_bucket_name" {
  type        = string
  description = "Nombre del bucket S3 donde se publica el JAR de la aplicación"
}

variable "data_lake_bucket_arn" {
  type        = string
  description = "ARN del bucket S3 que contiene el artefacto de Flink"
}

variable "application_jar_path" {
  type        = string
  description = "Ruta local al JAR sombreado, relativa al directorio de trabajo de Terraform"
}

variable "runtime_environment" {
  type        = string
  description = "Runtime administrado de Apache Flink compatible con el artefacto"
  default     = "FLINK-1_19"
}

variable "window_minutes" {
  type        = number
  description = "Duración de la ventana tumbling de tiempo de evento, en minutos"
  default     = 1

  validation {
    condition     = var.window_minutes >= 1 && floor(var.window_minutes) == var.window_minutes
    error_message = "window_minutes debe ser un entero positivo."
  }
}

variable "watermark_delay_seconds" {
  type        = number
  description = "Desorden de eventos tolerado por la estrategia de watermark"
  default     = 30

  validation {
    condition     = var.watermark_delay_seconds >= 0 && floor(var.watermark_delay_seconds) == var.watermark_delay_seconds
    error_message = "watermark_delay_seconds debe ser un entero no negativo."
  }
}

variable "checkpoint_interval_ms" {
  type        = number
  description = "Intervalo entre checkpoints administrados por Managed Flink"
  default     = 60000
}

variable "min_pause_between_checkpoints_ms" {
  type        = number
  description = "Pausa mínima entre checkpoints, en milisegundos"
  default     = 5000
}

variable "parallelism" {
  type        = number
  description = "Paralelismo de la aplicación Flink"
  default     = 1

  validation {
    condition     = var.parallelism >= 1 && floor(var.parallelism) == var.parallelism
    error_message = "parallelism debe ser un entero positivo."
  }
}

variable "parallelism_per_kpu" {
  type        = number
  description = "Número de unidades de paralelismo por KPU"
  default     = 1

  validation {
    condition     = var.parallelism_per_kpu >= 1 && floor(var.parallelism_per_kpu) == var.parallelism_per_kpu
    error_message = "parallelism_per_kpu debe ser un entero positivo."
  }
}
