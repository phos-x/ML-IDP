# **Internal Developer Platform (IDP): The MLOps Hub**

This project is an implementation of a modern Internal Developer Platform. Its end goal is to provide a seamless "one-click" experience for ML Engineers to spin up ephemeral ML environments (using **SageMaker** and **Bedrock**) via **Backstage**, while the underlying infrastructure is managed by **Crossplane**, **vcluster**, and **ArgoCD**.

Currently, **Layer 1** is completed, which focuses on the secure, observable, and automated cloud foundation.

---

## **Architecture at a Glance**

We follow a **Hub-and-Spoke** model.

* **The Hub (Layer 1):** A hardened Amazon EKS cluster that hosts our platform's "brains" (ArgoCD, Crossplane, OTel).
* **The Interface (Layer 2):** Backstage and the GitOps machinery (Coming next).
* **The Spokes (Layer 3):** Isolated vclusters and AWS ML services provisioned dynamically for end-users.

---

## **Project Structure**

```text
.
mgmt_hub/
├── Docs
│   ├── compute.md
│   ├── identity.md    # OIDC, SPIFFE, and Workload Auth
│   ├── networking.md
│   └── orchestrator.md
├── kubernetes
│   └── bootstrap
├── scripts
│   ├── init-s3-backend.sh
└── terraform
    ├── control-plane/
    │   ├── backend.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   └── variables.tf
    └── modules
        ├── eks/
        ├── iam_identity/
        └── vpc/
```

---

## **Technical Documentation Index**

To understand the specifics of each sub-system, please refer to the files in the `/docs` folder:

* **[Networking & Connectivity](/mgmt_hub/Docs/compute.md)**
Details on the 3-Tier VPC, CIDR math, and the tagging strategy required for Karpenter and AWS Load Balancer discovery.
* **[Compute & Orchestration](/mgmt_hub/Docs/compute.md)**
Specifications for the EKS Cluster version 1.31+, KMS envelope encryption, and the "System" node group taints.
* **[Identity & Security](/mgmt_hub/Docs/identity.md)**
A guide to our "Zero-Secret" approach using GitHub OIDC and the new EKS Pod Identity Agent for workload auth.

---

## **The Layer 1 Tech Stack**

| Component | Technology | Standard |
| --- | --- | --- |
| **IaC** | Terraform | HashiCorp Standard |
| **State** | Amazon S3 | Native Conditional Locking (No DynamoDB) |
| **CI/CD** | GitHub Actions | OIDC Federated Identity |
| **Networking** | Cilium | eBPF-based L7 Security |
| **Compute** | Amazon EKS | K8s 1.31 / Graviton / Spot |
| **Observability** | OpenTelemetry | OTLP (MELT Standard) |

---

## **Getting Started**

1. **Identity Bootstrap:** Ensure your GitHub OIDC trust is established in AWS.
2. **State Initialization:** Run the `./scripts/init-s3-backend.sh` to create your encrypted state bucket.
3. **Provision:** Trigger the GitHub Action or run `terraform apply` from the root directory.

---
