variable "project_name" {
  description = "Name of the project used for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., prod, mgmt, dev)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to spread subnets across"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster that will use this VPC (required for Karpenter/ELB tagging)"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway to save costs (set to false for High Availability)"
  type        = bool
  default     = true
}
