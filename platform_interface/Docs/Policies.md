Policies (Security & Governance)

To support self-service without compromising security, we utilize a "Defense in Depth" strategy for Policy as Code (PaC). We use two layers of enforcement: Kyverno (for complex mutations) and Native Validating Admission Policies (VAP) (as the fail-safe).
3.1 Layer 1: Validating Admission Policies (VAP)

VAP evaluates policies using Common Expression Language (CEL) directly inside the Kubernetes kube-apiserver. This is our unbreakable baseline; it works even if external webhooks fail.

Core VAP Rules Enforced:

    Mandatory FinOps Labels: Any Pod or Crossplane resource submitted without the platform.tech/cost-center label is immediately rejected by the API server.

    Resource Limits: Every container must declare explicit CPU and Memory requests and limits to prevent "noisy neighbor" ML training jobs from crashing EKS nodes.

    Privilege Escalation: Containers requesting privileged: true or root access are strictly blocked.

3.2 Layer 2: Kyverno (Mutation & Auditing)

While VAP blocks bad behavior, Kyverno fixes it or audits complex states.

    Automated Label Injection: If a Data Scientist forgets to add a team label to a specific pod inside their vcluster, Kyverno intercepts the request on the Hub and automatically injects the label based on the namespace name.

    Audit Mode for Rollouts: New, restrictive policies are always deployed in validationFailureAction: Audit mode first. This allows Platform Engineers to generate Policy Reports and warn offenders before flipping the switch to Enforce.