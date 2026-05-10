output "github_actions_role_arn" {
  description = "ARN for the GitHub Actions OIDC role"
  value       = aws_iam_role.github_actions.arn
}

output "crossplane_role_arn" {
  description = "ARN for the Crossplane Pod Identity role"
  value       = aws_iam_role.crossplane.arn
}
