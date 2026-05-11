provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}


# This allows ArgoCD to read your private GitOps repository
resource "kubernetes_secret" "github_creds" {
  metadata {
    name      = "github-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.github_repo_url
    password = var.github_token # Passed from GitHub Action Secret
    username = "platform-bot"
  }

  depends_on = [helm_release.argocd]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "9.5.13"

  values = [
    yamlencode({
      global = {
        nodeSelector = { "platform-role" = "system" }
        tolerations  = [{
          key      = "CriticalAddonsOnly"
          operator = "Equal"
          value    = "true"
          effect   = "NoSchedule"
        }]
      }
      # Optimization: Reduce server footprint as requested
      controller = { replicas = 1 }
      repoServer = { replicas = 1 }
      server     = { replicas = 1 }
      redis      = { architecture = "standalone" }
    })
  ]
}

resource "kubectl_manifest" "platform_bootstrap" {
  yaml_body = file("${path.module}/../platform_interface/kubernetes/bootstrap/platform-applicationset.yaml")

  depends_on = [helm_release.argocd, kubernetes_secret.github_creds]
}