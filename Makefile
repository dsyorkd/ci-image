# Docker CI/CD Image System Makefile
# Provides targets for building and managing CI Docker images

.PHONY: help build-ci-base build-ci-go build-ci-npm build-ci-go-npm clean packer-validate packer-build

# Default target
help: ## Show this help message
	@echo "Docker CI/CD Image System - Available Targets:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Base image build target
build-ci-base: ## Build the foundational ci-base Docker image
	@echo "Building ci-base image..."
	docker build --platform linux/amd64,linux/arm64 \
		-t ghcr.io/dsyorkd/ci-image/ci-base:latest \
		-t ghcr.io/dsyorkd/ci-image/ci-base:v1.0 \
		docker/ci-base/
	@echo "✅ ci-base image built successfully"

# Specialized image build targets
build-ci-go: build-ci-base ## Build the Go-specialized Docker image
	@echo "Building ci-go image..."
	docker build --platform linux/amd64,linux/arm64 \
		-t ghcr.io/dsyorkd/ci-image/ci-go:latest \
		-t ghcr.io/dsyorkd/ci-image/ci-go:v1.0 \
		docker/ci-go/
	@echo "✅ ci-go image built successfully"

build-ci-npm: build-ci-base ## Build the Node.js/React-specialized Docker image
	@echo "Building ci-npm image..."
	docker build --platform linux/amd64,linux/arm64 \
		-t ghcr.io/dsyorkd/ci-image/ci-npm:latest \
		-t ghcr.io/dsyorkd/ci-image/ci-npm:v1.0 \
		docker/ci-npm/
	@echo "✅ ci-npm image built successfully"

build-ci-go-npm: build-ci-base ## Build the combined full-stack Docker image
	@echo "Building ci-go-npm image..."
	docker build --platform linux/amd64,linux/arm64 \
		-t ghcr.io/dsyorkd/ci-image/ci-go-npm:latest \
		-t ghcr.io/dsyorkd/ci-image/ci-go-npm:v1.0 \
		docker/ci-go-npm/
	@echo "✅ ci-go-npm image built successfully"

# Utility targets
clean: ## Remove all locally built CI images
	@echo "Cleaning up local CI images..."
	docker rmi -f $$(docker images "ghcr.io/dsyorkd/ci-image/*" -q) 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Test targets for built images
test-ci-base: build-ci-base ## Build and test the ci-base image
	@echo "Testing ci-base image..."
	@echo "Testing tool versions:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest git --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest make --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest protoc --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest govulncheck -version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest gosec -version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest osv-scanner --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest syft version
	@echo "Testing user and workspace:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest whoami
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest pwd
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-base:latest touch test.txt && echo "✅ Write permissions OK" || echo "❌ Write permissions failed"
	@echo "✅ ci-base image tests completed"

test-ci-go: build-ci-go ## Build and test the ci-go image
	@echo "Testing ci-go image..."
	@echo "Testing Go installation and tools:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest go version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest protoc-gen-go --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest protoc-gen-go-grpc --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest golangci-lint version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest mockgen -version
	@echo "Testing Go environment:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest printenv | grep -E "^(GOPATH|GOROOT|GOOS|CGO_ENABLED)="
	@echo "Testing Go build capability:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go:latest sh -c 'echo "package main\nimport \"fmt\"\nfunc main() { fmt.Println(\"Hello CI\") }" > main.go && go build main.go && ./main'
	@echo "✅ ci-go image tests completed"

test-ci-npm: build-ci-npm ## Build and test the ci-npm image
	@echo "Testing ci-npm image..."
	@echo "Testing Node.js installation and tools:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest node --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest npm --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest tsc --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest prettier --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest eslint --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest vite --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest vitest --version
	@echo "Testing Node.js environment:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest printenv | grep -E "^(NODE_PATH|NPM_CONFIG)="
	@echo "Testing simple React project creation:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-npm:latest sh -c 'echo "{\"name\":\"test\",\"type\":\"module\",\"dependencies\":{\"react\":\"^18.0.0\"}}" > package.json && npm install --silent && echo "✅ npm install works"'
	@echo "✅ ci-npm image tests completed"

test-ci-go-npm: build-ci-go-npm ## Build and test the combined ci-go-npm image
	@echo "Testing ci-go-npm image..."
	@echo "Testing combined Go and Node.js installation:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest go version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest node --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest npm --version
	@echo "Testing Go tools:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest protoc-gen-go --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest protoc-gen-go-grpc --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest golangci-lint version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest mockgen -version
	@echo "Testing Node.js tools:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest tsc --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest prettier --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest eslint --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest vite --version
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest vitest --version
	@echo "Testing combined environment:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest printenv | grep -E "^(GOPATH|NODE_PATH|PATH)="
	@echo "Testing full-stack build capabilities:"
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest sh -c 'echo "package main\nimport \"fmt\"\nfunc main() { fmt.Println(\"Hello Go+Node CI\") }" > main.go && go build main.go && ./main'
	docker run --rm ghcr.io/dsyorkd/ci-image/ci-go-npm:latest sh -c 'echo "{\"name\":\"test\",\"type\":\"module\"}" > package.json && echo "console.log(\"Hello from Node!\");" > index.js && node index.js'
	@echo "✅ ci-go-npm image tests completed"

# Packer targets for GitHub Actions runner VMs
packer-validate: ## Validate Packer template for GitHub Actions runners
	@echo "Validating GitHub Actions runner Packer template..."
	cd packer/proxmox-gh-runner && ./build.sh --dry-run
	@echo "✅ Packer template validation completed"

packer-build: ## Build GitHub Actions runner VM template with Packer
	@echo "Building GitHub Actions runner VM template..."
	cd packer/proxmox-gh-runner && ./build.sh
	@echo "✅ VM template build completed"

.DEFAULT_GOAL := help