# github-repo-standards

Cross-repository standardization and compliance checking framework for the labrats-work organization.

## Purpose

This repository serves as the central hub for:
- **Compliance checking** - Automated validation of best practices
- **Standardization tracking** - Monitoring consistency across repositories
- **Improvement planning** - Coordinating enhancements across repos
- **Pattern documentation** - Recording successful patterns and anti-patterns

## Quick Start

### Run Compliance Checks

Check all repositories:
```bash
./compliance/run-all-checks.sh --all --format markdown
```

Check single repository:
```bash
./compliance/run-all-checks.sh /path/to/repository
```

### View Latest Report

```bash
cat reports/compliance-report-$(date +%Y-%m-%d).md
```

## Structure

```
github-repo-standards/
├── compliance/              # Compliance checking framework
│   ├── checks/             # Individual check scripts
│   ├── run-all-checks.sh   # Orchestrator script
│   └── README.md           # Compliance documentation
├── reports/                # Generated compliance reports
├── .github/
│   └── workflows/
│       └── compliance-check.yml  # Automated checks
├── COMPLIANCE.md           # Best practices definition
└── README.md               # This file
```

## Repositories Tracked

This system monitors all repositories in the labrats-work organization.

*Status updated weekly via automated checks. Configure which repositories to track using the GitHub App installation.*

## Compliance Framework

### Standards

See [COMPLIANCE.md](COMPLIANCE.md) for full details on standards.

**Priority Levels:**
- 🟢 **CRITICAL** - Must have (README, LICENSE, .gitignore, CLAUDE.md)
- 🟡 **HIGH** - Should have (README structure, docs/, workflows)
- 🔵 **MEDIUM** - Nice to have (issue templates, ADRs, .claude/)
- ⚪ **LOW** - Optional (CONTRIBUTING, SECURITY, MkDocs)

### Compliance Scoring

Each repository receives a weighted score:
- CRITICAL checks: 10 points each
- HIGH checks: 5 points each
- MEDIUM checks: 2 points each
- LOW checks: 1 point each

**Tiers:**
- 90-100%: 🟢 Excellent
- 75-89%: 🟡 Good
- 50-74%: 🟠 Needs Improvement
- 0-49%: 🔴 Critical Issues

## Automation

### Weekly Compliance Checks

Every Monday at 9 AM UTC:
1. Clone all repositories in the organization
2. Run compliance checks
3. Generate reports (markdown + JSON)
4. Commit reports to this repo
5. Create issues for critical failures
6. Create pipeline metrics issue with execution statistics
7. Analyze workflow health and create reports in each repository
8. Generate GitHub Actions usage report

### Manual Runs

Trigger checks manually:
1. Go to **Actions** tab
2. Select **Repository Compliance Check**
3. Click **Run workflow**

### Pipeline Metrics

After each compliance check run, a pipeline metrics issue is automatically created in github-repo-standards with:
- **Execution time metrics** - Total duration and step-by-step timing
- **Repository summary** - Scores, tiers, and pass/fail counts
- **Success metrics** - Passing/failing repository counts, issues created/updated/closed
- **Compliance tier breakdown** - Distribution across tiers
- **Top failing checks** - Most common compliance issues
- **Trend analysis** - Comparison with previous run

View the latest metrics: [pipeline-metrics label](../../issues?q=label%3Apipeline-metrics)

### Workflow Health Reports

After each compliance check run, workflow health issues are created in each repository with:
- **Overall workflow health** - Success rate across all workflows
- **Per-workflow statistics** - Individual success/failure rates
- **Recent failures** - Links to failed workflow runs
- **Health status** - Color-coded health indicator (🟢 🟡 🟠 🔴)
- **Recommendations** - Actionable steps for failing workflows

**Issue creation logic:**
- Issues created when success rate < 95%
- Previous health issues automatically closed
- Labeled with `workflow-health` and `automation`

