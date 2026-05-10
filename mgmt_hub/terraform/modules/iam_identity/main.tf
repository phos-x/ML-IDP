# --- 1. GitHub OIDC Provider ---
# This allows AWS to trust tokens issued by GitHub Actions

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# --- 2. GitHub Actions CI/CD Role ---
# The role assumed by your pipeline to deploy Layer 1

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub": "repo:${var.github_org}/${var.github_repo}:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Administrative policy for the Platform CI/CD
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" 
}

# --- 3. Crossplane Management Role ---
# Used by Crossplane in Layer 2 to provision SageMaker/S3/Bedrock
# This uses the new EKS Pod Identity trust relationship

resource "aws_iam_role" "crossplane" {
  name = "${var.project_name}-${var.environment}-crossplane-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "pods.eks.amazonaws.com"
        },
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

# Scoped policy for Crossplane (Mastery: Don't give it Admin)
resource "aws_iam_policy" "crossplane_provider_aws" {
  name        = "${var.project_name}-${var.environment}-crossplane-policy"
  description = "Permissions for Crossplane to manage ML resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sagemaker:*",
          "s3:*",
          "bedrock:*",
          "iam:PassRole"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crossplane_attach" {
  role       = aws_iam_role.crossplane.name
  policy_arn = aws_iam_policy.crossplane_provider_aws.arn
}
