#!/bin/bash

echo "🚀 Bootstrapping ArgoCD into the Hub Cluster..."

# 1. Create the namespace
kubectl create namespace argocd

# 2. Install ArgoCD via its raw manifest (The standard bootstrap method)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Wait for the pods to be ready
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo "✅ ArgoCD is alive. Transitioning to GitOps control."