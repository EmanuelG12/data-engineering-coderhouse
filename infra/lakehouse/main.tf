resource "aws_glue_catalog_database" "lakehouse" {
  name         = var.database_name
  description  = "Glue Data Catalog database for the urban sensor Iceberg lakehouse"
  location_uri = var.warehouse_location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
