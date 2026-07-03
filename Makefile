SHELL := /usr/bin/env bash

APPS := frontend legacy-service transaction-service notification-service
SCRIPT_DIR := infrastructure/scripts
TERRAFORM_INFRA := infrastructure/terraform/terraform-infra
TERRAFORM_PLATFORM := infrastructure/terraform/terraform-platform

.PHONY: help check test-apps lint-frontend terraform-fmt-check scripts-check cost-report daily-report connect-eks start-development stop-development start stop verify connect cost report

help:
	@echo "Available targets:"
	@echo "  check                 Run local syntax and formatting checks"
	@echo "  test-apps             Run app tests without building images"
	@echo "  lint-frontend         Run frontend lint"
	@echo "  terraform-fmt-check   Check Terraform formatting only"
	@echo "  scripts-check         Check shell script syntax"
	@echo "  cost-report           Run read-only AWS cost visibility report"
	@echo "  daily-report          Run read-only daily platform report"
	@echo "  connect-eks           Update kubeconfig and inspect nodes"
	@echo "  start-development     Run existing development start workflow"
	@echo "  stop-development      Run existing development stop workflow"
	@echo "  start                 Prepare the full development environment"
	@echo "  stop                  Stop expensive development compute resources"
	@echo "  verify                Verify local tooling and deployed platform"
	@echo "  connect               Update kubeconfig and inspect nodes"
	@echo "  cost                  Run read-only AWS cost visibility report"
	@echo "  report                Generate read-only daily platform report"

check: scripts-check terraform-fmt-check test-apps

test-apps:
	@for app in $(APPS); do \
		npm test --prefix "apps/$$app" --if-present; \
	done

lint-frontend:
	npm run lint --prefix apps/frontend

terraform-fmt-check:
	terraform -chdir=$(TERRAFORM_INFRA) fmt -check
	terraform -chdir=$(TERRAFORM_PLATFORM) fmt -check

scripts-check:
	@find $(SCRIPT_DIR) -name '*.sh' -print -exec bash -n {} \;

cost-report:
	$(SCRIPT_DIR)/04_check-cost.sh

daily-report:
	$(SCRIPT_DIR)/10_daily-report.sh

connect-eks:
	$(SCRIPT_DIR)/02_connect-eks.sh

start-development:
	$(SCRIPT_DIR)/06_start-development.sh

stop-development:
	$(SCRIPT_DIR)/05_stop-development.sh

start: start-development

stop:
	$(SCRIPT_DIR)/05_stop-development.sh --yes

verify: scripts-check terraform-fmt-check
	$(SCRIPT_DIR)/01_check-environment.sh
	$(SCRIPT_DIR)/03_verify-platform.sh

connect: connect-eks

cost: cost-report

report: daily-report
