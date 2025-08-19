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