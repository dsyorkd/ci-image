# Docker CI/CD Image System

A comprehensive Docker image ecosystem for multi-technology development workflows, optimized for Go backend and React frontend development with Raspberry Pi hardware deployment.

## 🎯 Project Overview

This project implements a **specialized Docker image system** with shared base layers, designed to support:

- **Go 1.24.x** backend development with comprehensive toolchain
- **React 19.x + Vite 7.x + TypeScript 5.8.3** frontend development  
- **Multi-architecture builds** for both x86_64 and ARM64 (Raspberry Pi)
- **Security-first approach** with vulnerability scanning and SBOM generation
- **Hot reload development** workflows with containerized environments
- **GPIO testing strategies** for Pi hardware integration

## 🏗️ Image Architecture

### Layered Design
```
ubuntu:22.04-lts (Base Layer)
├── ci-base:v1.0          # System essentials + security tools
├── ci-go:v1.0            # Go toolchain + ci-base
├── ci-npm:v1.0           # Node.js/React stack + ci-base
└── ci-go-npm:v1.0        # Combined full-stack + ci-base
```

### Registry Strategy
- **GitHub Container Registry**: `ghcr.io/spenceryork/ci-image/`
- **Multi-architecture**: Native ARM64 for Raspberry Pi deployment
- **Semantic versioning**: v1.0.0, v1.0.1, latest tags

## 🚀 Key Features

- ✅ **Security-First**: Non-root containers, vulnerability scanning, SBOM generation
- ✅ **Pi-Optimized**: ARM64 cross-compilation and GPIO testing support  
- ✅ **Developer Experience**: Hot reloading, comprehensive Makefile integration
- ✅ **CI/CD Ready**: GitHub Actions workflows with multi-arch builds
- ✅ **Production Ready**: systemd integration and deployment automation

## 📋 Development Progress


