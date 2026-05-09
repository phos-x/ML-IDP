variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "platform-hub"
}

variable "github_repo_name" {
  description = "Format: org/repo-name"
  type        = string
}
