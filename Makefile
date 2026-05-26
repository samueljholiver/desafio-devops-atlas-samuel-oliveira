.PHONY: dev-up dev-down dev-logs tf-init tf-plan tf-validate

# ── Docker Development ──────────────────────────────────────
dev-up:
	docker-compose up -d

dev-down:
	docker-compose down

dev-logs:
	docker-compose logs -f

# ── Terraform ───────────────────────────────────────────────
# Note: Terraform files are currently in .terraform/ per project layout
TF_DIR=.terraform

tf-init:
	cd $(TF_DIR) && terraform init

tf-plan:
	cd $(TF_DIR) && terraform plan -var-file=../local.tfvars

tf-validate:
	cd $(TF_DIR) && terraform validate
