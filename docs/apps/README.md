# GitHub Apps for Compliance Framework

This compliance framework uses a **two-app architecture** for security and separation of concerns.

> **Architecture Decision:** See [ADR-0004: Two-App Architecture](../adr/0004-two-app-architecture.md) for the rationale behind this design.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Organization Repositories                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────┐  │
│  │ Repo 1  │  │ Repo 2  │  │ Repo 3  │  │ github-repo- │  │
│  │         │  │         │  │         │  │  standards   │  │
│  └────┬────┘  └────┬────┘  └────┬────┘  └──────┬───────┘  │
│       │            │            │               │           │
│   ┌───▼────────────▼────────────▼───────────────▼───┐      │
│   │     App 1: Repo Standards Bot (Public)          │      │
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
│   │  App 2: Internal Automation (Private)            │      │
│   │  ✓ Installed ONLY on github-repo-standards      │      │
│   │  ✓ Write access to commit reports                │      │
│   │  ✓ Can create and merge PRs                      │      │
│   └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

## Why Two Apps?

### Security & Least Privilege
- **Repo Standards Bot** needs read access to many repos but shouldn't modify code
- **Internal Automation** needs write access but only to one repo
- Separating concerns prevents security issues if credentials are compromised

### Clear Boundaries
- Cross-repository scanning is separate from report generation
- Different permission scopes for different purposes
- Easier to audit and manage access

## App 1: Repo Standards Bot

**Purpose:** Cross-repository compliance scanning and monitoring

**Location:** `apps/repo-standards/`

**Permissions:**
- `administration: read` - Check branch protection and repo settings
- `contents: read` - Clone and scan repository files
- `issues: write` - Create/update/close compliance issues
- `metadata: read` - Basic repository information

**Installation:** Install on **ALL repositories** to monitor

**Used In:**
- `discover-repos` job - List repositories to scan
- `check-compliance` job - Clone and scan each repository
- Issue creation/management - Create issues in failing repos

**Security:**
- Read-only for repository contents
- Can create issues but cannot modify code
- Broad installation across organization

## App 2: Internal Automation

**Purpose:** Automated report generation and PR management

**Location:** `apps/internal-automation/`

**Permissions:**
- `contents: write` - Create branches and commit reports
- `pull_requests: write` - Create and manage PRs
- `metadata: read` - Basic repository information

**Installation:** Install **ONLY on github-repo-standards** repository

**Used In:**
- `aggregate-results` job - Commit reports and create PRs
- Auto-merge compliance report PRs

**Security:**
- Write access limited to single repository
- Can create and merge PRs automatically
- Private to organization
- Branch protection bypass for auto-merge

## Setup Instructions

See individual app READMEs for detailed setup:
- [Repo Standards Bot Setup](repo-standards/README.md)
- [Internal Automation Setup](internal-automation/README.md)

### Quick Start

1. Create both apps using their manifests
2. Save credentials as GitHub Secrets
3. Install App 1 on all repos, App 2 only on github-repo-standards
4. Configure branch protection bypass for App 2

See individual app directories for complete instructions.

## Security Best Practices

✅ **DO:**
- Use App 1 for cross-repository read operations
- Use App 2 for github-repo-standards write operations
- Keep App 2 credentials private
- Review App 1 installations regularly

❌ **DON'T:**
- Install App 2 on multiple repositories
- Give App 1 write access to contents
- Share App 2 credentials
- Use GITHUB_TOKEN for cross-repository operations
