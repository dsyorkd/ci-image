# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| v2.x    | :white_check_mark: |
| v1.x    | :white_check_mark: |
| < v1.0  | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it via GitHub Security Advisories or email the maintainers.

Include:
- Type of issue
- Affected source files
- Steps to reproduce
- Impact assessment

## Security Scanning

Automated scanning includes:
- Trivy (container vulnerabilities)
- TruffleHog (secrets)
- Hadolint (Dockerfile best practices)
- npm audit / safety (dependencies)
