# Claude Context: github-repo-standards - Cross-Repository Standardization

## Repository Overview

This is the **meta-repository** for managing compliance and standardization across all repositories in the labrats-work organization. It provides automated compliance checking, best practices enforcement, and cross-repository improvement tracking.

**Purpose:** Central hub for ensuring consistency, quality, and maintainability across all labrats-work repositories.

## Project Architecture

### Core Components

```
github-repo-standards/
├── compliance/              # Compliance checking framework
│   ├── checks/             # Modular check scripts (COMP-001 to COMP-019)
│   ├── scripts/            # Automated fix scripts
│   ├── check-priorities.json  # Check priority and scoring configuration
│   └── README.md           # Framework documentation
├── reports/                # Generated compliance reports
│   ├── compliance-report-YYYY-MM-DD.md    # Human-readable
│   └── compliance-report-YYYY-MM-DD.json  # Machine-readable
├── .github/
│   ├── workflows/
│   │   └── compliance-check.yml  # Weekly automated checks (orchestrates all checks)
│   └── ISSUE_TEMPLATE_COMPLIANCE_FAILURE.md  # Issue template
├── COMPLIANCE.md           # Standards definition
└── docs/                   # Documentation
    ├── setup.md            # Setup guide
    ├── upgrade.md          # Upgrade guide
    └── migration-checklist.md  # Migration tracker
```

### How It Works

1. **Compliance Checks** - 19 modular bash scripts check for best practices
2. **Weighted Scoring** - CRITICAL (10pts), HIGH (5pts), MEDIUM (2pts), LOW (1pt)
3. **Workflow Orchestration** - GitHub Actions workflow discovers and runs all checks
4. **Automated Workflow** - Runs weekly, clones all repos, generates reports
5. **Issue Creation** - Creates issues in failing repositories (CRITICAL/HIGH failures)
6. **Deduplication** - Prevents duplicate issues (checks for existing open compliance issues)

## Compliance Standards

### Standard Checks (19 total)

**CRITICAL (4 checks - 10 points each):**
- COMP-001: README.md exists
- COMP-002: .gitignore exists
- COMP-003: CLAUDE.md exists (repository context for AI)
- COMP-004: LICENSE file exists

**HIGH (3 checks - 5 points each):**
- COMP-005: README has required sections (Purpose, Quick Start, Structure)
- COMP-006: docs/ directory with README.md
- COMP-007: GitHub Workflows exist

**MEDIUM (3 checks - 2 points each):**
- COMP-008: Issue templates exist
- COMP-009: ADR pattern implemented (docs/adr/)
- COMP-010: .claude/ configuration exists

**LOW (3 checks - 1 point each):**
- COMP-011: CONTRIBUTING.md exists
- COMP-012: SECURITY.md exists
- COMP-013: MkDocs configuration exists

### Compliance Tiers

- **90-100%:** 🟢 Excellent
- **75-89%:** 🟡 Good
- **50-74%:** 🟠 Needs Improvement
- **0-49%:** 🔴 Critical Issues (auto-creates issue in repo)

## Common Operations

### Run Compliance Checks Locally

```bash
# Run individual check
./compliance/checks/check-readme-exists.sh /path/to/repo

# Run all checks manually
for check in compliance/checks/check-*.sh; do
  bash "$check" /path/to/repo
done

# Checks output JSON format:
# {"check_id":"COMP-001","name":"README.md Exists","status":"pass","message":"README.md found"}
```

### Trigger Automated Workflow

```bash
# Via GitHub CLI
gh workflow run compliance-check.yml --repo labrats-work/github-repo-standards

# Watch execution
gh run watch <run-id> --repo labrats-work/github-repo-standards
```

### View Compliance Reports

```bash
# Latest markdown report
cat reports/compliance-report-$(date +%Y-%m-%d).md

# Parse JSON report with jq
jq '.repositories[] | select(.compliance_score < 50)' reports/compliance-report-*.json
```

## GitHub App Integration

This repository uses a GitHub App for cross-repository access:

- **App Name:** Labrats-Work Repo Standards (to be created)
- **Permissions:** contents:read, issues:write
- **Purpose:** Read organization repos and create compliance issues
- **Setup:** See GITHUB_APP_SETUP.md for instructions

**Security Model:**
- GITHUB_TOKEN: Used for github-repo-standards operations (checkout, commit, push)
- GitHub App Token: Used ONLY for reading other repos (clone) and creating issues

## Automation Workflow

### Weekly Schedule (Every Monday 9 AM UTC)

