# Claude Code Setup

## Required Configuration

1. **Add OAuth Token**:
   - Go to Repository Settings → Secrets and variables → Actions
   - Add secret: CLAUDE_CODE_OAUTH_TOKEN
   - Get token from: https://claude.ai/settings

2. **Verify Permissions**:
   - Contents: read
   - Pull requests: write
   - Issues: write
   - Actions: read

## Troubleshooting

- **401 Errors**: Check token is valid and not expired
- **Workflow not triggering**: Ensure @claude mentions are in comments
- **Permission errors**: Verify all required permissions are set
