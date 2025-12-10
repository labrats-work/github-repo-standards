# ADR-0004: Two-App Architecture for Compliance Framework

**Date:** 2025-12-09
**Status:** Accepted
**Deciders:** Compliance framework maintainers

## Context

The compliance framework needs to perform two distinct sets of operations:

1. **Cross-repository operations** - Reading files from many repositories across the organization to run compliance checks and create issues in failing repositories
2. **Report automation** - Writing compliance reports, creating branches, committing files, and creating/merging pull requests in the github-repo-standards repository

Initially, we considered using a single GitHub App with broad permissions across all repositories. However, this posed significant security concerns:

- A compromised app token with write access to all repositories would be catastrophic
- The principle of least privilege suggests limiting permissions to only what's necessary for each operation
- Different operations have fundamentally different security profiles
- Audit trails become muddied when one app performs both read and write operations

## Decision

We will use a **two-app architecture** with clearly separated responsibilities:

### App 1: Repository Standards Bot (Public)
- **Purpose:** Cross-repository compliance scanning and monitoring
- **Installation:** ALL repositories in the organization
- **Permissions:**
  - `administration: read` - Check branch protection and repo settings
  - `contents: read` - Clone and scan repository files
  - `issues: write` - Create/update/close compliance issues
  - `metadata: read` - Basic repository information
- **Visibility:** Public (can be installed by any organization)

### App 2: Internal Automation (Private)
- **Purpose:** Automated report generation and PR management
- **Installation:** ONLY the github-repo-standards repository
- **Permissions:**
  - `contents: write` - Create branches and commit reports
  - `pull_requests: write` - Create and manage PRs
  - `metadata: read` - Basic repository information
- **Visibility:** Private (organization-specific)

### Clear Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│                    Organization Repositories                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────┐  │
│  │ Repo 1  │  │ Repo 2  │  │ Repo 3  │  │ github-repo- │  │
│  │         │  │         │  │         │  │  standards   │  │
│  └────┬────┘  └────┬────┘  └────┬────┘  └──────┬───────┘  │
│       │            │            │               │           │
│   ┌───▼────────────▼────────────▼───────────────▼───┐      │
│   │     App 1: Repo Standards Bot (Read-only)      │      │
│   │     ✓ Installed on ALL repositories             │      │
│   │     ✓ Read-only access to scan files            │      │
│   │     ✓ Write access to create issues             │      │
│   └──────────────────────────────────────────────────┘      │
│                                                              │
│                      ┌───────────────────┐                  │
│                      │ github-repo-      │                  │
│                      │  standards        │                  │
│                      └─────────┬─────────┘                  │
│                                │                             │
│   ┌────────────────────────────▼─────────────────────┐      │
│   │  App 2: Internal Automation (Write access)      │      │
│   │  ✓ Installed ONLY on github-repo-standards      │      │
│   │  ✓ Write access to commit reports                │      │
│   │  ✓ Can create and merge PRs                      │      │
│   └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Consequences

### Positive

- **Enhanced Security** - Write access limited to single repository; compromised App 1 token cannot modify code
- **Least Privilege** - Each app has only the permissions it needs for its specific purpose
- **Clear Audit Trail** - Easy to track which app performed which operations
- **Easier Debugging** - Clear separation makes troubleshooting simpler
- **Reduced Blast Radius** - Security incident with App 1 doesn't affect report automation
- **Better Access Control** - App 2 credentials can be more tightly controlled (organization secrets only)
- **Flexibility** - App 1 can be published for other organizations to use without exposing write operations

### Negative

- **Increased Complexity** - Two apps to create, configure, and maintain instead of one
- **More Secrets** - Need to manage credentials for both apps (4 secrets total: 2x APP_ID, 2x PRIVATE_KEY)
- **Setup Overhead** - Users must install two apps instead of one
- **Documentation Burden** - Need to clearly explain why two apps and which does what

### Neutral

- **Workflow Changes** - Different jobs in GitHub Actions use different app tokens (already necessary even with one app to prevent recursion)
- **Token Generation** - Both apps require the same token generation pattern in workflows
- **Installation Management** - Need to ensure App 1 is installed on all repos, App 2 only on github-repo-standards

## References

- [GitHub Apps Documentation](https://docs.github.com/en/apps)
- [Principle of Least Privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege)
- [apps/README.md](../apps/README.md) - Implementation details
- [apps/repo-standards/README.md](../apps/repo-standards.md) - App 1 setup
- [apps/internal-automation/README.md](../apps/internal-automation.md) - App 2 setup
- ADR-0002: GitHub App for Cross-Repo Access (original single-app decision)

## Alternatives Considered

### Single App with Broad Permissions
- **Rejected** - Security risk too high; single compromised token could modify all repositories
- Would need `contents: write` on all repositories
- Violates principle of least privilege

### Personal Access Token (PAT)
- **Rejected** - Tied to individual user account; not suitable for automation
- Harder to audit and rotate
- Token scope cannot be limited to specific repositories

### GITHUB_TOKEN Only
- **Rejected** - Cannot access other repositories; only works within same repository
- Would require running compliance checks from each repository individually
- Cannot create issues in other repositories

### Three Apps (Read, Issue Management, Write)
- **Rejected** - Over-engineered; issues are low-risk write operations
- Additional complexity not justified by security benefit
- Issue creation is part of the scanning workflow

## Migration Notes

Organizations using the previous single-app architecture should:

1. Create App 2 (Internal Automation) using the provided manifest
2. Install App 2 only on github-repo-standards repository
3. Update workflow secrets with App 2 credentials
4. Verify App 1 permissions are read-only for contents
5. Test both apps work correctly in workflow
6. Retire old app with write permissions

## Security Best Practices

When implementing this architecture:

✅ **DO:**
- Use App 1 for cross-repository read operations
- Use App 2 for github-repo-standards write operations
- Keep App 2 credentials in organization secrets only
- Review App 1 installations regularly
- Rotate private keys periodically

❌ **DON'T:**
- Install App 2 on multiple repositories
- Give App 1 write access to contents
- Share App 2 credentials outside secure channels
- Use GITHUB_TOKEN for cross-repository operations
- Mix app tokens (use App 1 token for App 1 operations, etc.)
