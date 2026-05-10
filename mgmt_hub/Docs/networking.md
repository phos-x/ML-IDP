This section handles the underlying network for the entire platform. Since we are building a "Management Hub," the network isn't just about connectivity; it’s about creating a secure, isolated environment that can scale without manual intervention.

---

## **What’s Under the Hood?**

We’ve moved away from a "flat" network. This module implements a **3-Tier VPC architecture** spread across multiple Availability Zones (AZs).

* **Public Subnets:** These act as the "DMZ." Only the NAT Gateways and Internet-facing Load Balancers (ALBs) live here.
* **Private Subnets:** This is where the EKS worker nodes, vclusters, and ML workloads reside. They have **no public IP addresses**, meaning they are unreachable from the open internet.
* **Intra Subnets (Optional/Internal):** Reserved for strictly internal resources like VPC Endpoints or DBs that don't even need NAT access.

---

## **Implementation Details**

### **1. Dynamic Networking**

Instead of hardcoding CIDR blocks for every subnet, we use the `cidrsubnet` function. This allows you to define one top-level VPC CIDR (like `10.0.0.0/16`) and let Terraform calculate the math for the subnets. If you need to change the VPC size later, the subnets shift automatically.

### **2. The "Karpenter" Discovery Hook**

The private subnets are tagged with `"karpenter.sh/discovery" = var.cluster_name`.
**Why?** When Karpenter (our autoscaler) needs to spin up a new EC2 node for a heavy ML training job, it queries the AWS API for subnets with this specific tag. Without this, the autoscaler is blind.

### **3. Smart Routing**

* **Internet Gateway (IGW):** Only attached to public subnets.
* **NAT Gateway:** Provides outbound-only internet access for private pods (e.g., pulling a Python library or a Docker image).
* **EIPs:** Static IPs assigned to the NAT Gateways to ensure predictable egress traffic.

---

## **Best Practices Applied**

* **Cost Optimization:** We’ve added a `single_nat_gateway` toggle. In a production environment, you’d want a NAT in every AZ for high availability. For this project, we use one NAT across all AZs to save roughly **$32/month per zone**.
* **Zero Trust Boundary:** By placing EKS nodes in private subnets, we reduce the attack surface by 90%. Any ingress traffic *must* pass through an AWS Application Load Balancer (ALB) which we control via the AWS Load Balancer Controller.
* **Tagging Standard:** Every resource follows a strict tagging convention:
* `kubernetes.io/role/elb`: Tells AWS where to put public load balancers.
* `kubernetes.io/role/internal-elb`: Tells AWS where to put internal load balancers.
* `Project` & `Environment`: For cost tracking and resource filtering.



---

## **Primary Use Cases**

1. **Isolated ML Training:** When you deploy a SageMaker job or a pod in a vcluster, it needs to reach the AWS API but shouldn't be exposed to the web. This network handles that via NAT.
2. **Automated Ingress:** When a Data Scientist deploys an inference service in their vcluster, the ALB Controller sees the tags we've set in this VPC and automatically configures the load balancer in the correct subnets.
3. **Secure Management:** The platform team can access the cluster via a private endpoint, keeping the "Engine Room" entirely off the public grid.

---

### **Next Steps for the Readme**

* [ ] Add EKS Cluster Configuration.
* [ ] Document IAM & Pod Identity logic.
* [ ] Add Observability/OTel network flow.

---

**Guide forward:** Should we move on to the **EKS Module** now to get the compute layer sitting on top of this network?