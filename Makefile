## include .env
ifneq (,$(wildcard ./.env))
	include .env
	export
endif

DOCKER_EXEC = docker run \
				-u $(shell id -u):$(shell id -g) \
				--rm \
				-v $(PWD):/opt \
				-e AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) \
				-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
				-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
				-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
				-e ANSIBLE_VAULT_PASSWORD=$(ANSIBLE_VAULT_PASS) \
				-e USERNAME=$(USERNAME) \
				jeffreycai/vultr_agent:latest

## Outer Docker Commands
plan:
	@$(DOCKER_EXEC) make _plan
.PHONEY: plan

apply:
	@$(DOCKER_EXEC) make _apply
.PHONEY: apply

destroy:
	@$(DOCKER_EXEC) make _destroy
.PHONEY: destroy

bootstrap:
	@$(DOCKER_EXEC) make _bootstrap
.PHONEY: bootstrap

## Inner Docker Commands
# Terraform
_plan: _init
	@cd app/terraform && terraform plan -var="AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID)"
.PHONEY: _plan

_init: _format
	@cd app/terraform && (terraform workspace select $(AWS_ACCOUNT_ID) || terraform workspace new $(AWS_ACCOUNT_ID)) && terraform init
.PHONEY: _init

_apply:
	@cd app/terraform && terraform apply -var="AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID)" -auto-approve
.PHONEY: _apply

_destroy:
	@cd app/terraform && terraform destroy -var="AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID)" -auto-approve
.PHONEY: _destroy

_format:
	@cd app/terraform && terraform fmt
.PHONEY: _format

# Ansible
_bootstrap:
	@AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) bash scripts/bootstrap.sh
.PHONEY: _bootstrap

## Build Agent Commands
# build
build:
	@echo "$(ANSIBLE_VAULT_PASS)" > docker/ansible_vault_password
	@cd docker && docker build \
					--build-arg UID=$(shell id -u) \
					--build-arg GID=$(shell id -g) \
					--build-arg USERNAME=$(shell id -un) \
					--build-arg GROUPNAME=$(shell id -gn) \
					-t jeffreycai/vultr_agent .
	@rm docker/ansible_vault_password
.PHONEY: build

## rebuild
rebuild: clean build push
.PHONEY: rebuild

## clean
clean:
	@cd docker && docker rmi jeffreycai/vultr_agent:latest &>/dev/null || true
.PHONEY: clean

## push
push:
	@docker login && docker push jeffreycai/vultr_agent:latest
.PHONEY: push

## pull
pull:
	@docker pull jeffreycai/vultr_agent:latest

## debug
debug:
	@docker run -it \
				-u $(shell id -u):$(shell id -g) \
				--rm \
				-v $(PWD):/opt \
				-e AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) \
				-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
				-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
				-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
				-e ANSIBLE_VAULT_PASSWORD=$(ANSIBLE_VAULT_PASS) \
				-e USERNAME=$(USERNAME) \
				jeffreycai/vultr_agent:latest /bin/bash
.PHONEY: debug

## ssh
ssh:
	@docker run  \
				-u $(shell id -u):$(shell id -g) \
				--rm \
				-it \
				-v $(PWD):/opt \
				-e AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID) \
				-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
				-e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
				-e AWS_SESSION_TOKEN=$(AWS_SESSION_TOKEN) \
				-e ANSIBLE_VAULT_PASSWORD=$(ANSIBLE_VAULT_PASS) \
				-e USERNAME=$(USERNAME) \
				jeffreycai/vultr_agent:latest /bin/bash /opt/scripts/ssh.sh

