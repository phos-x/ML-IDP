output "crossplane_role_arn" {
  description = "ARN for the Crossplane Pod Identity role"
  value       = aws_iam_role.crossplane.arn
}
