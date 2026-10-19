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

  validation {
    condition     = length(var.private_subnet_cidrs) == 2 && length(distinct(var.private_subnet_cidrs)) == 2
    error_message = "private_subnet_cidrs debe contener exactamente dos CIDRs distintos."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "Lista de Availability Zones (ej. us-east-2a, us-east-2b)"
  default     = ["us-east-2a", "us-east-2b"]

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "availability_zones debe contener exactamente dos zonas distintas."
  }
}

variable "aws_region" {
  type        = string
  description = "Región de AWS"
  default     = "us-east-2"
}
