# Setup Guide: Compliance Scanner Configuration

This guide walks you through configuring the github-repo-standards compliance scanner for your organization.

## Quick Start (Recommended)

**Use the automated setup script for fastest setup:**

```bash
cd github-repo-standards
./scripts/setup-compliance-framework.sh
```

The script will guide you through:
- Creating GitHub Apps using the manifest flow
- Installing apps on appropriate repositories
- Configuring all required secrets and variables
- Applying compliance fixes to the repository
- Running a test compliance check

**Continue reading for manual setup** or if you need to customize the configuration.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Automated Setup (Recommended)](#automated-setup-recommended)
3. [Manual Setup](#manual-setup)
   - [GitHub Apps Setup](#github-apps-setup)
   - [Environment Configuration](#environment-configuration)
   - [Repository Setup](#repository-setup)
4. [Verification](#verification)
5. [Common Issues](#common-issues)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before setting up the compliance scanner, ensure you have:

- **Organization Admin Access** - Required to create GitHub Apps and configure secrets
- **Repository Access** - Admin access to the repository where you'll deploy the scanner
- **GitHub CLI** - `gh` command installed and authenticated (`gh auth login`)
- **jq** - JSON processor (`sudo apt-get install jq` or `brew install jq`)
- **(Optional) github-app-tools** - For easier app creation via manifest flow

---

## Automated Setup (Recommended)

The automated setup script streamlines the entire configuration process.

### Prerequisites for Automated Setup

1. **Clone github-app-tools** (optional but recommended):
   ```bash
   cd /path/to/your/repos
   git clone https://github.com/labrats-work/github-app-tools.git
   ```

2. **Ensure github-app-tools is a sibling directory** to github-repo-standards:
   ```
   /your/repos/
   ├── github-app-tools/
   └── github-repo-standards/
   ```

### Running the Setup Script

```bash
cd github-repo-standards
./scripts/setup-compliance-framework.sh
```

The script will:
1. ✅ Verify prerequisites (gh CLI, jq, authentication)
2. ✅ Create GitHub App manifests for your organization
3. ✅ Guide you through app creation using manifest flow
4. ✅ Configure all required secrets (4 total)
5. ✅ Set repository variables (if needed)
6. ✅ Apply compliance fixes (merge methods, branch protection)
7. ✅ Trigger a test compliance check

**Estimated time:** 10-15 minutes

Once complete, skip to [Verification](#verification).

---

## Manual Setup

If you prefer manual setup or need custom configuration, follow these steps:

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

### Repository Variables

Navigate to your repository: **Settings** → **Secrets and variables** → **Actions** → **Variables**

#### Required Variables

| Variable Name | Required When | Example Value | Description |
|---------------|---------------|---------------|-------------|
| `STANDARDS_REPO_NAME` | Repository name is NOT `github-repo-standards` | `my-compliance-repo` | **⚠️ CRITICAL**: Name of the repository containing the compliance framework |

**⚠️ IMPORTANT**: If you renamed the repository from `github-repo-standards`, you **MUST** set this variable or the workflow will fail.

#### Optional Variables (All Have Defaults)

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `MAX_PARALLEL_JOBS` | `10` | Maximum number of concurrent compliance check jobs |
| `ARTIFACT_RETENTION_DAYS` | `30` | Days to retain compliance check artifacts |
| `DEFAULT_BRANCH` | `main` | Default branch for PRs |
| `COMPLIANCE_LABEL` | `compliance` | Label applied to compliance issues |
| `CRITICAL_LABEL` | `critical` | Label applied to critical issues |

**When to customize:**
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

## Common Issues

This section documents issues discovered during setup and their solutions.

### Issue 1: Workflow Fails - "No changes to commit" (Reports Not Generated)

**Symptom:**
- `aggregate-results` job completes successfully
- But no PR is created
- Log shows "No changes to commit"
- `reports/` directory stays empty in git

**Root Cause:**
The template repository's `.gitignore` excluded compliance reports:
```gitignore
reports/*.json
reports/*.md
```

This prevented `git add reports/` from staging the generated files, causing PR creation to be skipped.

**Solution:**
1. **Option A (Recommended)** - Use the automated setup script which handles this
2. **Option B (Manual)** - Remove the reports gitignore lines:
   ```bash
   # Edit .gitignore and remove:
   # reports/*.json
   # reports/*.md

   git add .gitignore
   git commit -m "fix: Allow committing compliance reports"
   git push
   ```

**Prevention:**
- PR [#6](https://github.com/labrats-work/github-repo-standards/pull/6) fixes this in the template

---

### Issue 2: Workflow Fails - "Not Found" on Internal Automation App

**Symptom:**
- `aggregate-results` job fails with error:
  ```
  Failed to create token for "github-repo-standards" (attempt 1): Not Found
  ```
- Internal Automation App token generation fails

**Root Cause:**
`STANDARDS_REPO_NAME` variable not set when repository was renamed from default `github-repo-standards`.

The workflow tries to access `github-repo-standards` but the actual repo has a different name.

**Solution:**
Set the `STANDARDS_REPO_NAME` variable:
```bash
gh variable set STANDARDS_REPO_NAME --body "YOUR-ACTUAL-REPO-NAME" \
  --repo YOUR_ORG/YOUR-ACTUAL-REPO-NAME
```

**Prevention:**
- The automated setup script sets this automatically
- Now documented as **REQUIRED** when repository name ≠ `github-repo-standards`

---

### Issue 3: GitHub App Names Cannot Start with "GitHub"

**Symptom:**
- App creation fails with error: "Name should not begin with 'GitHub' or 'Gist'"

**Root Cause:**
GitHub reserves app names starting with "GitHub" or "Gist" for official apps.

**Solution:**
Use a different prefix for app names:
- ❌ Bad: `github-repo-standards-bot`
- ✅ Good: `your-org-repo-standards-bot`
- ✅ Good: `test-repo-standards-bot`

**Prevention:**
- Automated setup script uses `${ORG}-repo-standards-bot` format
- Documentation updated to show correct naming

---

### Issue 4: Branch Protection Check Fails Despite Having Rulesets

**Symptom:**
- `COMP-016` (Branch Protection) check fails
- `COMP-019` (Branch Rulesets) check passes
- Repository has modern rulesets configured

**Root Cause:**
Check script looks for **classic branch protection**, not modern **rulesets**.
GitHub has two systems:
- **Classic branch protection** (older, being checked by COMP-016)
- **Branch rulesets** (newer, checked by COMP-019)

**Solution:**
Enable classic branch protection alongside rulesets:
```bash
gh api -X PUT repos/ORG/REPO/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": null,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

Or use the fix script:
```bash
# Enable both protection types
GITHUB_ORG=your-org ./compliance/scripts/fix-comp-016-branch-protection.sh REPO_NAME
```

**Prevention:**
- Automated setup script applies both protection types
- Consider deprecating COMP-016 in favor of COMP-019 only

---

### Issue 5: No Merge Methods Enabled (COMP-017 Failure)

**Symptom:**
- `COMP-017` (Repository Settings) check fails
- Error: "No merge methods enabled"

**Root Cause:**
Repository has all merge methods disabled:
- Merge commits: disabled
- Squash merging: disabled
- Rebase merging: disabled

**Solution:**
Enable at least one merge method (squash recommended):
```bash
GITHUB_ORG=your-org ./compliance/scripts/fix-comp-017-repo-settings.sh REPO_NAME
```

Or manually via GitHub UI:
1. Go to **Settings** → **General** → **Pull Requests**
2. Enable at least one merge method:
   - ✅ **Allow squash merging** (recommended)
   - ✅ **Delete branch after merge** (cleanup)

**Prevention:**
- Automated setup script enables squash merge
- Template should ship with squash merge enabled

---

## Troubleshooting

### Debugging Workflow Failures

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

**Last Updated:** 2025-12-11