<!-- TASKMASTER_EXPORT_START -->
> 🎯 **Taskmaster Export** - 2025-09-07 03:47:46 UTC
> 📋 Export: with subtasks • Status filter: none
> 🔗 Powered by [Task Master](https://task-master.dev?utm_source=github-readme&utm_medium=readme-export&utm_campaign=ci-image&utm_content=task-export-link)

| Project Dashboard |  |
| :-                |:-|
| Task Progress     | ░░░░░░░░░░░░░░░░░░░░ 0% |
| Done | 0 |
| In Progress | 0 |
| Pending | 10 |
| Deferred | 0 |
| Cancelled | 0 |
|-|-|
| Subtask Progress | ░░░░░░░░░░░░░░░░░░░░ 0% |
| Completed | 0 |
| In Progress | 0 |
| Pending | 10 |


| ID | Title | Status | Priority | Dependencies | Complexity |
| :- | :-    | :-     | :-       | :-           | :-         |
| 1 | Implement Foundational `ci-base` Docker Image | ○&nbsp;pending | high | None | N/A |
| 1.1 | Initialize Dockerfile and Install Core System Packages | ○&nbsp;pending | -            | None | N/A |
| 1.2 | Implement Multi-Architecture Installation for Security Tools | ○&nbsp;pending | -            | None | N/A |
| 1.3 | Create and Configure Non-Root `ci-user` | ○&nbsp;pending | -            | None | N/A |
| 1.4 | Set Up Workspace Directory and Finalize User Configuration | ○&nbsp;pending | -            | None | N/A |
| 1.5 | Add Makefile Target for Local `ci-base` Image Build | ○&nbsp;pending | -            | None | N/A |
| 2 | Set Up Multi-Arch Build and Publish Pipeline in GitHub Actions | ○&nbsp;pending | high | 1 | N/A |
| 3 | Develop Specialized `ci-go` Image with Multi-Stage Build | ○&nbsp;pending | high | 1 | N/A |
| 4 | Develop Specialized `ci-npm` Image with Multi-Stage Build | ○&nbsp;pending | medium | 1 | N/A |
| 5 | Develop Combined `ci-go-npm` Full-Stack Image | ○&nbsp;pending | medium | 3, 4 | N/A |
| 5.1 | Create `ci-go-npm/Dockerfile` and Define Go Builder Stage | ○&nbsp;pending | -            | None | N/A |
| 5.2 | Add Node.js Builder Stage to Dockerfile | ○&nbsp;pending | -            | 5.1 | N/A |
| 5.3 | Implement Final Stage and Copy Go/Node Artifacts | ○&nbsp;pending | -            | 5.1, 5.2 | N/A |
| 5.4 | Configure Combined Environment Variables for Go and Node.js | ○&nbsp;pending | -            | 5.3 | N/A |
| 5.5 | Create and Secure User-Writable Directories | ○&nbsp;pending | -            | 5.4 | N/A |
| 6 | Expand GitHub Actions to Build All Specialized Images | ○&nbsp;pending | medium | 2, 5 | N/A |
| 7 | Implement Comprehensive Makefile for Development Workflows | ○&nbsp;pending | high | 5 | N/A |
| 8 | Integrate Makefile with Docker for Containerized Workflows | ○&nbsp;pending | medium | 7 | N/A |
| 9 | Implement Build, Security, and Pi Deployment Makefile Targets | ○&nbsp;pending | medium | 7 | N/A |
| 10 | Create Comprehensive Documentation and Usage Examples | ○&nbsp;pending | low | 2, 8, 9 | N/A |

> 📋 **End of Taskmaster Export** - Tasks are synced from your project using the `sync-readme` command.
<!-- TASKMASTER_EXPORT_END -->

## 🚀 Quick Start

### Development Workflow

```bash
# Pull the combined full-stack image
docker pull ghcr.io/spenceryork/ci-image/ci-go-npm:v1.0

# Start development with hot reloading
docker run -it --rm \
  --name pi-controller-dev \
  -v $(pwd):/workspace \
  -v pi-controller-cache:/go/pkg/mod \
  -p 3000:3000 -p 8080:8080 \
  ghcr.io/spenceryork/ci-image/ci-go-npm:v1.0 \
  make dev-all
```

### Pi Deployment

```bash
# Build for Raspberry Pi (ARM64)
docker run --rm -v $(pwd):/workspace \
  -e GOOS=linux -e GOARCH=arm64 \
  ghcr.io/spenceryork/ci-image/ci-go-npm:v1.0 \
  make build-pi

# Deploy to Pi
make deploy-pi DEPLOY_TARGET=pi@raspberrypi.local
```

### Available Images

| Image | Purpose | Size | Usage |
|-------|---------|------|-------|
| `ci-base:v1.0` | Foundation with system tools | ~500MB | Base for other images |
| `ci-go:v1.0` | Go development | ~1GB | Go-only projects |
| `ci-npm:v1.0` | React/Node.js development | ~1.5GB | Frontend-only projects |
| `ci-go-npm:v1.0` | Full-stack development | ~2GB | Combined Go + React |

## 🧪 GPIO Testing

### Testing Modes

```bash
# Mock GPIO testing (CI/CD safe)
docker run --rm -v $(pwd):/workspace \
  -e GPIO_MOCK_MODE=true \
  ghcr.io/spenceryork/ci-image/ci-go-npm:v1.0 \
  make test-gpio-mock

# Real hardware testing (Pi only)
docker run --rm -v $(pwd):/workspace \
  --device /dev/gpiomem \
  --privileged \
  ghcr.io/spenceryork/ci-image/ci-go-npm:v1.0 \
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
│   ├── ci-base/Dockerfile          # Foundation image
│   ├── ci-go/Dockerfile           # Go specialization  
│   ├── ci-npm/Dockerfile          # Node.js specialization
│   └── ci-go-npm/Dockerfile       # Combined image
├── .github/workflows/
│   └── build-images.yml           # Multi-arch build pipeline
├── Makefile                       # Development targets
└── .taskmaster/                   # Task management
    ├── docs/prd.txt              # Product requirements
    └── tasks/tasks.json          # Implementation tasks
```

## 📚 Documentation

- **[PRD Document](.taskmaster/docs/prd.txt)** - Complete product requirements and architecture
- **[Task Management](.taskmaster/tasks/)** - Implementation tasks and progress tracking
- **[CI/CD Requirements](ci-cd-image-requirements.md)** - Technical specifications

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
