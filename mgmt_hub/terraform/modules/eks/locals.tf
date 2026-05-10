locals {
  name = "${var.project_name}-${var.environment}-hub"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
