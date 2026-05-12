Use Cases and Operational Best Practices
4.1 Use Case: Tenant Workspace Onboarding

    Anti-Pattern: A Platform Engineer manually creates an IAM role, a Kubernetes namespace, and runs a helm install command for the requesting team.

    Best Practice: The Data Scientist fills out the "New ML Workspace" template in Backstage. Backstage commits a declarative YAML skeleton (vcluster, Crossplane RDS, RBAC) to the tenants/ directory in the GitOps repo. ArgoCD detects the commit and provisions the complete, secure environment automatically.

4.2 Use Case: Upgrading Platform Tools (e.g., Cilium or ArgoCD)

    Anti-Pattern: Running helm upgrade via the CLI, or clicking buttons in the ArgoCD UI.

    Best Practice: Platform Engineers update the version field in the kustomization.yaml file located in kubernetes/platform/cilium/base/. A Pull Request is opened, CI validates the YAML, and upon merge, ArgoCD executes a rolling, zero-downtime update.

4.3 Use Case: Disaster Recovery (DR)

    Anti-Pattern: Trying to back up the entire EKS cluster state (etcd) to restore it in a new region.

    Best Practice: Treat the EKS cluster as completely ephemeral. In a DR scenario:

        Update the aws_region in the global-variables.yaml file.

        Trigger the Terraform CI pipeline to build a new EKS cluster in the backup region.

        Terraform installs ArgoCD and points it to the existing ApplicationSet.

        ArgoCD rebuilds the entire platform (Observability, Security, FinOps) and reconnects to the existing out-of-cluster Crossplane RDS instances. Recovery is achieved in under 20 minutes with zero manual intervention.

4.4 The "Zero-Touch" Philosophy

If a human needs to access the cluster via kubectl to fix a standard operational issue, the automation has failed.

    Secret Management: Never encode passwords in Git. Use Crossplane to generate credentials in AWS, and the Infisical Operator to inject them directly into pod memory.

    Git is the Source of Truth: Any configuration drift detected in the cluster (e.g., someone manually scaling a deployment) is immediately overwritten by ArgoCD's selfHeal mechanism.