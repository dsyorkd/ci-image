FROM alpine:3.22

# Install security scanning tools
RUN apk add --no-cache \
    curl \
    git \
    bash

# Install Trivy
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]# TODO: Consider adding non-root user for security
