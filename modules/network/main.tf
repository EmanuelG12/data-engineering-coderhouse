# 1. VPC Base
resource "aws_vpc" "data_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "vpc-data-${var.environment}"
    Environment = var.environment
  }
}

# 2. Dos Subredes Privadas (una por cada AZ)
resource "aws_subnet" "private_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.data_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "subnet-data-private-${count.index + 1}-${var.environment}"
    Environment = var.environment
  }
}

# 3. Tabla de ruteo privada
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.data_vpc.id

  tags = {
    Name        = "rt-data-private-${var.environment}"
    Environment = var.environment
  }
}

# 4. Asociación de las subredes a la tabla de ruteo
resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# 5. S3 Gateway Endpoint asociado a la tabla de ruteo
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.data_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_rt.id]

  tags = {
    Name        = "vpce-s3-gateway-${var.environment}"
    Environment = var.environment
  }
}
