# Upgrade Guide: v1.x to v2.0 (Environment-Based Configuration)

**Version:** 2.0.0
**Date:** 2025-12-10
**Breaking Change:** Yes

---

## ⚠️ Breaking Change Notice

Version 2.0 introduces **environment-based configuration** for the compliance scanner. This is a **breaking change** that requires manual configuration before workflows will run successfully.

**What Changed:**
- Workflow now uses GitHub environment variables and secrets
- Hardcoded values (like `github-repo-standards`, `10` parallel jobs) moved to environment variables
- All values have sensible defaults, but **secrets are still required**

**Impact:**
- ❌ Existing workflows will **fail** if secrets are not configured
- ✅ Once configured, scanner is more flexible and portable
- ✅ Backward compatible behavior available through defaults

---

## Who Needs to Upgrade?

**You need to upgrade if:**
- You're currently running the compliance scanner
- You have an existing installation of github-repo-standards
- You want to pull the latest changes from the main repository

**You can skip this if:**
- This is a fresh installation (use [SETUP.md](SETUP.md) instead)
- You're not using the automated workflows

---

## Pre-Upgrade Checklist

Before starting the upgrade, gather this information:

- [ ] **GitHub App Credentials** - You should already have these from initial setup:
  - Repo Standards Bot: App ID and Private Key
  - Internal Automation App: App ID and Private Key

- [ ] **Current Configuration** - Note any customizations:
  - Repository name (if you renamed it)
  - Number of parallel jobs (if you modified workflow)
  - Custom label names (if you changed them)

- [ ] **Backup** - Create a backup of your workflow file:
  ```bash
  cp .github/workflows/compliance-check.yml .github/workflows/compliance-check.yml.backup
  ```

---

## Migration Steps

### Step 1: Locate Your GitHub App Credentials

If you don't have your App IDs and Private Keys readily available:

**Find App IDs:**
1. Go to your **Organization Settings** → **Developer settings** → **GitHub Apps**
2. Click on each app (Repo Standards Bot, Internal Automation)
3. Note the **App ID** shown in the "About" section

**Find or Regenerate Private Keys:**
1. In the same GitHub App settings page
2. Scroll to **Private keys** section
3. If you saved the original key, use it
4. If not, click **Generate a private key** and download the new `.pem` file

### Step 2: Add Required Secrets

Navigate to your repository: **Settings** → **Secrets and variables** → **Actions** → **Secrets**

Click **New repository secret** and add each of these:

| Secret Name | Where to Find | Format |
|-------------|---------------|--------|
| `REPO_STANDARDS_APP_ID` | Repo Standards Bot → App ID | Number (e.g., `123456`) |
| `REPO_STANDARDS_APP_PRIVATE_KEY` | Repo Standards Bot → Private key file | Full PEM format (see below) |
| `INTERNAL_AUTOMATION_APP_ID` | Internal Automation App → App ID | Number (e.g., `123457`) |
| `INTERNAL_AUTOMATION_APP_PRIVATE_KEY` | Internal Automation App → Private key file | Full PEM format (see below) |

**Private Key Format:**

