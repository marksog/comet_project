# comet_project

Testing the app Locally


on local terminal
export PORT=8080
uvicorn main:app --reload --host 0.0.0.0 --port 8080

Docker locak image
# build image
docker build -t fastapi-hello:local .

# run image
docker run -d -p 8080:8080 --name fastapi-hello fastapi-hello:local


Deploying the infrastructure

## Terraform - aws eks

usage (local)
```bash
cd infra
terraform init
terraform plan
terraform apply -auto-approve
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region 
```

push code to github

Deploy github actions will deploy infrastructure and application.

# Hello World Kubernetes Deployment

This project demonstrates how to deploy a simple "Hello, World!" application to Kubernetes using Infrastructure-as-Code tools.

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed locally (optional)
- kubectl configured (after cluster creation)
- Helm installed (for local deployment)

## Deployment Steps

### 1. Infrastructure Setup

The Kubernetes cluster will be automatically created when you push changes to the `infrastructure/` directory. 

Alternatively, to deploy manually:

1. Navigate to the `infrastructure/` directory
2. Run `terraform init` to initialize Terraform
3. Run `terraform plan` to review changes
4. Run `terraform apply` to create the cluster

### 2. Application Deployment

The application will be automatically built and deployed when you push changes to the `application/` directory.

To deploy manually:

1. Build and push the Docker image:
   ```bash
   cd application
   docker build -t hello-world .