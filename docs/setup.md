# Setup Guide: Compliance Scanner Configuration

This guide walks you through configuring the github-repo-standards compliance scanner for your organization.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [GitHub Apps Setup](#github-apps-setup)
3. [Environment Configuration](#environment-configuration)
4. [Repository Setup](#repository-setup)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before setting up the compliance scanner, ensure you have:

- **Organization Admin Access** - Required to create GitHub Apps and configure secrets
- **Repository Access** - Admin access to the repository where you'll deploy the scanner
- **GitHub CLI** - `gh` command installed (for testing)

---

## GitHub Apps Setup

The compliance scanner uses **two GitHub Apps** for secure, scoped access:

### 1. Repo Standards Bot (Cross-Repository Scanner)

**Purpose:** Scans all repositories in the organization and creates compliance issues.

**Required Permissions:**
- `administration: read` - Check branch protection and repository settings
- `contents: read` - Clone repositories and read files
- `issues: write` - Create and update compliance issues
- `metadata: read` - Access basic repository metadata

**Installation:** Install on **all repositories** you want to scan (or organization-wide).

**Setup Steps:**
1. Go to **Organization Settings** → **Developer settings** → **GitHub Apps**
2. Click **New GitHub App**
3. Configure:
   - **Name:** `[Your-Org]-Repo-Standards-Bot`
   - **Homepage URL:** `https://github.com/YOUR_ORG/github-repo-standards`
   - **Webhook:** Uncheck "Active"
   - **Permissions:** Set as listed above
   - **Where can this GitHub App be installed?** → "Only on this account"
4. Click **Create GitHub App**
5. Generate and download a **private key**
6. Note the **App ID**
7. Install the app on your organization (select "All repositories" or specific repos)

### 2. Internal Automation App (Report Management)

**Purpose:** Commits compliance reports to the standards repository and manages PRs.

**Required Permissions:**
- `contents: write` - Commit reports and create branches
- `pull_requests: write` - Create and merge PRs
- `metadata: read` - Access basic repository metadata

**Installation:** Install **only on the github-repo-standards repository**.

**Setup Steps:**
1. Go to **Organization Settings** → **Developer settings** → **GitHub Apps**
2. Click **New GitHub App**
3. Configure:
   - **Name:** `[Your-Org]-Internal-Automation`
   - **Homepage URL:** `https://github.com/YOUR_ORG/github-repo-standards`
   - **Webhook:** Uncheck "Active"
   - **Permissions:** Set as listed above
   - **Where can this GitHub App be installed?** → "Only on this account"
4. Click **Create GitHub App**
5. Generate and download a **private key**
6. Note the **App ID**
7. Install the app on **only** the `github-repo-standards` repository

---

## Environment Configuration

The compliance scanner uses **GitHub Secrets** for sensitive credentials and **GitHub Variables** for organization-specific configuration.

### Required Secrets

Navigate to your repository: **Settings** → **Secrets and variables** → **Actions** → **Secrets**

Add the following **Repository secrets**:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `REPO_STANDARDS_APP_ID` | App ID from Step 1 | ID of the Repo Standards Bot app |
| `REPO_STANDARDS_APP_PRIVATE_KEY` | Private key from Step 1 | Private key for Repo Standards Bot (full PEM format) |
| `INTERNAL_AUTOMATION_APP_ID` | App ID from Step 2 | ID of the Internal Automation app |
| `INTERNAL_AUTOMATION_APP_PRIVATE_KEY` | Private key from Step 2 | Private key for Internal Automation (full PEM format) |

**Private Key Format:**
```
-----BEGIN RSA PRIVATE KEY-----
[Your private key content here]
-----END RSA PRIVATE KEY-----
```

### Optional Variables

Navigate to your repository: **Settings** → **Secrets and variables** → **Actions** → **Variables**

Add the following **Repository variables** (all have sensible defaults):

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `STANDARDS_REPO_NAME` | `github-repo-standards` | Name of the repository containing the compliance framework |
| `MAX_PARALLEL_JOBS` | `10` | Maximum number of concurrent compliance check jobs |
| `ARTIFACT_RETENTION_DAYS` | `30` | Days to retain compliance check artifacts |
| `DEFAULT_BRANCH` | `main` | Default branch for PRs |
| `COMPLIANCE_LABEL` | `compliance` | Label applied to compliance issues |
| `CRITICAL_LABEL` | `critical` | Label applied to critical issues |

**When to customize:**
- **STANDARDS_REPO_NAME** - If you've renamed the repository
- **MAX_PARALLEL_JOBS** - Reduce if hitting API rate limits, increase for faster scans
- **ARTIFACT_RETENTION_DAYS** - Adjust based on storage needs
- **DEFAULT_BRANCH** - If your organization uses a different default branch name
- **COMPLIANCE_LABEL** / **CRITICAL_LABEL** - If you want different label names

---

## Repository Setup

### 1. Clone or Fork Repository

```bash
# Option A: Clone the template
git clone https://github.com/YOUR_ORG/github-repo-standards.git
cd github-repo-standards

# Option B: Fork and clone
# Fork via GitHub UI, then:
git clone https://github.com/YOUR_ORG/github-repo-standards.git
cd github-repo-standards
```

### 2. Customize Configuration (Optional)

If you need to customize the compliance standards, edit:

```bash
# Edit compliance standards
vim COMPLIANCE.md

# Edit check scripts
ls compliance/checks/

# Adjust scoring weights and priorities
vim compliance/check-priorities.json
```

### 3. Configure Repository Settings

**Enable Required Features:**
1. Go to **Settings** → **General**
2. Enable **Issues** (for compliance issue creation)
3. Enable **Allow squash merging** (for automated PR merges)

**Configure Branch Protection:**
1. Go to **Settings** → **Branches**
2. Add rule for your default branch (`main`)
3. Recommended settings:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date

### 4. Enable Workflow

The workflow is already configured and will run:
- **Weekly** - Every Monday at 9 AM UTC
- **Manually** - Via workflow dispatch
- **On changes** - When you push to the repository

To trigger the first run:
1. Go to **Actions** tab
2. Select **Repository Compliance Check (Matrix)**
3. Click **Run workflow**
4. Click **Run workflow** button

---

## Verification

### 1. Test GitHub App Permissions

```bash
# Test Repo Standards Bot token generation
gh api /installation/repositories --paginate

# Test Internal Automation App access
gh api /repos/YOUR_ORG/github-repo-standards
```

### 2. Run Local Compliance Check

```bash
# Test individual check
./compliance/checks/check-readme-exists.sh /path/to/repo

# Test all checks manually
for check in compliance/checks/check-*.sh; do
  bash "$check" /path/to/repo
done
```

### 3. Monitor First Workflow Run

1. Go to **Actions** tab
2. Watch the workflow execution
3. Check for errors in each job:
   - `discover-repos` - Should list all repositories
   - `check-compliance` - Should run checks on each repo
   - `aggregate-results` - Should create reports and PR

### 4. Verify Outputs

After successful run:
- ✅ Compliance reports appear in `reports/` directory
- ✅ Issues created in repositories with critical/high failures
- ✅ PR created with report updates (auto-merged)
- ✅ GitHub Actions summary shows results

---

## Troubleshooting

### Common Issues

#### 1. "Resource not accessible by integration"

**Cause:** GitHub App missing required permissions or not installed on repository.

**Fix:**
1. Check GitHub App installation:
   - Repo Standards Bot → Should be installed on all repos
   - Internal Automation → Should be installed on standards repo only
2. Verify permissions match the required list above
3. Reinstall the app if needed

#### 2. "Issues are disabled"

**Cause:** Target repository has issues disabled.

**Fix:**
1. Go to repository **Settings** → **General**
2. Enable **Issues** feature
3. Re-run workflow or wait for next scheduled run

#### 3. "API rate limit exceeded"

**Cause:** Too many parallel jobs or high API usage.

**Fix:**
1. Reduce `MAX_PARALLEL_JOBS` variable (try `5` or `3`)
2. Add delays between API calls in check scripts
3. Spread out check schedules across different times

#### 4. "Failed to create PR"

**Cause:** Branch protection or permissions issue.

**Fix:**
1. Verify Internal Automation App has `contents: write` permission
2. Check branch protection rules allow app to push
3. Ensure app token has `pull_requests: write` permission

#### 5. "Private key format error"

**Cause:** Private key not in correct PEM format or has extra characters.

**Fix:**
1. Ensure private key includes header and footer:
   ```
   -----BEGIN RSA PRIVATE KEY-----
   ...
   -----END RSA PRIVATE KEY-----
   ```
2. Remove any extra whitespace before/after
3. Ensure no line breaks are corrupted

### Debug Mode

Enable debug logging:

```bash
# Add to workflow environment variables
ACTIONS_STEP_DEBUG: true
ACTIONS_RUNNER_DEBUG: true
```

### Getting Help

1. **Check Workflow Logs:**
   - Actions tab → Failed workflow → Click on failed step
   - Look for error messages and stack traces

2. **Review GitHub App Installation:**
   - Organization Settings → GitHub Apps → Installed Apps
   - Check permissions and installation scope

3. **Test Locally:**
   - Run compliance checks manually
   - Use `--format json` for detailed output
   - Check individual check scripts

4. **API Permissions Reference:**
   - See `API_PERMISSIONS.md` for detailed API usage per check
   - Cross-reference with GitHub App permissions

---

## Next Steps

After successful setup:

1. **Review Compliance Reports** - Check `reports/` directory
2. **Address Critical Issues** - Review issues in repositories
3. **Customize Standards** - Edit `COMPLIANCE.md` for your needs
4. **Add Fix Scripts** - Use `compliance/scripts/` for automated fixes
5. **Schedule Adjustments** - Modify cron schedule if needed

---

## Additional Resources

- [COMPLIANCE.md](../COMPLIANCE.md) - Compliance standards definition
- [API_PERMISSIONS.md](../API_PERMISSIONS.md) - Detailed API permissions reference
- [GITHUB_APP_setup.md](../GITHUB_APP_setup.md) - GitHub App creation details
- [SECURITY.md](../SECURITY.md) - Security considerations
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contributing guidelines

---

**Last Updated:** 2025-12-10
