.DEFAULT_GOAL := help
CLOUD ?= aws
ACCOUNT ?= workload-dev
REGION ?= us-west-2
ENVIRONMENT ?= dev
COMPONENT ?= all

##@ Validation

.PHONY: fmt
fmt: ## Format all OpenTofu files
	tofu fmt -recursive components/
	tofu fmt -recursive modules/

.PHONY: fmt-check
fmt-check: ## Check formatting without modifying files
	tofu fmt -check -recursive components/
	tofu fmt -check -recursive modules/

.PHONY: validate
validate: ## Validate all components for CLOUD (default: aws)
	@for dir in components/$(CLOUD)/*/; do \
		name=$$(basename $$dir); \
		echo "Validating $(CLOUD)/$$name..."; \
		cd $$dir && tofu init -backend=false -input=false > /dev/null 2>&1 && tofu validate && cd - > /dev/null || exit 1; \
	done
	@echo "All $(CLOUD) components valid."

.PHONY: lint
lint: ## Run tflint on all components for CLOUD (default: aws)
	tflint --recursive --config .tflint-$(CLOUD).hcl components/$(CLOUD)/

##@ Planning

.PHONY: plan
plan: ## Plan for CLOUD/ACCOUNT/REGION/ENVIRONMENT/COMPONENT
	@if [ "$(COMPONENT)" = "all" ]; then \
		cd live/$(CLOUD)/$(ACCOUNT)/$(REGION)/$(ENVIRONMENT) && terragrunt run-all plan; \
	else \
		cd live/$(CLOUD)/$(ACCOUNT)/$(REGION)/$(ENVIRONMENT)/$(COMPONENT) && terragrunt plan; \
	fi

.PHONY: apply
apply: ## Apply for CLOUD/ACCOUNT/REGION/ENVIRONMENT/COMPONENT
	@if [ "$(COMPONENT)" = "all" ]; then \
		cd live/$(CLOUD)/$(ACCOUNT)/$(REGION)/$(ENVIRONMENT) && terragrunt run-all apply; \
	else \
		cd live/$(CLOUD)/$(ACCOUNT)/$(REGION)/$(ENVIRONMENT)/$(COMPONENT) && terragrunt apply; \
	fi

##@ Backend

.PHONY: init-backend
init-backend: ## Create backend storage for CLOUD
	./scripts/init-backend-$(CLOUD).sh

##@ Help

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m [CLOUD=aws|gcp|azure] [ACCOUNT=workload-dev|workload-staging|workload-prod|management] [REGION=us-west-2] [ENVIRONMENT=dev|staging|production|org] [COMPONENT=network|cluster|all]\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
