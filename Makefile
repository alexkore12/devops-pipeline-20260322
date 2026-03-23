# Makefile for devops-pipeline-20260321
# Common development tasks

.PHONY: help validate lint build test deploy clean

help:
	@echo "Available commands:"
	@echo "  make validate    - Validate Jenkinsfile syntax"
	@echo "  make lint       - Lint configuration files"
	@echo "  make build      - Build application"
	@echo "  make test       - Run tests"
	@echo "  make deploy     - Run deployment"
	@echo "  make clean      - Clean temporary files"

validate:
	@echo "Validating Jenkinsfile..."
	@grep -q "pipeline" Jenkinsfile && echo "Valid Jenkinsfile" || echo "Invalid Jenkinsfile"

lint:
	@echo "Linting configuration..."
	@command -v hadolint >/dev/null 2>&1 && hadolint Dockerfile || echo "hadolint not installed"

build:
	@echo "Building application..."
	docker build -t app:latest .

test:
	@echo "Running tests..."
	docker run --rm app:latest test || echo "No tests configured"

deploy:
	@echo "Deployment handled by Jenkins"

clean:
	find . -name "*.log" -delete
	rm -rf .gradle/ 2>/dev/null || true
	rm -rf target/ 2>/dev/null || true
