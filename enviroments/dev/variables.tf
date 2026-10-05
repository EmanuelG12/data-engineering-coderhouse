variable "aws_region" {
  type        = string
  description = "Región de AWS para el despliegue"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Nombre del entorno"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "Rango CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs de las subredes privadas"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b"]
}
