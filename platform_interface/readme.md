The GitOps Paradigm Shift

To show true engineering mastery, we implement the "App of Apps" pattern.
Instead of telling ArgoCD to deploy 50 different tools, we tell ArgoCD to watch one folder (the bootstrap folder). Inside that folder are definitions that point to the rest of the platform.

Why this is brilliant: Notice source: InjectedIdentity. We are not passing AWS Access Keys or Secret YAMLs. Because we enabled the EKS Pod Identity Agent in Layer 1, Crossplane automatically assumes the IAM role we created for it, seamlessly and securely.
Summary of Layer 2 So Far

    ArgoCD is installed and monitoring your GitHub repository.

    Crossplane is installed via GitOps.

    Crossplane is securely authenticated to AWS using Zero-Secret Pod Identity, specifically loaded with the AWS S3 and SageMaker providers.

Your cluster is now a fully functional AWS provisioning engine.

Next Step:
We have two paths forward to complete the platform's capabilities before we install the Backstage UI:

    vcluster Setup: Define the ArgoCD application that installs the virtual cluster operator (so we can sandbox our Data Scientists).

    Crossplane Compositions: Write the custom K8s YAML that defines what a "SageMaker ML Workspace" actually looks like.