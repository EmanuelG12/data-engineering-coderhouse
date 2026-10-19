terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-datalake-dev-coder"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
    # Mantener esta configuración alineada con el bootstrap documentado en README.md.
  }
}

provider "aws" {
  region = var.aws_region
}
