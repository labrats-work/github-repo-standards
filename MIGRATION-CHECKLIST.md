# Migration Checklist: v1.x → v2.0

Use this checklist to track your upgrade progress. Check off items as you complete them.

**Estimated Time:** 10-15 minutes
**Difficulty:** Easy
**Risk:** Low (rollback available)

---

## Pre-Migration

- [ ] **Backup current workflow**
  ```bash
  cp .github/workflows/compliance-check.yml .github/workflows/compliance-check.yml.backup
  ```

- [ ] **Locate GitHub App credentials** (from initial setup)
  - [ ] Repo Standards Bot: App ID
  - [ ] Repo Standards Bot: Private Key
  - [ ] Internal Automation App: App ID
  - [ ] Internal Automation App: Private Key

- [ ] **Document current configuration**
  - Repository name: ________________
  - Parallel jobs: ________________
  - Default branch: ________________
  - Custom labels: ________________

- [ ] **Review breaking changes** (read UPGRADE.md)

---

## Configuration

### Required Secrets

Navigate to: **Settings → Secrets and variables → Actions → Secrets**

- [ ] Add `REPO_STANDARDS_APP_ID`
  - Value: ________________
  - Format: Number (e.g., `123456`)

- [ ] Add `REPO_STANDARDS_APP_PRIVATE_KEY`
  - Format: Full PEM including `-----BEGIN` and `-----END`
  - ⚠️ **Verify:** No extra whitespace before/after

- [ ] Add `INTERNAL_AUTOMATION_APP_ID`
  - Value: ________________
  - Format: Number (e.g., `123457`)

- [ ] Add `INTERNAL_AUTOMATION_APP_PRIVATE_KEY`
  - Format: Full PEM including `-----BEGIN` and `-----END`
  - ⚠️ **Verify:** No extra whitespace before/after

### Optional Variables (if needed)

Navigate to: **Settings → Secrets and variables → Actions → Variables**

Skip this section if you're using default values.

- [ ] Add `STANDARDS_REPO_NAME` (if repository renamed)
  - Value: ________________
  - Default: `github-repo-standards`

- [ ] Add `MAX_PARALLEL_JOBS` (if customizing parallelism)
  - Value: ________________
  - Default: `10`

- [ ] Add `ARTIFACT_RETENTION_DAYS` (if customizing retention)
  - Value: ________________
  - Default: `30`

- [ ] Add `DEFAULT_BRANCH` (if not using `main`)
  - Value: ________________
  - Default: `main`

- [ ] Add `COMPLIANCE_LABEL` (if customizing)
  - Value: ________________
  - Default: `compliance`

- [ ] Add `CRITICAL_LABEL` (if customizing)
  - Value: ________________
  - Default: `critical`

---

## Migration

- [ ] **Pull latest changes**
  ```bash
  cd /path/to/github-repo-standards
  git fetch origin
  git pull origin main
  ```

- [ ] **Verify secrets configured**
  ```bash
  gh secret list --repo YOUR_ORG/github-repo-standards
  ```
  Expected: 4 secrets listed

- [ ] **Verify variables configured** (if any)
  ```bash
  gh variable list --repo YOUR_ORG/github-repo-standards
  ```

---

## Testing

- [ ] **Trigger manual workflow run**
  ```bash
  gh workflow run compliance-check.yml --repo YOUR_ORG/github-repo-standards
  ```

- [ ] **Monitor workflow execution**
  ```bash
  gh run watch --repo YOUR_ORG/github-repo-standards
  ```

- [ ] **Verify workflow steps:**
  - [ ] `discover-repos` job succeeds
  - [ ] `check-compliance` jobs run in parallel
  - [ ] `aggregate-results` creates reports
  - [ ] No "missing secret" errors

- [ ] **Check outputs:**
  - [ ] Reports generated in `reports/` directory
  - [ ] PR created with reports (if changes exist)
  - [ ] Issues created in failing repositories
  - [ ] No errors in workflow logs

---

## Verification

- [ ] **First workflow run completed successfully**
- [ ] **All repositories discovered**
- [ ] **Compliance checks executed**
- [ ] **Reports look correct**
- [ ] **Issues created as expected**
- [ ] **No breaking errors**

---

## Post-Migration

- [ ] **Clean up backup**
  ```bash
  rm .github/workflows/compliance-check.yml.backup
  ```

- [ ] **Update team documentation** (if applicable)
  - [ ] Note configuration decisions
  - [ ] Document any customizations
  - [ ] Share migration experience

- [ ] **Monitor next scheduled run**
  - Next run: Monday 9 AM UTC
  - [ ] Verify scheduled run works

---

## Rollback (if needed)

If migration fails:

- [ ] **Option 1: Restore backup**
  ```bash
  cp .github/workflows/compliance-check.yml.backup .github/workflows/compliance-check.yml
  git add .github/workflows/compliance-check.yml
  git commit -m "Rollback: Restore pre-v2.0 workflow"
  git push origin main
  ```

- [ ] **Option 2: Reset to previous commit**
  ```bash
  git log --oneline -n 10  # Find commit before upgrade
  git reset --hard COMMIT_HASH
  git push --force origin main
  ```

- [ ] **Document rollback reason**
  - Issue encountered: ________________
  - Error message: ________________
  - Next steps: ________________

---

## Troubleshooting

If you encounter issues, check:

- [ ] **Secret names** exactly match (case-sensitive)
- [ ] **Private key format** includes header/footer
- [ ] **GitHub Apps** are still installed
- [ ] **App permissions** are correct
- [ ] **Workflow logs** for specific error messages

See [UPGRADE.md - Troubleshooting](UPGRADE.md#troubleshooting) for detailed solutions.

---

## Help & Resources

- [ ] **Documentation reviewed:**
  - [ ] [UPGRADE.md](UPGRADE.md) - Complete upgrade guide
  - [ ] [SETUP.md](SETUP.md) - Setup reference
  - [ ] [.env.example](.env.example) - Configuration reference

- [ ] **Support channels:**
  - [ ] Check existing issues with `upgrade` label
  - [ ] Review troubleshooting section
  - [ ] Open new issue if needed

---

## Success Criteria

✅ **Migration successful when:**
- Workflow runs without errors
- All repositories scanned
- Reports generated correctly
- Issues created as expected
- Team informed of changes

---

## Notes

Use this space for notes during migration:

**Configuration decisions:**


**Issues encountered:**


**Solutions applied:**


**Follow-up items:**


---

**Date started:** ________________
**Date completed:** ________________
**Completed by:** ________________
**Rollback required:** Yes / No

---

**Next Review:** After first scheduled run (Monday 9 AM UTC)
