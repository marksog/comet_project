# Comet Project

This project demonstrates how to deploy a simple "Hello, World!" application to Kubernetes using Infrastructure-as-Code tools like Terraform, Helm, and GitHub Actions.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Local Testing](#local-testing)
3. [Infrastructure Deployment](#infrastructure-deployment)
4. [Application Deployment](#application-deployment)
5. [Automated Deployment with GitHub Actions](#automated-deployment-with-github-actions)

---

## Prerequisites

Before you begin, ensure you have the following tools and permissions:

- **AWS Account**: With appropriate permissions to create EKS clusters, IAM roles, and other resources.
- **Terraform**: Installed locally (optional for manual deployment).
- **kubectl**: Installed and configured (after the cluster is created).
- **Helm**: Installed for managing Kubernetes resources.
- **Docker**: Installed for building and running container images.

---

## Local Testing

You can test the application locally before deploying it to Kubernetes.

### 1. Run Locally with Uvicorn
```bash
export PORT=8080
uvicorn main:app --reload --host 0.0.0.0 --port $PORT
```
## Infrastructure deployment

This can easily be done with github actions. 
or Can be runned from local machine with right credentials 

### manually
```bash
cd infra
terraform init
terraform plan
terraform apply -auto-approve
```
after deployment 
```bash
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region <your region>
```

deploying the application
```bash 
cd application
docker build -t <your-ecr-repo>:latest .
docker push <your-ecr-repo>:latest
```
deploy using helm
```bash
helm upgrade --install hello-world-app ./helm-chart \
  --set image.repository="<your-ecr-repo>" \
  --set image.tag="latest" \
  --namespace default \
  --create-namespace \
  --wait
  ```
  verify
```bash
kubectl get pods -n default
kubectl get svc -n default
# access application
# Use the external IP or DNS of the service:
kubectl get svc -n default
```


## Automated Deployment with GitHub Actions
Using help github actions will deploy the application to aws eks