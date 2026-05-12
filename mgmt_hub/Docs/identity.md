To achieve a "Zero-Secret" architecture, the IAM Identity module is the most critical security component. In this module, we handle two distinct types of identity: External Identity (allowing GitHub Actions to manage AWS) and Workload Identity (allowing Kubernetes pods to manage AWS).

By using OIDC and EKS Pod Identity, we ensure that not a single AWS Access Key is ever generated, stored, or rotated.

Engineering Details & Mastery Points

    Workload Identity Federation (OIDC): We are establishing a cryptographic trust between GitHub and AWS. By checking the sub (subject) claim in the trust policy, we ensure that only your specific repository can assume this role. This is the gold standard for CI/CD security.

    Pod Identity Trust Policy: Notice the Principal for the Crossplane role is pods.eks.amazonaws.com. This is the new 2026 standard. It’s cleaner than the old OIDC/IRSA method because it supports sts:TagSession, allowing for much better auditing of which specific pod performed an action in AWS.

    Scoped Permissions: For the Crossplane role, we aren't just slapping AdministratorAccess on it. We are scoping it to SageMaker, S3, and Bedrock. This limits the "blast radius"—if Crossplane were ever compromised, the attacker couldn't delete your entire AWS Organization or VPC.

    No Secrets: There is literally no aws_iam_access_key resource in this code. We are purely using temporary, short-lived tokens.

Updated README for the IAM Identity Section

Add this to your documentation:
Identity Layer: Zero-Secret Auth

This module manages how the outside world (GitHub) and the inside world (Kubernetes Pods) talk to AWS securely.
GitHub OIDC (External Identity)

We use OpenID Connect (OIDC) to eliminate the need for long-lived IAM user keys in GitHub Secrets.

    How it works: GitHub provides a temporary JWT (JSON Web Token) to AWS. AWS verifies this token against GitHub's public keys and checks that it originated from the correct repository branch. If everything matches, AWS grants a short-lived IAM session.

EKS Pod Identity (Workload Identity)

For our internal platform tools like Crossplane and the OpenTelemetry collector, we use the EKS Pod Identity Agent.

    The Benefit: We don't have to manage complex OIDC provider strings or annotate Kubernetes ServiceAccounts with long ARNs. We define an IAM role with a trust relationship for the EKS Pod Identity service, and the agent handles the token injection into the pods automatically.

Security Controls

    Least Privilege: Roles are scoped strictly to their function (e.g., Crossplane only sees the services it needs to provision for ML).

    Session Tagging: We enable session tagging so that every AWS API call made by a pod can be traced back to the specific Kubernetes metadata that triggered it.

