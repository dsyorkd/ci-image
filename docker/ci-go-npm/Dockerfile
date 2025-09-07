# Stage 1: Go builder for installing Go-specific tools
FROM golang:1.24-bullseye AS go-builder

# Set environment variables for Go
ENV GOOS=linux
ENV CGO_ENABLED=0

# Install Protocol Buffer compiler tools for Go
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Install golangci-lint for code quality
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2

# Install additional Go development tools
RUN go install github.com/golang/mock/mockgen@latest
RUN go install golang.org/x/tools/cmd/goimports@latest

# Stage 2: Node.js builder for installing npm global tools
FROM node:22-bullseye AS npm-builder

# Set Node.js environment variables
ENV NODE_ENV=production
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_AUDIT=false

# Create a clean npm cache directory
RUN mkdir -p /npm-global && \
    npm config set prefix /npm-global && \
    npm config set cache /npm-cache

# Install global development tools
RUN npm install -g \
    typescript@latest \
    prettier@latest \
    eslint@latest \
    vite@latest \
    vitest@latest \
    @vitejs/plugin-react@latest \
    @types/node@latest \
    tsx@latest

# Stage 3: Final ci-go-npm image extending ci-base
FROM ghcr.io/spenceryork/ci-image/ci-base:v1.0

# Architecture argument for multi-platform builds
ARG TARGETARCH

# Install Go 1.24 (same version as builder for consistency)
RUN set -eux; \
    case "${TARGETARCH}" in \
        'amd64') GO_ARCH='amd64' ;; \
        'arm64') GO_ARCH='arm64' ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    wget -O go.tar.gz "https://go.dev/dl/go1.24.0.linux-${GO_ARCH}.tar.gz" && \
    sudo tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Install Node.js 20 LTS (same version as npm-builder for consistency)
RUN set -eux; \
    case "${TARGETARCH}" in \
        'amd64') NODE_ARCH='x64' ;; \
        'arm64') NODE_ARCH='arm64' ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    wget -O node.tar.xz "https://nodejs.org/dist/v20.18.0/node-v20.18.0-linux-${NODE_ARCH}.tar.xz" && \
    sudo tar -C /usr/local --strip-components=1 -xJf node.tar.xz && \
    rm node.tar.xz

# Copy Go tools from builder stage
COPY --from=go-builder /go/bin/protoc-gen-go /usr/local/bin/
COPY --from=go-builder /go/bin/protoc-gen-go-grpc /usr/local/bin/
COPY --from=go-builder /go/bin/golangci-lint /usr/local/bin/
COPY --from=go-builder /go/bin/mockgen /usr/local/bin/
COPY --from=go-builder /go/bin/goimports /usr/local/bin/

# Copy Node.js global tools from npm-builder stage
COPY --from=npm-builder /npm-global /usr/local
COPY --from=npm-builder /npm-cache /home/ci-user/.npm

# Set combined environment variables for Go and Node.js
ENV GOPATH=/home/ci-user/go
ENV GOCACHE=/home/ci-user/.cache/go-build
ENV GOMODCACHE=/home/ci-user/go/pkg/mod
ENV NODE_PATH=/usr/local/lib/node_modules
ENV NPM_CONFIG_PREFIX=/home/ci-user/.npm-global
ENV NPM_CONFIG_CACHE=/home/ci-user/.npm
ENV PATH=/usr/local/go/bin:$GOPATH/bin:/usr/local/bin:/home/ci-user/.npm-global/bin:$PATH
ENV GOOS=linux
ENV CGO_ENABLED=1
ENV NODE_ENV=development
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_AUDIT=false

# Create and set permissions for user-writable directories
RUN sudo mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg && \
    sudo mkdir -p /home/ci-user/.cache/go-build && \
    sudo mkdir -p /home/ci-user/.npm-global /home/ci-user/.npm && \
    sudo chown -R ci-user:ci-user $GOPATH /home/ci-user/.cache /home/ci-user/.npm-global /home/ci-user/.npm

# Switch to ci-user for final setup
USER ci-user

# Verify installations
RUN go version && \
    node --version && \
    npm --version && \
    protoc-gen-go --version && \
    protoc-gen-go-grpc --version && \
    golangci-lint version && \
    mockgen -version && \
    tsc --version && \
    prettier --version && \
    eslint --version && \
    vite --version && \
    vitest --version && \
    echo "✅ All Go and Node.js tools installed successfully"

# Set default working directory
WORKDIR /workspace