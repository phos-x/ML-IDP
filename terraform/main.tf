module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = "10.0.0.0/16"
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets      = ["10.0.10.0/24", "10.0.11.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true # Cost optimization for Dev/Management
}

module "iam_identity" {
  source = "./modules/iam_identity"
  
  github_repo_name = var.github_repo_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "${var.project_name}-hub"
  cluster_version = "1.31"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  # Enable EKS Pod Identity Agent
  enable_pod_identity = true

  # Security Best Practice: Encryption at Rest
  enable_kms_encryption = true

  # Networking: Cilium requires specific settings
  # We will install Cilium via Helm in Layer 2
}

# Karpenter NodePool IAM Roles (Provisioned here for Karpenter to use later)
module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  cluster_name = module.eks.cluster_name
  
  enable_pod_identity = true
  create_iam_role      = true
}
