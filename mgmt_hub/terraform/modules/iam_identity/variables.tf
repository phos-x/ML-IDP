variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "github_org" {
  description = "The GitHub Organization or Username"
  type        = string
}

variable "github_repo" {
  description = "The GitHub Repository name"
  type        = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "account_id" {
  type    = string
  sensitive   = true
}