1. **Generate GitHub App Token** from app credentials
2. **Checkout github-repo-standards** using GITHUB_TOKEN
3. **Clone all my-* repositories** using App Token
4. **Run compliance checks** on all repos (including github-repo-standards itself)
5. **Generate reports** (markdown + JSON)
6. **Commit reports** to github-repo-standards using GITHUB_TOKEN
7. **Create issues** in failing repositories (<50%) using App Token
8. **Deduplication check** - Skip if open compliance issue exists

### Manual Triggers

- Push to `compliance/` directory
- Push to `COMPLIANCE.md`
- Manual workflow dispatch

## Related Repositories

This framework tracks all repositories in the labrats-work organization where the GitHub App is installed. The list is dynamic and automatically discovered during compliance checks.

## Important Files

### COMPLIANCE.md
Defines all 19 compliance standards in detail. This is the source of truth for what makes a repository compliant.

### compliance/check-priorities.json
Configuration file that defines:
- Check ID to name mapping
- Priority levels (CRITICAL, HIGH, MEDIUM, LOW)
- Point values for weighted scoring

### .github/workflows/compliance-check.yml
GitHub Actions workflow that orchestrates the entire compliance checking process:
- Discovers all check scripts in compliance/checks/
- Runs them in parallel across repositories
- Calculates weighted scores using check-priorities.json
- Aggregates results and generates reports
- Uses both GITHUB_TOKEN and GitHub App tokens with proper scoping

### .github/ISSUE_TEMPLATE_COMPLIANCE_FAILURE.md
Template file for compliance issues created in failing repositories. Uses `{{PLACEHOLDER}}` syntax for dynamic content replacement.

## Notes for AI Assistants

When working in this repository:

1. **Compliance Checks Are Modular** - Each check is a separate script in `compliance/checks/`
2. **Don't Break the GitHub App** - App credentials are in GitHub Secrets (APP_ID, APP_PRIVATE_KEY)
3. **Use Template Files** - Issue bodies should use the template file approach, not heredocs
4. **Deduplication Is Important** - Always check for existing open issues before creating new ones
5. **Security Model Matters** - GITHUB_TOKEN for same-repo, App token for cross-repo reads
6. **Self-Checking** - github-repo-standards checks itself for compliance too
7. **Documentation Placement** - ALWAYS place markdown documentation files in the `docs/` directory, never in the root
8. **Documentation Naming** - Use lowercase filenames with hyphens for docs (e.g., `setup.md`, `api-reference.md`, not `SETUP.MD` or `API_REFERENCE.md`)

### Common Pitfalls

- **Don't use sed for multiline substitution** - Use awk or separate temp files
- **Don't create duplicate issues** - Check for existing open compliance issues first
- **Don't use GitHub App token for github-repo-standards operations** - Use GITHUB_TOKEN
- **Don't hardcode repo lists** - Use GitHub App to discover installed repos
- **Don't put markdown docs in root** - ALWAYS place markdown documentation (guides, references, etc.) in `docs/` directory
  - ❌ Wrong: `/UPGRADE.md`, `/MIGRATION-GUIDE.md`, `/API-REFERENCE.md`
  - ✅ Correct: `/docs/upgrade.md`, `/docs/migration-guide.md`, `/docs/api-reference.md`
  - Exception: Root-level standard files (README.md, CONTRIBUTING.md, SECURITY.md, LICENSE, CHANGELOG.md) stay in root
- **Don't use all-caps filenames in docs/** - Use lowercase with hyphens for better readability
  - ❌ Wrong: `docs/SETUP.md`, `docs/API_REFERENCE.md`, `docs/USER_GUIDE.md`
  - ✅ Correct: `docs/setup.md`, `docs/api-reference.md`, `docs/user-guide.md`
  - Exception: Root-level convention files can use UPPERCASE (README.md, CONTRIBUTING.md, etc.)

### Typical Workflows

**Adding a new compliance check:**
1. Create new script in `compliance/checks/` (e.g., `check-new-thing.sh`)
2. Follow existing script pattern (JSON output, exit codes)
3. Document in COMPLIANCE.md
4. Test locally before committing

**Updating compliance standards:**
1. Update COMPLIANCE.md documentation
2. Update relevant check script(s)
3. Trigger workflow to regenerate all reports

**Investigating compliance failures:**
1. Check latest report in `reports/`
2. View specific repository's compliance issue
3. Reference COMPLIANCE.md for requirements
4. Fix issues in target repository

## Version History

- **2025-12-03:** Repository migrated to labrats-work organization with fresh history
- **2025-12-03:** Renamed from my-repos to github-repo-standards
- **Previous:** Compliance framework with 13 checks, GitHub App integration, automated reporting

## Last Updated

2025-12-10 (v2.0.0 - Environment-based configuration)
