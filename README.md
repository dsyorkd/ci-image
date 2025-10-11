# Docker CI/CD Image System

A comprehensive Docker image ecosystem for multi-technology development workflows, optimized for Go backend and React frontend development with Raspberry Pi hardware deployment.

## 🎯 Project Overview

This project implements a **production-ready Docker image system** with shared base layers, designed to support:

- **Go 1.25.x** backend development with comprehensive toolchain
- **Node.js 20.x + TypeScript 5.x + React/Vite** frontend development  
- **Multi-architecture builds** for both x86_64 and ARM64 (Raspberry Pi)
- **Security-first approach** with vulnerability scanning, secret detection, and compliance checking
- **Automated CI/CD workflows** with GitHub Actions
- **Specialized security and Python development environments**

## 🏗️ Image Architecture

### Layered Design
```
ubuntu:24.04 (Base Layer)
├── ci-base:v2.0          # System essentials + security tools (govulncheck, gosec, osv-scanner, syft)
├── ci-go:v2.0            # Go 1.25 + protobuf + linting tools + ci-base
├── ci-npm:v2.0           # Node.js 20 + TypeScript + React/Vite stack + ci-base
├── ci-go-npm:v2.0        # Combined full-stack environment + ci-base
├── ci-python:v2.0        # Python development environment (standalone)
└── ci-security:v2.0      # Security scanning and analysis tools (standalone)
```

### Registry Strategy
- **GitHub Container Registry**: `ghcr.io/dsyorkd/ci-image/`
- **Multi-architecture**: Native ARM64 for Raspberry Pi deployment
- **Semantic versioning**: v1.0.0, v1.0.1, latest tags

## 🚀 Key Features

- ✅ **Security-First**: Non-root containers, Trivy vulnerability scanning, TruffleHog secret detection, Dockerfile linting
- ✅ **Multi-Architecture**: AMD64 and ARM64 builds for Raspberry Pi deployment
- ✅ **Developer Experience**: Comprehensive Makefile with test targets and local development workflows
- ✅ **CI/CD Ready**: Complete GitHub Actions pipeline with automated builds, security scanning, and compliance checks
- ✅ **Production Ready**: All workflows passing, container registry integration, failure handling automation

## 📋 Project Status

### ✅ **PRODUCTION READY** - All Core Components Implemented

| Component | Status | Description |
|-----------|--------|-------------|
| **🐳 Docker Images** | ✅ Complete | All 6 images built and tested (ci-base, ci-go, ci-npm, ci-go-npm, ci-python, ci-security) |
| **🏗️ CI/CD Pipeline** | ✅ Complete | GitHub Actions with multi-arch builds, security scanning, and automated testing |
| **🔒 Security Scanning** | ✅ Complete | Trivy, TruffleHog, Hadolint, dependency checks, compliance validation |
| **🛠️ Development Tools** | ✅ Complete | Comprehensive Makefile with build, test, and development targets |
| **📦 Container Registry** | ✅ Complete | GitHub Container Registry integration with automated publishing |
| **🔧 Failure Handling** | ✅ Complete | Automated failure detection and PR creation system |

### Recent Achievements
- **🎉 All CI workflows now passing** - Resolved sudoers configuration, Docker registry access, and build verification issues
- **🧹 Cleaned up 12 redundant automated failure PRs** - Repository is now clean and ready for development
- **🔧 Fixed critical build issues** - goimports verification, missing dependencies, security scan configurations
- **📊 Comprehensive testing** - All Docker images have working test suites and verification steps

### Current Workflow Status
```
✅ CI Tests:        All images building and testing successfully
✅ Security Scan:   Vulnerability and secret scanning operational  
✅ Build Pipeline:  Multi-architecture builds working
✅ Registry:        Automated publishing configured
```

## 🚀 Quick Start

### Development Workflow

```bash
# Pull the combined full-stack image
docker pull ghcr.io/dsyorkd/ci-image/ci-go-npm:v2.0

# Start development with hot reloading
docker run -it --rm \
  --name pi-controller-dev \
  -v $(pwd):/workspace \
  -v pi-controller-cache:/go/pkg/mod \
  -p 3000:3000 -p 8080:8080 \
  ghcr.io/dsyorkd/ci-image/ci-go-npm:v2.0 \
  make dev-all
```

### Pi Deployment

```bash
# Build for Raspberry Pi (ARM64)
docker run --rm -v $(pwd):/workspace \
  -e GOOS=linux -e GOARCH=arm64 \
  ghcr.io/dsyorkd/ci-image/ci-go-npm:v2.0 \
  make build-pi

# Deploy to Pi
make deploy-pi DEPLOY_TARGET=pi@raspberrypi.local
```

