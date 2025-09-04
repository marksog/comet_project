# Comet Project

Pipeline overview
- Builds and pushes Docker image to ECR.
- Provisions infra (VPC, EKS, ECR, addons) via Terraform.
- Installs the app Helm chart.
- Exposes a public endpoint with a Service of type LoadBalancer.
- Runs a smoke test to /health.

DNS/exposure and ports
- Exposure: Kubernetes Service type LoadBalancer (classic/NLB). You will see an AWS DNS hostname (EXTERNAL-IP) on the Service.
- Ports:
  - containerPort: 8080 (the app listens here)
  - Service: port 80 -> targetPort 8080 (HTTP)
- Ingress: Not used by default. If you prefer ALB Ingress, install AWS Load Balancer Controller and switch the chart to Ingress.

Required GitHub secrets
- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY: IAM user/role with permissions for ECR, EKS, EC2, IAM, etc.
- ECR_REPOSITORY: The ECR repo name (must match infra variable `ecr_repo_name`).
- CLUSTER_NAME: The EKS cluster name (must match infra variable `cluster_name`).

Setup GitHub Secrets
- Go to your repo → Settings → Secrets and variables → Actions → New repository secret.

How to run end-to-end (CI)
- Push to main or run the “Build, Test, and Deploy” workflow via Actions.
- The workflow will apply Terraform, build/push image, deploy, and print the endpoint, then smoke test /health.

How to rerun fialed jobs
- Go to GitHub Actions → select the run → Rerun jobs → “Rerun failed jobs”.

How to tear down the setup
- from your local machine. 
```bash
brew install gh
gh auth login

# By workflow name
gh workflow run "Cleanup: Helm uninstall and Terraform destroy" -f confirm=DESTROY

# Or by file on a branch
gh workflow run destroy.yml --ref main -f confirm=DESTROY
```

How to run locally (Mac)
- Provision infra: `make apply`
- Update kubeconfig: `aws eks update-kubeconfig --region us-east-1 --name <cluster_name>`
- Deploy via CI or manually with Helm (values already default to LoadBalancer).
- Smoke test: `make smoke`

Rerun failed jobs
- Go to GitHub Actions → select the run → Rerun jobs → “Rerun failed jobs”.

Teardown
- Preferred: Run the “Cleanup: Helm uninstall and Terraform destroy” workflow and type DESTROY.
- Locally: `make destroy`
  - If IGW detaches fail due to ELB, ensure no Services of type LoadBalancer remain: `kubectl get svc -A | grep LoadBalancer` and delete them, then destroy again.

Notes
- Redis persistence is disabled by default to avoid PVC binding issues on clusters without a default StorageClass. If you enable it later, ensure the EBS CSI add-on and a default gp3 StorageClass exist.