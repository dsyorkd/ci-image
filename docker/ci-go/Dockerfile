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

# Stage 2: Final ci-go image extending ci-base
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

# Set Go environment variables for ci-user
ENV GOPATH=/home/ci-user/go
ENV GOCACHE=/home/ci-user/.cache/go-build
ENV GOMODCACHE=/home/ci-user/go/pkg/mod
ENV PATH=/usr/local/go/bin:$GOPATH/bin:$PATH
ENV GOOS=linux
ENV CGO_ENABLED=1

# Copy Go tools from builder stage
COPY --from=go-builder /go/bin/protoc-gen-go /usr/local/bin/
COPY --from=go-builder /go/bin/protoc-gen-go-grpc /usr/local/bin/
COPY --from=go-builder /go/bin/golangci-lint /usr/local/bin/
COPY --from=go-builder /go/bin/mockgen /usr/local/bin/
COPY --from=go-builder /go/bin/goimports /usr/local/bin/

# Create Go workspace directories with proper ownership
RUN sudo mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg && \
    sudo mkdir -p /home/ci-user/.cache/go-build && \
    sudo chown -R ci-user:ci-user $GOPATH /home/ci-user/.cache

# Switch to ci-user for final setup
USER ci-user

# Verify Go installation and tools
RUN go version && \
    protoc-gen-go --version && \
    protoc-gen-go-grpc --version && \
    golangci-lint version && \
    mockgen -version && \
    (goimports --help || goimports -h || which goimports) > /dev/null 2>&1 && echo "goimports installed successfully"

# Set default working directory
WORKDIR /workspace