Example: [my-diet workflow-health](https://github.com/labrats-work/my-diet/issues?q=label%3Aworkflow-health)

### Actions Usage Report

After each compliance check run, an actions usage report is created in github-repo-standards with:
- **Total actions inventory** - All GitHub Actions used across repositories
- **Usage statistics** - How many times each action is used
- **Top 10 most used actions** - Ranked by usage frequency
- **Version analysis** - Detects actions with multiple versions in use
- **Per-repository breakdown** - Actions used in each repository
- **Security recommendations** - Best practices for action usage

**Purpose:**
- Track which actions are used across the organization
- Identify version inconsistencies
- Ensure security best practices
- Monitor action dependencies

View the latest report: [actions-usage label](../../issues?q=label%3Aactions-usage)

## Standardization Roadmap

### Foundation Phase
- [ ] Add CLAUDE.md to all repos
- [ ] Ensure all repos have .gitignore
- [ ] Add LICENSE to all repos
- [ ] Standardize README structure

### Structure Phase
- [ ] Add docs/ directory to repos lacking it
- [ ] Implement ADR pattern
- [ ] Create .claude/ configuration
- [ ] Add issue templates

### Automation Phase
- [ ] Add workflows to repositories
- [ ] Implement scheduled tasks
- [ ] Add PR validation

### Enhancement Phase
- [ ] Expand documentation
- [ ] Add contributing guidelines
- [ ] Implement consistent commit conventions

## Best Practices

The compliance framework promotes these patterns:

**Issue-Driven Workflows:**
- Form-based issue templates capture structured data
- GitHub Actions auto-create PRs
- Non-technical interface for data entry

**Architecture Decision Records:**
- Numbered ADRs document "why" decisions were made
- Template-based consistency
- Prevents re-litigating decisions

**Documentation Status Tracking:**
- Tables showing completion percentages
- Visual indicators (🟢🟡🔴)
- Clear roadmap of gaps

**Automated Data Collection:**
- Scheduled workflows gather data
- Hands-off accumulation
- Consistent formatting

## Contributing

When working with labrats-work repositories:

1. Review compliance reports before making changes
2. Follow standards defined in COMPLIANCE.md
3. Run compliance checks locally before pushing
4. Document architectural decisions in ADRs

## Reports

Compliance reports are generated weekly and stored in `reports/`:

- `compliance-report-YYYY-MM-DD.md` - Human-readable markdown
- `compliance-report-YYYY-MM-DD.json` - Machine-readable JSON

### Report Location

Latest reports available at:
- [reports/](./reports/)

### Report Summary

View summary in GitHub Actions:
- [Actions tab](../../actions) → Latest "Repository Compliance Check" run

## Issues

Track standardization work:
- [Issue #1](../../issues/1) - Master standardization plan
- [Compliance label](../../issues?q=label%3Acompliance) - Compliance-related issues
- [Critical label](../../issues?q=label%3Acritical) - Critical compliance failures

### Automatic Issue Creation

Compliance issues are automatically created in repositories based on **priority thresholds**, not compliance scores.

**Default behavior:** Issues created for any CRITICAL or HIGH priority failures.

**Configurable priority threshold** (`.compliance.yml`):
```yaml
# Set minimum priority level that triggers issues
# Valid values: CRITICAL, HIGH (default), MEDIUM, LOW
min_priority_for_issue: HIGH

# Completely disable automatic issues (optional)
disabled: true
```

**Priority threshold examples:**
- `CRITICAL`: Only CRITICAL failures trigger issues
- `HIGH` (default): CRITICAL or HIGH failures trigger issues
- `MEDIUM`: CRITICAL, HIGH, or MEDIUM failures trigger issues
- `LOW`: Any failure at any priority triggers issues

**Issue lifecycle:**
- Issues created when failures at or above threshold are detected
- Issues remain open until ALL failures at or above threshold are resolved
- Issues close automatically when only lower-priority failures remain

This ensures important issues are surfaced immediately, regardless of overall compliance percentage.

## Documentation

- [COMPLIANCE.md](COMPLIANCE.md) - Best practices definition
- [compliance/README.md](compliance/README.md) - Compliance framework guide

## Status

**Created:** 2025-12-03
**Organization:** labrats-work
**Active Checks:** 13
**Automation:** ✅ Active (weekly)

---

Last Updated: 2025-12-03
