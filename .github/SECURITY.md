# Security Policy

## Automated CI Failure Handling

This repository includes an automated failure handling system that creates pull requests when CI workflows fail. Here are the security considerations:

### Security Features

- **Limited Permissions**: Failure handler workflows use minimal required permissions
- **No Secret Exposure**: Failed workflow logs are analyzed without exposing secrets
- **Branch Protection**: Automated fix PRs cannot bypass branch protection rules
- **Review Required**: All automated fixes are created as draft PRs requiring manual review

### Permissions Used

The failure handler workflow requires these permissions:
- `contents: write` - Create branches and commits
- `pull-requests: write` - Create pull requests  
- `actions: read` - Read workflow run details
- `issues: write` - Create issues for critical failures

### Security Measures

1. **Token Limitations**: Uses `GITHUB_TOKEN` to prevent recursive workflow triggers
2. **Content Validation**: All generated content is sanitized and validated
3. **No External Dependencies**: Failure analysis runs without external API calls
4. **Audit Trail**: All automated actions are logged and traceable

### Manual Review Points

Automated fixes require manual review for:
- Security-related changes
- Dependency updates
- Configuration modifications
- Infrastructure changes

### Reporting Security Issues

If you discover a security vulnerability in the failure handling system:

1. **Do not** create a public issue
2. Email security concerns to the repository owner
3. Include detailed reproduction steps
4. Allow 90 days for resolution before disclosure

### Supported Versions

The failure handling system supports the latest version of this repository. Security updates are applied to the main branch.

| Component | Supported |
|-----------|-----------|
| failure-handler.yml | ✅ Latest |
| ci-tests.yml | ✅ Latest |
| security-scan.yml | ✅ Latest |

### Security Best Practices

When contributing to or modifying the failure handling system:

- Use least-privilege permissions
- Validate all inputs and outputs
- Never commit secrets or tokens
- Test security measures in isolated environments
- Document security implications of changes