# Repository Compliance Framework

Automated compliance checking system for all `my-*` repositories.

## Overview

This framework ensures consistency and quality across all personal repositories by:
- Defining best practices based on successful patterns
- Providing automated checks for compliance
- Generating reports to track progress
- Creating actionable issues for critical failures

## Quick Start

### Run Via GitHub Actions (Recommended)

The compliance framework is designed to run via the automated workflow:

```bash
# Trigger the workflow
gh workflow run compliance-check.yml --repo YOUR_ORG/github-repo-standards

# Watch execution
gh run watch --repo YOUR_ORG/github-repo-standards
```

The workflow automatically:
- Discovers all repositories where the app is installed
- Runs all checks in parallel
- Aggregates results with weighted scoring
- Generates reports (markdown + JSON)
- Creates issues for failing repositories

### Run Individual Checks Locally

Each check can be run independently for testing:

```bash
# Run a specific check
./checks/check-readme-exists.sh /path/to/repository

# Run all checks manually (bash loop)
for check in checks/check-*.sh; do
  echo "Running: $(basename $check)"
  bash "$check" /path/to/repository
done
```

## Check Scripts

Each compliance check is implemented as an independent script in `checks/`:

| Script | Check ID | Priority | Description |
|--------|----------|----------|-------------|
| `check-readme-exists.sh` | COMP-001 | 🟢 CRITICAL | README.md must exist |
| `check-license-exists.sh` | COMP-002 | 🟢 CRITICAL | LICENSE file must exist |
| `check-gitignore-exists.sh` | COMP-003 | 🟢 CRITICAL | .gitignore must exist and not be empty |
| `check-claude-md-exists.sh` | COMP-004 | 🟢 CRITICAL | CLAUDE.md must exist with content |
| `check-readme-structure.sh` | COMP-005 | 🟡 HIGH | README must have standard sections |
| `check-docs-directory.sh` | COMP-006 | 🟡 HIGH | docs/ directory should exist |
| `check-workflows.sh` | COMP-007 | 🟡 HIGH | At least one GitHub workflow should exist |
| `check-issue-templates.sh` | COMP-008 | 🔵 MEDIUM | Issue templates should be present |
| `check-adr-pattern.sh` | COMP-009 | 🔵 MEDIUM | ADR pattern should be implemented |
| `check-claude-config.sh` | COMP-010 | 🔵 MEDIUM | .claude/ configuration should exist |
| `check-contributing.sh` | COMP-011 | ⚪ LOW | CONTRIBUTING.md may exist |
| `check-security.sh` | COMP-012 | ⚪ LOW | SECURITY.md may exist |
| `check-mkdocs.sh` | COMP-013 | ⚪ LOW | MkDocs configuration may exist |

## Running Individual Checks

Each check can be run independently:

```bash
./checks/check-readme-exists.sh /path/to/repository
```

Output is JSON:

```json
{
  "check_id": "COMP-001",
  "name": "README.md Exists",
  "status": "pass",
  "message": "README.md found"
}
```

## Exit Codes

- `0` - Check passed
- `1` - Check failed
- `2` - Check not applicable (currently unused)

## Compliance Scoring

Repositories receive a weighted compliance score:

**Weights:**
- CRITICAL: 10 points each
- HIGH: 5 points each
- MEDIUM: 2 points each
- LOW: 1 point each

**Example:**
- 4 CRITICAL checks = 40 points
- 3 HIGH checks = 15 points
- 3 MEDIUM checks = 6 points
- 3 LOW checks = 3 points
- **Total possible: 64 points**

**Compliance Tiers:**
- 90-100%: 🟢 Excellent
- 75-89%: 🟡 Good
- 50-74%: 🟠 Needs Improvement
- 0-49%: 🔴 Critical Issues

## Exemptions

If a check doesn't apply to a specific repository, create `.compliance-exemptions.yml` in that repo:

```yaml
exemptions:
  - check: COMP-008
    reason: "No issue templates needed for personal documentation repo"
  - check: COMP-013
    reason: "Simple project doesn't need MkDocs"
```

## Automation

The GitHub Action workflow (`.github/workflows/compliance-check.yml`) automatically:

1. **Runs weekly** (Mondays at 9 AM UTC)
2. **Clones all my-* repositories**
3. **Executes compliance checks**
4. **Generates reports** (markdown + JSON)
5. **Commits reports** to `reports/` directory
6. **Creates issues** for critical compliance failures (<50% score)

### Manual Trigger

Run checks manually via GitHub Actions:
1. Go to Actions tab
2. Select "Repository Compliance Check"
3. Click "Run workflow"

## Report Format

### JSON Report

```json
{
  "generated": "2025-11-26T12:00:00Z",
  "repositories": [
    {
      "repository": "my-homelab",
      "path": "/path/to/my-homelab",
      "compliance_score": 85,
      "tier": "🟡 Good",
      "passed": 10,
      "failed": 3,
      "total_score": 54,
      "max_score": 64,
      "checks": [...]
    }
  ]
}
```

### Markdown Report

```markdown
## my-homelab

**Compliance Score:** 85% (54/64 points) - 🟡 Good

**Summary:** 10 passed, 3 failed

| Check | Priority | Status | Message |
|-------|----------|--------|---------|
| README.md Exists | CRITICAL | ✅ | README.md found |
| ...
```

## Adding New Checks

To add a new compliance check:

1. **Create check script** in `checks/`:
   ```bash
   #!/bin/bash
   # COMP-XXX: Check description

   REPO_PATH="${1:-.}"
   CHECK_ID="COMP-XXX"
   CHECK_NAME="Your Check Name"

   # Your check logic here

   if [ condition ]; then
       echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Success message\"}"
       exit 0
   else
       echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Failure message\"}"
       exit 1
   fi
   ```

2. **Make it executable:**
   ```bash
   chmod +x checks/check-your-check.sh
   ```

3. **Add to check-priorities.json:**
   ```json
   {
     "COMP-XXX": {
       "name": "Your Check Name",
       "priority": "HIGH",
       "points": 5
     }
   }
   ```

4. **Document in COMPLIANCE.md**
   - Add new standard definition
   - Assign check ID and priority

5. **Test it:**
   ```bash
   ./checks/check-your-check.sh /path/to/test/repo
   ```

## Development

### Testing All Checks

```bash
# Test individual check on a repo
./checks/check-readme-exists.sh /path/to/repo

# Test all checks manually
for check in checks/check-*.sh; do
  bash "$check" /path/to/repo
done

# Test via workflow (end-to-end)
gh workflow run compliance-check.yml --repo YOUR_ORG/github-repo-standards
```

### Debugging Check Scripts

Add `set -x` to enable debug output:

```bash
#!/bin/bash
set -ex  # Enable debugging

# rest of script...
```

Run check directly:

```bash
bash -x ./checks/check-readme-exists.sh /path/to/repo
```

## Troubleshooting

### Check script fails with "command not found"

Ensure script is executable:
```bash
chmod +x compliance/checks/*.sh
```

### jq not found

Install jq:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

### Check priorities not loading

Ensure `compliance/check-priorities.json` exists and is valid JSON:
```bash
jq . compliance/check-priorities.json
```

## Future Enhancements

- [ ] Support for `.compliance-exemptions.yml`
- [ ] Parallel check execution
- [ ] Progress bar for long checks
- [ ] HTML report generation
- [ ] Check result caching
- [ ] Trend analysis over time
- [ ] Automatic fix suggestions
- [ ] Custom check plugins

---

**Last Updated:** 2025-11-26
**Version:** 1.0.0
