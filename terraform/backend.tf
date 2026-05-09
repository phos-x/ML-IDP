terraform {
  backend "s3" {
    bucket         = "tf-state-${var.project_name}-${var.aws_region}"
    key            = "infrastructure/layer1-hub/terraform.tfstate"
    region         = "us-east-1"
    # 2026 Industry Standard: S3 Native Conditional Writes for locking
    use_lockfile   = true
    encrypt        = true
  }
}
