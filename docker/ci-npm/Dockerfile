# Stage 1: Node.js builder for installing npm global tools
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

# Stage 2: Final ci-npm image extending ci-base
FROM ghcr.io/spenceryork/ci-image/ci-base:v1.0

# Architecture argument for multi-platform builds
ARG TARGETARCH

# Install Node.js 20 LTS (same version as builder for consistency)
RUN set -eux; \
    case "${TARGETARCH}" in \
        'amd64') NODE_ARCH='x64' ;; \
        'arm64') NODE_ARCH='arm64' ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac; \
    wget -O node.tar.xz "https://nodejs.org/dist/v20.18.0/node-v20.18.0-linux-${NODE_ARCH}.tar.xz" && \
    sudo tar -C /usr/local --strip-components=1 -xJf node.tar.xz && \
    rm node.tar.xz

# Copy Node.js global tools from builder stage
COPY --from=npm-builder /npm-global /usr/local
COPY --from=npm-builder /npm-cache /home/ci-user/.npm

# Set Node.js environment variables for ci-user
ENV NODE_PATH=/usr/local/lib/node_modules
ENV NPM_CONFIG_PREFIX=/home/ci-user/.npm-global
ENV NPM_CONFIG_CACHE=/home/ci-user/.npm
ENV PATH=/usr/local/bin:/home/ci-user/.npm-global/bin:$PATH
ENV NODE_ENV=development
ENV NPM_CONFIG_UPDATE_NOTIFIER=false
ENV NPM_CONFIG_AUDIT=false

# Create npm directories with proper ownership
RUN sudo mkdir -p /home/ci-user/.npm-global /home/ci-user/.npm && \
    sudo chown -R ci-user:ci-user /home/ci-user/.npm-global /home/ci-user/.npm

# Switch to ci-user for final setup
USER ci-user

# Verify Node.js installation and global tools
RUN node --version && \
    npm --version && \
    tsc --version && \
    prettier --version && \
    eslint --version && \
    vite --version && \
    vitest --version && \
    echo "All Node.js tools installed successfully"

# Set default working directory
WORKDIR /workspace