# Automated CI Failure Handler

## Overview

This repository includes a comprehensive automated failure handling system that creates pull requests when CI workflows fail. The system provides intelligent analysis, automated fixes, and proper escalation for critical issues.

## How It Works

### 1. Failure Detection
- Uses `workflow_run` event to detect when workflows complete with failures
- Monitors these workflows: `Build and Publish Images`, `CI Tests`, `Security Scan`
- Triggers only on `failure` conclusion

### 2. Analysis & Fix Generation
- Analyzes failed jobs and steps
- Generates contextual fixes based on failure type
- Creates detailed failure analysis reports
- Applies automated fixes where possible

### 3. PR Creation
- Creates a new branch with descriptive name: `fix/ci-failure-{workflow}-{run-number}-{timestamp}`
- Commits automated fixes and analysis
- Creates PR with comprehensive details and checklist
- Adds appropriate labels: `automated-fix`, `ci-failure`, `needs-review`

### 4. Escalation
- Creates GitHub issues for failures requiring manual intervention
- Sets PRs as draft when manual review is critical
- Provides detailed analysis and suggested next steps

## Supported Failure Types

### Docker Build Failures
- Validates Dockerfile syntax and structure
- Checks for missing security best practices
- Reviews multi-arch build compatibility
- Verifies registry authentication

### Test Failures
- Reviews test dependencies and environment
- Identifies flaky tests and race conditions
- Validates test data and fixtures
- Checks for missing test configurations

### Security Scan Failures
- Updates vulnerability databases
- Reviews security scan configurations
- Creates `.trivyignore` files when appropriate
- Analyzes security policy violations

### General CI Issues
- Validates workflow syntax
- Checks for missing dependencies
- Reviews permission configurations
- Identifies environment-specific issues

## Files Created

### Core Workflows
- `.github/workflows/failure-handler.yml` - Main failure detection and handling
- `.github/workflows/ci-tests.yml` - Comprehensive testing workflow
- `.github/workflows/security-scan.yml` - Multi-layered security scanning

### Documentation
- `.github/SECURITY.md` - Security policy and considerations
- `.github/FAILURE_HANDLER_README.md` - This documentation

### Generated Files (During Failures)
- `FAILURE_ANALYSIS.md` - Detailed failure analysis (in PR branch)
- Various fix files based on failure type

## Configuration

### Required Permissions
```yaml
permissions:
  contents: write        # Create branches and commits
  pull-requests: write   # Create pull requests
  actions: read          # Read workflow details
  issues: write          # Create escalation issues
```

### Environment Requirements
- Uses `GITHUB_TOKEN` (automatically available)
- Requires repository with Issues and PRs enabled
- Works with branch protection rules (PRs still require review)

## Usage Examples

### Automatic Activation
The system activates automatically when monitored workflows fail. No manual intervention needed for activation.

### Manual Testing
To test the failure handler:

1. Force a failure in a monitored workflow
2. Check Actions tab for the failure handler execution
3. Look for automatically created PR and/or issue

### Customization
To monitor additional workflows, edit `failure-handler.yml`:

```yaml
on:
  workflow_run:
    workflows: 
      - "Your Custom Workflow Name"
      - "Another Workflow"
```

## Security Considerations

### Safety Measures
- Uses minimal required permissions
- No exposure of secrets or sensitive data
- All automated fixes require manual review
- Audit trail for all automated actions

### Token Security
- Uses `GITHUB_TOKEN` to prevent recursive triggers
- Limited scope prevents unauthorized access
- No external API calls or data transmission

### Review Process
- All automated PRs require manual review before merge
- Critical failures create issues for immediate attention
- Draft PRs for security-related failures

## Troubleshooting

### Common Issues

**Handler Not Triggering**
- Check that monitored workflow names match exactly
- Verify the workflow actually failed (not cancelled or skipped)
- Ensure repository has required permissions enabled

**PR Creation Fails**
- Check repository settings allow workflow-created PRs
- Verify branch protection doesn't block automated branches
- Review Actions logs for specific error messages

**Analysis Incomplete**
- Large workflows may hit GitHub API rate limits
- Check for network issues during workflow run
- Review workflow logs for timeout errors

### Debug Information
Check these locations for debugging:
- Actions tab > Failed workflow > Summary
- Actions tab > Failure Handler workflow > Logs
- Repository Issues (for escalated failures)

## Contributing

### Adding New Fix Patterns
Edit the `generateFixes()` function in `failure-handler.yml`:

```javascript
if (workflowName.includes('YourPattern')) {
  fixes.push('Your specific fix suggestion');
}
```

### Improving Analysis
Enhance the failure analysis in the `generate-fixes` step to include:
- More specific error pattern recognition
- Additional automated fix applications
- Better categorization of failure types

### Security Updates
All security-related changes must:
- Maintain or improve current security posture
- Include documentation updates
- Pass security review process

## Monitoring & Metrics

### Success Metrics
- Percentage of failures with automated fixes applied
- Time to resolution for different failure types  
- Reduction in manual intervention required

### Monitoring Points
- Failure handler execution success rate
- PR creation success rate
- Time from failure to PR creation
- Manual intervention frequency

The system provides comprehensive logging and can integrate with monitoring solutions for operational insights.

---

*This automated failure handling system improves CI reliability and reduces manual overhead while maintaining security and review standards.*