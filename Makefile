AWS_REGION ?= us-east-1
NAMESPACE  ?= default-app
RELEASE    ?= hello-world-app
CLUSTER    ?= comet-hello-app

.PHONY: apply destroy smoke kubeconfig

apply:
    cd infra && terraform init -input=false && terraform apply -auto-approve

destroy:
    -helm uninstall $(RELEASE) -n $(NAMESPACE) || true
    cd infra && terraform destroy -auto-approve

kubeconfig:
    aws eks update-kubeconfig --region $(AWS_REGION) --name $(CLUSTER)

smoke: kubeconfig
    @SVC=$(RELEASE); \
    HOST=$$(kubectl get svc $$SVC -n $(NAMESPACE) -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'); \
    if [ -z "$$HOST" ]; then echo "Service hostname not ready"; exit 1; fi; \
    echo "Endpoint: http://$$HOST"; \
    for i in $$(seq 1 24); do \
      if curl -fsS "http://$$HOST/health" >/dev/null 2>&1; then echo "Smoke OK"; exit 0; fi; \
      sleep 5; \
    done; \
    echo "Smoke failed"; exit 1