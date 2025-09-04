AWS_REGION ?= us-east-1
NAMESPACE  ?= default-app
RELEASE    ?= hello-world-app
CLUSTER    ?= comet-hello-app
IMAGE_REPO ?= 923214554566.dkr.ecr.us-east-1.amazonaws.com/hello-world-app
IMAGE_TAG  ?= latest

.PHONY: apply destroy smoke kubeconfig deploy

apply:
	cd infra && terraform init -input=false && terraform apply -auto-approve

destroy:
	-helm uninstall $(RELEASE) -n $(NAMESPACE) || true
	cd infra && terraform destroy -auto-approve

kubeconfig:
	aws eks update-kubeconfig --region $(AWS_REGION) --name $(CLUSTER)

deploy: kubeconfig
	helm dependency update charts/hello
	helm upgrade --install $(RELEASE) charts/hello \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--set image.repository="$(IMAGE_REPO)" \
		--set image.tag="$(IMAGE_TAG)" \
		--set container.port=8080 \
		--set redis.master.persistence.enabled=false \
		--set redis.replica.persistence.enabled=false \
		--wait --timeout 10m --atomic --debug

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