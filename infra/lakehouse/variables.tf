variable "database_name" {
  type        = string
  description = "Nombre de la base de datos del catálogo Glue"
  default     = "lakehouse_db"
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue utilizado en las etiquetas de los recursos"
}

variable "aws_region" {
  type        = string
  description = "Región de AWS que contiene el catálogo Glue"
}

variable "warehouse_location" {
  type        = string
  description = "Ubicación raíz S3 del warehouse de tablas Iceberg"
}