When adding the private key, copy the **entire contents** of the `.pem` file:

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
[multiple lines]
...
-----END RSA PRIVATE KEY-----
```

**Important:** Include the `-----BEGIN` and `-----END` lines!

### Step 3: Add Optional Variables (If Needed)

Navigate to: **Settings** → **Secrets and variables** → **Actions** → **Variables**

**You only need to add variables if you want to customize defaults.** If you're happy with the defaults, skip this step.

| Variable Name | Default Value | When to Customize |
|---------------|---------------|-------------------|
| `STANDARDS_REPO_NAME` | `github-repo-standards` | If you renamed the repository |
| `MAX_PARALLEL_JOBS` | `10` | If you want to adjust parallelism |
| `ARTIFACT_RETENTION_DAYS` | `30` | If you want different retention |
| `DEFAULT_BRANCH` | `main` | If your default branch isn't `main` |
| `COMPLIANCE_LABEL` | `compliance` | If you want different label names |
| `CRITICAL_LABEL` | `critical` | If you want different label names |

**Example - If you renamed the repository:**
1. Click **New repository variable**
2. Name: `STANDARDS_REPO_NAME`
3. Value: `your-custom-name`
4. Click **Add variable**

### Step 4: Pull Latest Changes

```bash
cd /path/to/github-repo-standards
git fetch origin
git pull origin main
```

Or if you're on a specific branch:

```bash
git fetch origin
git checkout main
git pull origin main
```

### Step 5: Verify Configuration

Run this verification script to check your setup:

```bash
# Check if secrets are configured (you can't read their values, but can verify they exist)
gh variable list --repo YOUR_ORG/github-repo-standards
gh secret list --repo YOUR_ORG/github-repo-standards
```

Expected output should include:
- **Secrets:** `REPO_STANDARDS_APP_ID`, `REPO_STANDARDS_APP_PRIVATE_KEY`, `INTERNAL_AUTOMATION_APP_ID`, `INTERNAL_AUTOMATION_APP_PRIVATE_KEY`
- **Variables:** (Any you configured, or empty if using defaults)

### Step 6: Test the Workflow

Trigger a manual workflow run to test:

```bash
gh workflow run compliance-check.yml --repo YOUR_ORG/github-repo-standards
```

Monitor the run:

```bash
gh run watch --repo YOUR_ORG/github-repo-standards
```

**Expected Results:**
- ✅ Workflow starts successfully
- ✅ `discover-repos` job completes
- ✅ `check-compliance` jobs run in parallel
- ✅ `aggregate-results` creates reports and PR

**If it fails:**
- Check workflow logs for error messages
- Verify secrets are configured correctly
- See [Troubleshooting](#troubleshooting) section below

### Step 7: Clean Up Backup

Once you've verified the workflow works:

```bash
rm .github/workflows/compliance-check.yml.backup
```

---

## Verification Checklist

After upgrade, verify everything works:

- [ ] Workflow runs without errors
- [ ] Repository discovery works (lists all repos)
- [ ] Compliance checks execute on all repositories
- [ ] Reports are generated in `reports/` directory
- [ ] PR is created with reports (if changes exist)
- [ ] Issues are created in failing repositories
- [ ] No "missing secret" errors in logs

---

## Troubleshooting

### Error: "Context access might be invalid: REPO_STANDARDS_APP_ID"

**Cause:** Secret not configured or wrong name.

**Fix:**
1. Go to **Settings** → **Secrets and variables** → **Actions** → **Secrets**
2. Verify secret name exactly matches: `REPO_STANDARDS_APP_ID` (case-sensitive)
3. Ensure it's a **repository secret**, not an environment secret
4. Re-run workflow

### Error: "Resource not accessible by integration"

**Cause:** GitHub App not installed or missing permissions.

**Fix:**
1. Check GitHub App is still installed on repositories
2. Verify app permissions match requirements (see [SETUP.md](SETUP.md#github-apps-setup))
3. Reinstall app if needed

### Error: "Failed to create token: Bad credentials"

**Cause:** Private key format incorrect or corrupted.

**Fix:**
1. Regenerate private key from GitHub App settings
2. Copy **entire** `.pem` file contents including header/footer
3. Ensure no extra whitespace before `-----BEGIN` or after `-----END`
4. Update secret with new key
5. Re-run workflow

### Workflow Runs But Uses Wrong Repository Name

**Cause:** Repository renamed but `STANDARDS_REPO_NAME` variable not set.

**Fix:**
1. Go to **Settings** → **Secrets and variables** → **Actions** → **Variables**
2. Add variable: `STANDARDS_REPO_NAME` with your actual repository name
3. Re-run workflow

### Jobs Failing with "Not Found" Errors

**Cause:** Hardcoded paths in workflow don't match your setup.

**Fix:**
1. Check if you've renamed the repository
2. Set `STANDARDS_REPO_NAME` variable to match actual name
3. Verify default branch is `main` or set `DEFAULT_BRANCH` variable

---

## Rollback Procedure

If upgrade fails and you need to rollback:

### Option 1: Rollback to Previous Commit

```bash
# Find the commit before the upgrade
git log --oneline -n 10

# Reset to previous version (replace COMMIT_HASH)
git reset --hard COMMIT_HASH

