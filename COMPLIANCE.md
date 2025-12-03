# Repository Compliance Standards

This document defines the best practices for all `my-*` repositories based on patterns identified from successful repos.

## Compliance Levels

- **🟢 CRITICAL** - Must have, blocking issues
- **🟡 HIGH** - Should have, important for consistency
- **🔵 MEDIUM** - Nice to have, improves quality
- **⚪ LOW** - Optional, advanced features

---

## Standards

### 🟢 CRITICAL - Foundation Files

#### COMP-001: README.md Exists
**Status:** CRITICAL
**Description:** Repository must have a README.md file in the root directory.
**Rationale:** README is the entry point for understanding any repository.
**Check Script:** `check-readme-exists.sh`

#### COMP-002: LICENSE File Exists
**Status:** CRITICAL
**Description:** Repository must have a LICENSE file in the root directory.
**Rationale:** Defines legal terms for using the repository.
**Check Script:** `check-license-exists.sh`

#### COMP-003: .gitignore Exists
**Status:** CRITICAL
**Description:** Repository must have a .gitignore file to prevent committing sensitive data.
**Rationale:** Prevents accidental commits of sensitive files, build artifacts, etc.
**Check Script:** `check-gitignore-exists.sh`

#### COMP-004: CLAUDE.md Exists
**Status:** CRITICAL
**Description:** Repository must have a CLAUDE.md file for AI assistant context.
**Rationale:** Provides context to AI assistants about the project structure and conventions.
**Check Script:** `check-claude-md-exists.sh`

---

### 🟡 HIGH - Structure & Documentation

#### COMP-005: README Structure
**Status:** HIGH
**Description:** README must contain standard sections:
- Title and description
- Purpose section
- Quick Start section
- Structure section
- Documentation section
- Last Updated date

**Rationale:** Consistent README structure improves discoverability and onboarding.
**Check Script:** `check-readme-structure.sh`

#### COMP-006: docs/ Directory
**Status:** HIGH
**Description:** Repository should have a docs/ directory with at least README.md.
**Rationale:** Separates detailed documentation from the main README.
**Check Script:** `check-docs-directory.sh`

#### COMP-015: Deprecated Actions
**Status:** HIGH
**Description:** Workflows must not use deprecated GitHub Actions.
**Deprecated Actions List:** `compliance/deprecated-actions.txt`
**Currently Deprecated:**
- `actions/checkout@v3` (upgrade to v4)

**Rationale:** Deprecated actions may have security vulnerabilities, missing features, or will eventually stop working. Keeping actions up-to-date ensures security and compatibility.

**⚠️ Critical Behavior:** Failing this check **automatically triggers issue creation**, regardless of overall compliance score. This ensures deprecated actions are addressed promptly.

**Check Script:** `check-deprecated-actions.sh`

---

### 🔵 MEDIUM - Best Practices

#### COMP-008: Issue Templates
**Status:** MEDIUM
**Description:** Repository should have issue templates in .github/ISSUE_TEMPLATE/.
**Rationale:** Structured issue creation improves data quality and workflow.
**Check Script:** `check-issue-templates.sh`

#### COMP-009: ADR Directory
**Status:** MEDIUM
**Description:** Repository should have Architecture Decision Records in docs/adr/.
**Rationale:** Documents architectural decisions and their context.
**Check Script:** `check-adr-pattern.sh`

#### COMP-010: .claude/ Configuration
**Status:** MEDIUM
**Description:** Repository should have .claude/ directory for Claude Code configuration.
**Rationale:** Enhances Claude Code experience with project-specific settings.
**Check Script:** `check-claude-config.sh`

#### COMP-014: ADR Quality
**Status:** MEDIUM
**Description:** ADRs must meet quality standards for structure and content.
**Requirements per ADR:**
- Has **Status** section (with date information preferred)
- Has **Context** section (problem statement and background)
- Has **Decision** section (what was decided)
- Has **Alternatives Considered** section (minimum 3 alternatives)
- Has **Consequences** section (positive and negative impacts)

**Scoring:**
- Each ADR evaluated on 7 criteria (5 required sections + status date + 3+ alternatives)
- Repository passes if average quality ≥ 60% (approximately 4 of 7 criteria met)
- Individual ADRs below 57% flagged but don't fail check alone

**Rationale:** High-quality ADRs provide lasting value through comprehensive documentation of decisions, alternatives, and tradeoffs. Poor ADRs quickly lose value and fail at institutional knowledge retention.

**Reference:** See `docs/standards/ADR-RFC-STANDARDS.md` for comprehensive guidelines.
**Check Script:** `check-adr-quality.sh`

---

### ⚪ LOW - Advanced Features

