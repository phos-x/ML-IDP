terraform {
  backend "s3" {
    bucket         = "tf-state-${var.project_name}-${var.aws_region}"
    key            = "infrastructure/layer1-hub/terraform.tfstate"
    region         = var.aws_region
    use_lockfile   = true
    encrypt        = true
  }
}
