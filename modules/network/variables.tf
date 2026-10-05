variable "environment" {
  type        = string
  description = "Ambiente de despliegue (ej. dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Rango CIDR para la VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Lista con los CIDRs de las dos subredes privadas"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Lista de Availability Zones (ej. us-east-1a, us-east-1b)"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "aws_region" {
  type        = string
  description = "Región de AWS"
  default     = "us-east-1"
}
