# Stage 1: Builder with Go for compiling Go-based security tools
FROM ubuntu:24.04 AS builder

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
        curl \
        wget \
        git \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install Go 1.25 (consistent with other stages)
ARG TARGETARCH
RUN set -eux; \
    case "${TARGETARCH}" in \
        'amd64') GO_ARCH='amd64' ;; \
        'arm64') GO_ARCH='arm64' ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    wget -O go.tar.gz "https://go.dev/dl/go1.25.0.linux-${GO_ARCH}.tar.gz" && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set Go environment variables
ENV GOPATH=/go
ENV PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# Install Go-based security tools using go install (architecture-aware)
RUN go install golang.org/x/vuln/cmd/govulncheck@latest
RUN go install github.com/securego/gosec/v2/cmd/gosec@latest

# Stage 2: Final ci-base image
FROM ubuntu:24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install core system packages with security updates
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        make \
        git \
        curl \
        wget \
        sudo \
        bash \
        build-essential \
        protobuf-compiler \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Security tools versions (updated for v2.0)
ARG OSV_SCANNER_VERSION=1.9.0
ARG SYFT_VERSION=v1.17.0

# Architecture argument for multi-platform builds
ARG TARGETARCH

# Copy Go-based tools from the builder stage
COPY --from=builder /go/bin/govulncheck /usr/local/bin/
COPY --from=builder /go/bin/gosec /usr/local/bin/

# Install osv-scanner (direct binary download)
RUN curl -L "https://github.com/google/osv-scanner/releases/download/v${OSV_SCANNER_VERSION}/osv-scanner_v${OSV_SCANNER_VERSION}_linux_${TARGETARCH}" -o /usr/local/bin/osv-scanner && \
    chmod +x /usr/local/bin/osv-scanner

# Install syft using official installation script (architecture-aware)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin ${SYFT_VERSION}

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash ci-user && \
    usermod -aG sudo ci-user && \
    echo 'ci-user ALL=(ALL:ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt, /bin/tar, /bin/mkdir, /bin/chown' >> /etc/sudoers.d/ci-user && \
    chmod 0440 /etc/sudoers.d/ci-user

# Set up workspace directory and finalize user configuration
RUN mkdir -p /workspace && \
    chown ci-user:ci-user /workspace

# Set default working directory and switch to non-root user
WORKDIR /workspace
USER ci-user