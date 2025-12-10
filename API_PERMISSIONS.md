# GitHub API Permissions Required for Compliance Checks

This document details the GitHub API permissions required for each compliance check.

## Summary

For a GitHub App to run all compliance checks, it needs the following permissions:

- **Repository permissions:**
  - `Administration`: **read** (for COMP-016, COMP-017, COMP-018)
  - `Contents`: **read** (for file-based checks via git clone)
  - `Metadata`: **read** (automatically included)

## Compliance Checks by Permission

### File-Based Checks (Contents: read)

These checks only require repository contents access (via git clone):

#### COMP-001: README.md Exists
- **Priority:** CRITICAL (10 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies README.md file exists in repository root
- **API Calls:** None (file system check only)

#### COMP-002: LICENSE File Exists
- **Priority:** CRITICAL (10 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies LICENSE file exists in repository root
- **API Calls:** None (file system check only)

#### COMP-003: .gitignore Exists
- **Priority:** CRITICAL (10 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies .gitignore file exists and is not empty
- **API Calls:** None (file system check only)

#### COMP-004: CLAUDE.md Exists
- **Priority:** CRITICAL (10 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies CLAUDE.md file exists with content
- **API Calls:** None (file system check only)

#### COMP-005: README Structure
- **Priority:** HIGH (5 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies README contains required sections (Purpose, Quick Start, Structure)
- **API Calls:** None (file system check only)

#### COMP-006: docs/ Directory
- **Priority:** HIGH (5 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies docs/ directory exists with README.md
- **API Calls:** None (file system check only)

#### COMP-007: GitHub Workflows
- **Priority:** HIGH (5 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies .github/workflows/ directory contains workflow files
- **API Calls:** None (file system check only)

#### COMP-008: Issue Templates
- **Priority:** MEDIUM (2 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies .github/ISSUE_TEMPLATE/ directory exists
- **API Calls:** None (file system check only)

#### COMP-009: ADR Pattern
- **Priority:** MEDIUM (2 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies docs/adr/ contains ADR files (format: NNNN-*.md)
- **API Calls:** None (file system check only)

#### COMP-010: .claude/ Configuration
- **Priority:** MEDIUM (2 points)
- **API Permission:** Contents: read
- **What it checks:** Verifies .claude/ directory exists
- **API Calls:** None (file system check only)

#### COMP-011: CONTRIBUTING.md
- **Priority:** LOW (1 point)
- **API Permission:** Contents: read
- **What it checks:** Verifies CONTRIBUTING.md file exists
- **API Calls:** None (file system check only)

#### COMP-012: SECURITY.md
- **Priority:** LOW (1 point)
- **API Permission:** Contents: read
- **What it checks:** Verifies SECURITY.md file exists
- **API Calls:** None (file system check only)

#### COMP-013: MkDocs Configuration
- **Priority:** LOW (1 point)
- **API Permission:** Contents: read
- **What it checks:** Verifies mkdocs.yml or mkdocs.yaml exists
- **API Calls:** None (file system check only)

#### COMP-014: ADR Quality
- **Priority:** MEDIUM (2 points)
- **API Permission:** Contents: read
- **What it checks:** Validates ADR files have required sections (Status, Date, Context, Decision, Alternatives, Consequences)
- **API Calls:** None (file system check only)

#### COMP-015: Deprecated Actions
- **Priority:** HIGH (5 points)
- **API Permission:** Contents: read
- **What it checks:** Scans workflow files for deprecated GitHub Actions versions
- **API Calls:** None (file system check only)

### API-Based Checks (Administration: read)

These checks require GitHub API access with Administration permission:

#### COMP-016: Branch Protection
- **Priority:** HIGH (5 points)
- **API Permission:** Administration: **read**
- **What it checks:** Verifies main/master branch has protection rules enabled
- **API Endpoint:** `GET /repos/{owner}/{repo}/branches/{branch}/protection`
- **API Documentation:** https://docs.github.com/en/rest/branches/branch-protection#get-branch-protection
- **What it validates:**
  - Branch protection is enabled
  - Preferably with required pull request reviews

#### COMP-017: Repository Settings
- **Priority:** HIGH (5 points)
- **API Permission:** Administration: **read**
- **What it checks:** Validates repository settings follow best practices
- **API Endpoints:**
  - `GET /repos/{owner}/{repo}` - Repository metadata
  - `GET /repos/{owner}/{repo}/vulnerability-alerts` - Security alerts status
- **API Documentation:**
  - https://docs.github.com/en/rest/repos/repos#get-a-repository
  - https://docs.github.com/en/rest/repos/repos#check-if-vulnerability-alerts-are-enabled-for-a-repository
- **What it validates:**
  - Issues are enabled (`has_issues: true`)
  - Delete branch on merge is enabled (`delete_branch_on_merge: true`)
  - At least one merge method is allowed (squash, merge commit, or rebase)
  - Vulnerability alerts are enabled (optional check)

#### COMP-018: Default Branch
- **Priority:** HIGH (5 points)
- **API Permission:** Administration: **read**
- **What it checks:** Verifies repository default branch is set to 'main'
- **API Endpoint:** `GET /repos/{owner}/{repo}`
- **API Documentation:** https://docs.github.com/en/rest/repos/repos#get-a-repository
- **What it validates:**
  - `default_branch` field equals "main"

## GitHub App Configuration

### Minimal Permissions

For a GitHub App to run compliance checks, configure these permissions:

```json
{
  "permissions": {
    "administration": "read",
    "contents": "read",
    "metadata": "read"
  }
}
```

### Why Administration: read?

The `Administration` permission with `read` access allows the app to:
- View repository settings (COMP-017, COMP-018)
- Check branch protection rules (COMP-016)
- Access security and analysis settings

**Note:** This permission does NOT allow:
- Modifying repository settings (requires `write` access)
- Changing branch protection (requires `write` access)
- Deleting the repository (requires `write` access)

### Alternative: Using GITHUB_TOKEN

When running in GitHub Actions, the default `GITHUB_TOKEN` automatically has:
- Full repository access for the current repository
- Limited access to other repositories in the organization

For cross-repository compliance checking, you should use a GitHub App with appropriate permissions instead of personal access tokens.

## Troubleshooting Permission Issues

### "API error" or "Unable to check" Messages

If you see these errors in compliance reports:

```
COMP-016: Unable to check branch protection (API error)
COMP-017: Unable to fetch repository information (API error)
COMP-018: Unable to fetch repository information (API error)
```

**Possible causes:**

1. **Missing Administration Permission**
   - Ensure the GitHub App has `Administration: read` permission
   - Reinstall the app if permissions were updated

2. **App Not Installed on Repository**
   - The GitHub App must be installed on each repository being checked
   - Verify installation in organization settings

3. **Rate Limiting**
   - GitHub API has rate limits (5,000 requests/hour for apps)
   - Checks should handle rate limiting gracefully

4. **Repository Archived**
   - Archived repositories may have limited API access
   - These should be skipped in compliance checks

5. **Network Issues**
   - Temporary network problems can cause API failures
   - Retry logic should be implemented

### Verifying Permissions

To verify your GitHub App has correct permissions:

```bash
# Check app installation
gh api /repos/{owner}/{repo}/installation

# Test repository access
gh api /repos/{owner}/{repo}

# Test branch protection access
gh api /repos/{owner}/{repo}/branches/main/protection
```

## Permission Changes

If you need to add or modify permissions:

1. Update the GitHub App manifest or settings
2. Users/organizations will be prompted to approve new permissions
3. The app may need to be reinstalled on repositories
4. Update this documentation

## Security Considerations

- **Principle of Least Privilege**: Only request permissions actually needed
- **Read-Only Access**: Compliance checks should only need `read` access
- **Token Storage**: Never commit GitHub App credentials to version control
- **Audit Logging**: GitHub automatically logs all API access
- **Permission Reviews**: Regularly review and minimize required permissions

## References

- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [GitHub Apps Permissions](https://docs.github.com/en/rest/apps/permissions)
- [Creating a GitHub App](https://docs.github.com/en/apps/creating-github-apps)
- [Repository Permissions for GitHub Apps](https://docs.github.com/en/rest/apps/permissions#repository-permissions-for-github-apps)
