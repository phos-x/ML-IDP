terraform {
  backend "s3" {
    bucket         = "tf-state-ml-platform-eu-west-2"
    key            = "infrastructure/layer1-hub/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}
