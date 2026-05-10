variable "aws_region" {
  type    = string
  default = "us-east-1"
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
  default = ["us-east-1a", "us-east-1b"]
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "github_org" {
  type        = string
  description = "GitHub Org/User for OIDC trust"
}

variable "github_repo" {
  type        = string
  description = "GitHub Repo name for OIDC trust"
}
