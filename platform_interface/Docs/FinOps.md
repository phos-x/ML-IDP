FinOps (Cloud Cost Management)

In a dynamically scaling ML environment, untracked GPU and storage usage can destroy budgets. We embed FinOps directly into the GitOps pipeline using OpenCost to provide real-time, unit-level economics.
2.1 The Tagging Taxonomy

Cost attribution is impossible without strict tagging. Every resource deployed on this platform (vcluster pods, Crossplane RDS instances, S3 buckets) must include these labels:

    platform.tech/team: The specific engineering squad (e.g., fraud-detection).

    platform.tech/project: The specific ML model or initiative.

    platform.tech/cost-center: The finance department billing code (e.g., AI-RND-100).

2.2 The OpenCost Engine

OpenCost runs on the Hub's system nodes. It actively polls the AWS Billing API for spot and on-demand pricing and cross-references it with our Thanos metrics.

    In-Cluster Costs: OpenCost calculates the exact micro-cents per hour a tenant's vcluster is burning based on CPU, RAM, and GPU requests.

    Out-of-Cluster Costs: Because Crossplane tags AWS RDS and S3 resources with the exact same cost-center labels, OpenCost aggregates the EKS compute cost and the AWS managed service cost into a single "Total Cost of Ownership" dashboard per ML team.