#### COMP-011: CONTRIBUTING.md
**Status:** LOW
**Description:** Repository may have contributing guidelines for external contributors.
**Rationale:** Useful for open-source or collaborative projects.
**Check Script:** `check-contributing.sh`

#### COMP-012: SECURITY.md
**Status:** LOW
**Description:** Repository may have security policy for vulnerability reporting.
**Rationale:** Important for projects handling sensitive data.
**Check Script:** `check-security.sh`

#### COMP-013: MkDocs Configuration
**Status:** LOW
**Description:** Repository may use MkDocs for comprehensive documentation site.
**Rationale:** Advanced documentation approach for complex projects.
**Check Script:** `check-mkdocs.sh`

---

## Compliance Score

Each repository receives a compliance score based on passed checks:

```
Score = (Passed Checks / Total Applicable Checks) * 100
```

**Weight by Priority:**
- CRITICAL: 10 points each (4 checks = 40 points)
- HIGH: 5 points each (3 checks = 15 points)
- MEDIUM: 2 points each (4 checks = 8 points)
- LOW: 1 point each (3 checks = 3 points)

**Total Possible:** 66 points

**Compliance Tiers:**
- 90-100% (60-66 points): 🟢 Excellent
- 75-89% (50-59 points): 🟡 Good
- 50-74% (33-49 points): 🟠 Needs Improvement
- 0-49% (0-32 points): 🔴 Critical Issues

---

## Repository Configuration

Each repository can customize compliance checking behavior using a `.compliance.yml` file in its root directory.

### Configuration Format

```yaml
# Compliance Configuration
# List of check IDs to disable
disabled_checks:
  - COMP-013  # Example: Skip MkDocs check for simple repos
  - COMP-008  # Example: Skip issue templates for personal projects

# Minimum score percentage to trigger issue creation (default: 50)
min_score_for_issue: 50

# Notes
notes: |
  Optional explanation of why certain checks are disabled
  or other repository-specific context.
```

### Configuration Options

#### disabled_checks
**Type:** Array of check IDs
**Default:** `[]` (no checks disabled)
**Purpose:** Exclude specific checks from running against this repository.

**When to use:**
- COMP-013 (MkDocs): Simple tools that don't need full documentation sites
- COMP-008 (Issue Templates): Personal projects not accepting external contributions
- COMP-011 (CONTRIBUTING.md): Non-collaborative repositories
- COMP-012 (SECURITY.md): Projects without security implications

**Important:** Disabled checks are completely skipped (status: "skip") and do not affect the compliance score calculation.

#### min_score_for_issue
**Type:** Integer (0-100)
**Default:** `50`
**Purpose:** Set the score threshold below which GitHub issues are automatically created in the repository.

**Common values:**
- `25` - Very lenient (only critical failures)
- `50` - Default (balanced approach)
- `75` - Strict (high standards required)
- `90` - Very strict (near-perfect compliance required)

**Note:** This setting is used by the GitHub Actions workflow when automatically creating compliance issues.

### Example Configurations

**Simple tool (my-inbox, my-jobs, my-resume):**
```yaml
disabled_checks:
  - COMP-013  # MkDocs not needed for simple tools
min_score_for_issue: 50
notes: |
  Simple tool - full documentation site not warranted.
```

**Complex application (my-diet, my-homelab):**
```yaml
disabled_checks: []
min_score_for_issue: 50
notes: |
  Full compliance maintained for comprehensive documentation.
```

**Meta-repository (github-repo-standards):**
```yaml
disabled_checks: []
min_score_for_issue: 50
notes: |
  Meta-repository for compliance checking.
  All checks apply to meet our own standards.
```

---

## Check Script Interface

All check scripts must follow this interface:

**Input:**
- `$1` - Path to repository to check

**Output (JSON):**
```json
{
  "check_id": "COMP-001",
  "name": "README.md Exists",
  "status": "pass|fail",
  "message": "Description of result",
  "details": {}
}
```

**Exit Codes:**
- `0` - Check passed
- `1` - Check failed
- `2` - Check not applicable

---

## Running Compliance Checks

### Check Single Repository
```bash
./compliance/run-all-checks.sh /path/to/repo
```

### Check All my-* Repositories
```bash
./compliance/run-all-checks.sh --all
```

### Check Specific Compliance Rule
```bash
./compliance/checks/check-readme-exists.sh /path/to/repo
```

### Generate Compliance Report
```bash
./compliance/run-all-checks.sh --all --format markdown > COMPLIANCE-REPORT.md
```

---

## Automation

Compliance checks run automatically:
- **Weekly:** Full scan of all repositories
- **On PR:** When this repo is updated
- **Manual:** Via workflow_dispatch

Results are committed to `reports/` directory.

---

**Last Updated:** 2025-12-01
**Version:** 1.1.0 (Added COMP-014: ADR Quality check)
