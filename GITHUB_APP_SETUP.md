# GitHub App Setup Guide

This guide walks you through creating a GitHub App for the compliance checker using the **manifest flow**.

## Why a GitHub App?

Benefits over Personal Access Tokens:
- ✅ Scoped permissions (only what's needed)
- ✅ Can be installed per-repository
- ✅ Better audit trail
- ✅ Doesn't tie to personal account
- ✅ More secure token rotation

---

## Prerequisites

Clone the GitHub App creation toolset:

```bash
cd /home/u0/code/labrats-work
gh repo clone labrats-work/my-gh-apps
cd my-gh-apps
```

**Or visit:** https://github.com/labrats-work/my-gh-apps

---

## Quick Setup (Using my-gh-apps)

### Step 1: Create the App

Use the manifest from this repository:

```bash
cd /home/u0/code/labrats-work/my-gh-apps
./create-app.sh ../repo-standards/github-app-manifest.json
```

This will:
1. Open GitHub in your browser with the manifest
2. Prompt you to confirm the app creation
3. Ask you to paste the code from the redirect URL
4. Automatically exchange the code for credentials

### Step 2: App Created!

The script will display:

```
✅ GitHub App created successfully!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 GitHub App Details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

App ID:           123456
App Slug:         repo-standards-compliance-checker
Private Key:      Saved to github-app-private-key.pem
```

---

## Step 3: Add Secrets to GitHub

1. **Go to Repository Secrets**
   ```
   https://github.com/labrats-work/repo-standards/settings/secrets/actions
   ```

2. **Add APP_ID**
   - Click **"New repository secret"**
   - Name: `APP_ID`
   - Value: The App ID from the exchange script output
   - Click **"Add secret"**

3. **Add APP_PRIVATE_KEY**
   - Click **"New repository secret"**
   - Name: `APP_PRIVATE_KEY`
   - Value: Copy **entire contents** of `github-app-private-key.pem`

   ```bash
   cat github-app-private-key.pem
   ```

   - Copy everything including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`
   - Paste into the secret value
   - Click **"Add secret"**

**✅ Secrets Added!** You should now have:
- ✅ `APP_ID`
- ✅ `APP_PRIVATE_KEY`

---

## Step 4: Install the App on Repositories

1. Go to your app's installations page:
   ```
   https://github.com/settings/apps/YOUR-APP-SLUG/installations
   ```

   Or use the URL from the exchange script output.

2. Click **"Install"** next to your username

3. Select repositories:
   - **"Only select repositories"**
   - Add all your `my-*` repositories:
     - ✅ repo-standards (required for writing reports)
     - ✅ my-borowego-2
     - ✅ my-diet
     - ✅ my-fin
     - ✅ my-health
     - ✅ my-homelab
     - ✅ my-jobs
     - ✅ my-junk
     - ✅ my-orangepi
     - ✅ my-protonmail
     - ✅ my-resume

4. Click **"Install"**

---

## Step 5: Clean Up Sensitive Files

After adding secrets to GitHub, delete the credential files in my-gh-apps:

```bash
cd /home/u0/code/labrats-work/my-gh-apps

# Delete private key (it's now in GitHub Secrets)
rm github-app-private-key.pem

# Optionally keep the credentials file for reference (it's in .gitignore)
# rm github-app-credentials.txt
```

**⚠️ Important:** These files won't be committed (they're in `.gitignore`), but delete them after setup for security.

---

## Step 6: Test the Setup

Trigger the compliance workflow to test everything:

```bash
gh workflow run compliance-check.yml --repo labrats-work/repo-standards
```

**Check the workflow run:**
```bash
gh run watch --repo labrats-work/repo-standards
```

**What should happen:**
1. ✅ Workflow generates app token successfully
2. ✅ Clones all 11 repositories
3. ✅ Runs compliance checks
4. ✅ Generates reports
5. ✅ Commits reports to repo-standards
6. ✅ Creates issue if <50% compliance

If it works, you're done! 🎉

---

## Summary

You've created a GitHub App that can:
- ✅ Read all your `my-*` repositories
- ✅ Create issues for compliance failures
- ✅ Run automated checks weekly
- ✅ Generate compliance reports

**Next Steps:**
- Wait for Monday 9 AM UTC for automatic run
- Or trigger manually anytime with `gh workflow run`
- View reports in `reports/` directory

---

## Troubleshooting

### "Bad credentials" error
- Check that `APP_ID` matches your app
- Verify `APP_PRIVATE_KEY` is the complete `.pem` file contents
- Ensure the app is installed on all required repos

### "Resource not accessible by integration" error
- Check app permissions include `contents: read` and `issues: write`
- Verify the app is installed on the target repository

### "Could not resolve to a Repository" error
- Ensure the GitHub App is installed on all `my-*` repositories
- Check installation includes the specific repository

### Private key format issues
- Ensure the entire PEM file is copied including headers/footers
- No extra whitespace before/after
- Newlines should be preserved

---

## Security Notes

- ✅ The private key is stored as a GitHub secret (encrypted)
- ✅ Secrets are not exposed in logs
- ✅ App has minimal permissions (read repos, write issues)
- ✅ App is scoped to your account only
- ⚠️ Never commit the `.pem` file to git
- ⚠️ Store the `.pem` file securely (password manager, encrypted storage)

---

## Revoking Access

If you need to revoke access:

1. **Uninstall the app:**
   - Go to: https://github.com/settings/installations
   - Click "Configure" next to the app
   - Click "Uninstall"

2. **Delete the app:**
   - Go to: https://github.com/settings/apps
   - Click your app name
   - Scroll to bottom → "Delete this GitHub App"

---

## Next Steps

After completing this setup:

1. ✅ Run the compliance workflow to test
2. ✅ Verify reports are generated
3. ✅ Check that issues are created for critical failures
4. ✅ Schedule will run automatically every Monday

---

**Created:** 2025-11-26
**For:** labrats-work/repo-standards compliance checking
