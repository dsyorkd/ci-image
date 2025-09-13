#!/bin/bash

# Build and push CI images to GitHub Container Registry
# Usage: ./build-and-push.sh [image-name] [version]

set -e

# Configuration
REGISTRY="ghcr.io"
NAMESPACE="dsyorkd/ci-image"
VERSION="${2:-v2.0}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to build and push an image
build_and_push() {
    local image_name=$1
    local dockerfile_path="docker/${image_name}/Dockerfile"
    local full_image_name="${REGISTRY}/${NAMESPACE}/${image_name}:${VERSION}"

    if [ ! -f "$dockerfile_path" ]; then
        print_error "Dockerfile not found: $dockerfile_path"
        return 1
    fi

    print_status "Building ${image_name}..."

    # Build for multiple architectures
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --tag "${full_image_name}" \
        --tag "${REGISTRY}/${NAMESPACE}/${image_name}:latest" \
        --file "${dockerfile_path}" \
        --push \
        .

    if [ $? -eq 0 ]; then
        print_status "Successfully built and pushed ${full_image_name}"
    else
        print_error "Failed to build ${image_name}"
        return 1
    fi
}

# Main script
main() {
    # Check if docker is installed
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi

    # Check if logged in to GitHub Container Registry
    if ! docker pull ${REGISTRY}/hello-world &> /dev/null; then
        print_warning "Not logged in to GitHub Container Registry"
        print_status "Please run: docker login ${REGISTRY}"
        exit 1
    fi

    # Create and use buildx builder for multi-arch
    print_status "Setting up Docker buildx for multi-architecture builds..."
    docker buildx create --name ci-builder --use 2>/dev/null || docker buildx use ci-builder
    docker buildx inspect --bootstrap

    # If specific image is provided, build only that
    if [ -n "$1" ]; then
        print_status "Building specific image: $1"
        build_and_push "$1"
    else
        # Build all CI images in dependency order
        print_status "Building all CI images..."

        # Build base image first
        build_and_push "ci-base"

        # Build specialized images that depend on ci-base
        for image in ci-go ci-npm ci-python ci-security ci-go-npm; do
            build_and_push "$image"
        done
    fi

    print_status "Build process completed!"
    print_status "Images are available at:"
    if [ -n "$1" ]; then
        echo "  ${REGISTRY}/${NAMESPACE}/$1:${VERSION}"
    else
        echo "  ${REGISTRY}/${NAMESPACE}/ci-base:${VERSION}"
        echo "  ${REGISTRY}/${NAMESPACE}/ci-go:${VERSION}"
        echo "  ${REGISTRY}/${NAMESPACE}/ci-npm:${VERSION}"
        echo "  ${REGISTRY}/${NAMESPACE}/ci-python:${VERSION}"
        echo "  ${REGISTRY}/${NAMESPACE}/ci-security:${VERSION}"
        echo "  ${REGISTRY}/${NAMESPACE}/ci-go-npm:${VERSION}"
    fi
}

# Run main function
main "$@"