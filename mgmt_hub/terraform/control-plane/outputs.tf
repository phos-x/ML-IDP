output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "crossplane_role_arn" {
  value = module.iam_identity.crossplane_role_arn
}

output "karpenter_instance_profile_name" {
  value = module.karpenter.instance_profile_name
}