### Available Images

| Image | Purpose | Key Tools | Usage |
|-------|---------|-----------|-------|
| `ci-base:v2.0` | Foundation with security tools | govulncheck, gosec, osv-scanner, syft | Base for other images |
| `ci-go:v2.0` | Go development | Go 1.25, protoc-gen-go, golangci-lint v2.4.0, mockgen | Go-only projects |
| `ci-npm:v2.0` | Node.js/React development | Node 20, TypeScript, Vite, Vitest, ESLint | Frontend-only projects |
| `ci-go-npm:v2.0` | Full-stack development | Combined Go + Node.js toolchains | Combined Go + React |
| `ci-python:v2.0` | Python development | Python runtime and tools | Python projects |
| `ci-security:v2.0` | Security analysis | Specialized security scanning tools | Security testing |

## 🧪 GPIO Testing

### Testing Modes

```bash
# Mock GPIO testing (CI/CD safe)
docker run --rm -v $(pwd):/workspace \
  -e GPIO_MOCK_MODE=true \
  ghcr.io/dsyorkd/ci-image/ci-go-npm:v2.0 \
  make test-gpio-mock

# Real hardware testing (Pi only)
docker run --rm -v $(pwd):/workspace \
  --device /dev/gpiomem \
  --privileged \
  ghcr.io/dsyorkd/ci-image/ci-go-npm:v2.0 \
  make test-gpio-real
```

## 🛠️ Development

### Prerequisites

- Docker with BuildKit support
- GitHub account for container registry access

### Building Locally

```bash
# Build base image
make build-ci-base

# Build specialized images  
make build-ci-go
make build-ci-npm
make build-ci-go-npm
```

### Project Structure

```
ci-image/
├── docker/
│   ├── ci-base/Dockerfile          # Foundation image with security tools
│   ├── ci-go/Dockerfile           # Go 1.25 development environment
│   ├── ci-npm/Dockerfile          # Node.js 20 + TypeScript + React/Vite
│   ├── ci-go-npm/Dockerfile       # Combined full-stack environment
│   ├── ci-python/Dockerfile       # Python development environment
│   └── ci-security/Dockerfile     # Security analysis tools
├── .github/workflows/
│   ├── build-images.yml           # Multi-arch build and publish pipeline
│   ├── ci-tests.yml               # Comprehensive testing of all images
│   ├── security-scan.yml          # Vulnerability and security scanning
│   └── failure-handler.yml        # Automated failure detection and PR creation
├── Makefile                       # Development, build, and test targets
├── LICENSE                        # MIT license
└── .taskmaster/                   # Task management system
    ├── docs/prd.txt              # Product requirements document
    └── tasks/tasks.json          # Implementation tracking
```

## 🔧 Recent Infrastructure Improvements

### Critical Fixes Applied (September 2025)
- **✅ Sudoers Configuration** - Fixed passwordless sudo access for package installation in containers
- **✅ Docker Registry Access** - Resolved 403 Forbidden errors with proper artifact sharing in workflows
- **✅ Build Tool Verification** - Fixed goimports and other Go tool verification steps
- **✅ Security Scan Optimization** - Restructured workflows to handle base image dependencies efficiently  
- **✅ Missing Dependencies** - Added required packages (wget) and missing Docker directories
- **✅ TruffleHog Configuration** - Fixed BASE/HEAD commit reference issues for secret scanning

### Workflow Health
All GitHub Actions workflows are now **passing consistently**:
- **Build and Publish Images**: Multi-architecture builds working flawlessly
- **CI Tests**: All 6 Docker images building and testing successfully  
- **Security Scan**: Comprehensive vulnerability and compliance checking operational
- **Failure Handler**: Automated issue detection and PR creation system active

## 📚 Documentation

- **[PRD Document](.taskmaster/docs/prd.txt)** - Complete product requirements and architecture
- **[Task Management](.taskmaster/tasks/)** - Implementation tasks and progress tracking
- **[GitHub Actions](.github/workflows/)** - Complete CI/CD pipeline configuration

## 🤝 Contributing

This project uses [Task Master](https://task-master.dev) for task management:

```bash
# View available tasks
task-master list

# Work on next task
task-master next

# Update task status
task-master set-status --id=1.1 --status=done
```

## 📄 License

MIT License - See LICENSE file for details

---

> **Note**: This project is optimized for Raspberry Pi deployment but works on any Docker-compatible platform.
