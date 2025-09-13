FROM python:3.13-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install common Python tools
RUN pip install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]# TODO: Consider adding non-root user for security
