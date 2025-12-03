# ADR-0002: GitHub App for Cross-Repository Access

**Date:** 2025-11-29
**Status:** Accepted
**Deciders:** labrats-work

## Context

The compliance workflow needed to:
- Clone multiple `my-*` repositories
- Read their contents for checking
- Create issues in repositories that fail compliance

GITHUB_TOKEN only provides access to the current repository (github-repo-standards), not other repositories.

**Alternatives considered:**
1. Personal Access Token (PAT)
2. Deploy keys per repository
3. GitHub App

## Decision

Use a **GitHub App** for cross-repository access:

- **App Name:** My-Repos Compliance Checker
- **App ID:** 2376728
- **Permissions:** contents:read, issues:write
- **Installation:** On all my-* repositories

**Security model:**
- GITHUB_TOKEN: github-repo-standards operations (checkout, commit, push)
- GitHub App token: Cross-repo reads and issue creation

## Consequences

### Positive

- **Scoped permissions** - Only what's needed (read + issues)
- **No expiration** - Unlike PATs that expire
- **Auditable** - App actions clearly identified
- **Revocable** - Can be uninstalled anytime
- **Fine-grained** - Can install on specific repos only
- **Clear separation** - Different tokens for different purposes

### Negative

- **Additional setup** - Requires app creation and installation
- **Secret management** - APP_ID and APP_PRIVATE_KEY in secrets
- **Token generation** - Must use actions/create-github-app-token
- **Complexity** - More moving parts than simple PAT

### Neutral

- **Repository dependency** - my-gh-apps repo for app creation tools
- **Documentation burden** - Need to document app setup process

## References

- [my-gh-apps](https://github.com/labrats-work/my-gh-apps) - GitHub App creation toolkit
- [GITHUB_APP_SETUP.md](../../GITHUB_APP_SETUP.md) - Setup instructions
- [GitHub Apps Documentation](https://docs.github.com/en/apps)
- Workflow: `.github/workflows/compliance-check.yml`