# Force push to restore (⚠️ destructive)
git push --force origin main
```

### Option 2: Restore Backup Workflow

```bash
# Restore backup workflow file
cp .github/workflows/compliance-check.yml.backup .github/workflows/compliance-check.yml

# Commit and push
git add .github/workflows/compliance-check.yml
git commit -m "Rollback: Restore pre-v2.0 workflow"
git push origin main
```

### Option 3: Pin to v1.x Tag

If v1.x was tagged:

```bash
git checkout v1.9.0  # Replace with last v1.x version
git checkout -b rollback-to-v1
git push origin rollback-to-v1
```

---

## What's New in v2.0

Besides the breaking changes, v2.0 includes:

### New Features
- ✅ Environment-based configuration for organization customization
- ✅ Configurable parallel job limits
- ✅ Customizable issue labels
- ✅ Flexible repository naming
- ✅ Comprehensive setup documentation (SETUP.md)
- ✅ Configuration reference (.env.example)

### Improvements
- ✅ Better portability across organizations
- ✅ Easier to fork and customize
- ✅ Clearer separation of secrets and configuration
- ✅ More maintainable workflow code

### New Documentation
- ✅ SETUP.md - Complete setup guide for new installations
- ✅ UPGRADE.md - This upgrade guide
- ✅ .env.example - Configuration reference

---

## Migration Support

### Need Help?

1. **Review Documentation:**
   - [SETUP.md](SETUP.md) - Complete setup guide
   - [API_PERMISSIONS.md](../API_PERMISSIONS.md) - GitHub App permissions
   - [SECURITY.md](../SECURITY.md) - Security considerations

2. **Check Existing Issues:**
   - Search repository issues for similar problems
   - Look for `upgrade` or `migration` labels

3. **Common Patterns:**
   - Most issues are secret configuration problems
   - Verify private key format (most common issue)
   - Check app installation and permissions

---

## Post-Upgrade Recommendations

After successful upgrade:

1. **Review Configuration:**
   - Check if default values work for your organization
   - Consider customizing `MAX_PARALLEL_JOBS` based on rate limits
   - Adjust `ARTIFACT_RETENTION_DAYS` based on storage needs

2. **Update Documentation:**
   - Document your specific configuration
   - Note any customizations made
   - Update any internal setup guides

3. **Monitor First Few Runs:**
   - Watch for rate limit issues
   - Verify issue creation works
   - Check report generation

4. **Share Knowledge:**
   - Update team documentation
   - Share successful configuration
   - Document any organization-specific issues

---

## FAQ

### Q: Do I need to reconfigure every time I pull updates?

**A:** No. Once you configure secrets and variables, they persist. Future updates won't require reconfiguration unless new secrets/variables are added.

### Q: Can I still use the old workflow?

**A:** You can rollback, but v2.0+ will be the supported version. Old workflows may break with future updates.

### Q: What if I don't have the original private keys?

**A:** Generate new private keys from GitHub App settings. The old keys will be invalidated, but you can update the secrets with new keys.

### Q: Can I migrate gradually?

**A:** No. The workflow change is all-or-nothing. Configure all secrets before pulling changes, or rollback if needed.

### Q: Will this affect my compliance reports?

**A:** No. The change only affects workflow configuration. Report content and compliance checks remain the same.

### Q: Do I need to reinstall GitHub Apps?

**A:** No. Your existing GitHub Apps continue working. You just need to add their credentials as secrets.

---

## Summary

**Before Upgrade:**
- ✅ Backup workflow file
- ✅ Gather App IDs and private keys
- ✅ Note any customizations

**During Upgrade:**
- ✅ Add 4 required secrets
- ✅ Add optional variables (if needed)
- ✅ Pull latest changes

**After Upgrade:**
- ✅ Test workflow run
- ✅ Verify reports generated
- ✅ Check issues created
- ✅ Monitor for errors

**Time Required:** 10-15 minutes

**Rollback Time:** 2-5 minutes (if needed)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-12-10 | Environment-based configuration (breaking change) |
| 1.x | 2025-12-03 | Initial compliance framework with hardcoded values |

---

**Questions or Issues?** Open an issue in the repository with the `upgrade` label.

**Last Updated:** 2025-12-10
