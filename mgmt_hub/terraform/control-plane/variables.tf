variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "github_token" {
  description = "GitHub Personal Access Token used by ArgoCD to read the private platform repository"
  type        = string
  sensitive   = true
}

variable "account_id" {
  description = "account id value"
  type        = string
  sensitive   = true
}

variable "project_name" {
  type    = string
  default = "ml-platform"
}

variable "environment" {
  type    = string
  default = "mgmt"
}

variable "cluster_name" {
  type    = string
  default = "hub-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "github_org" {
  type        = string
  description = "GitHub Org/User for OIDC trust"
  default = "ade"
}

variable "github_repo" {
  type        = string
  description = "GitHub Repo name for OIDC trust"
}
