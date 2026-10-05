output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.data_vpc.id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas creadas"
  value       = aws_subnet.private_subnets[*].id
}

output "s3_endpoint_id" {
  description = "ID del VPC Endpoint Gateway hacia S3"
  value       = aws_vpc_endpoint.s3_gateway.id
}
