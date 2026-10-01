output "resource_prefix" {
  description = "Prefix for future AWS resources"
  value       = "${var.project_name}-${var.environment}"
}