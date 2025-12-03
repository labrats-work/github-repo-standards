# Documentation

This directory contains detailed documentation for the my-repos compliance framework.

## Contents

- **compliance-framework.md** - Detailed guide to the compliance checking system
- **adding-checks.md** - How to add new compliance checks
- **github-app-setup.md** - GitHub App configuration and setup
- **adr/** - Architecture Decision Records

## Quick Links

### Core Documentation

- [COMPLIANCE.md](../COMPLIANCE.md) - Standards definition
- [compliance/README.md](../compliance/README.md) - Framework guide
- [CLAUDE.md](../CLAUDE.md) - Repository context for AI

### External Resources

- [GitHub App: my-gh-apps](https://github.com/tomp736/my-gh-apps) - GitHub App creation tools
- [Compliance Reports](../reports/) - Generated compliance reports

## Compliance Framework Overview

The compliance framework consists of:

1. **Modular Check Scripts** (`compliance/checks/`)
   - Each check is an independent bash script
   - Outputs JSON with status and message
   - Returns exit code 0 (pass) or 1 (fail)

2. **Orchestrator** (`compliance/run-all-checks.sh`)
   - Discovers and runs all checks
   - Calculates weighted compliance score
   - Generates markdown and JSON reports

3. **Automation** (`.github/workflows/compliance-check.yml`)
   - Runs weekly on Monday 9 AM UTC
   - Clones all my-* repositories
   - Creates issues for failures <50%

4. **GitHub App Integration**
   - Provides cross-repository read access
   - Creates compliance issues in target repos
   - Scoped permissions (contents:read, issues:write)

## Compliance Standards Summary

### By Priority

**CRITICAL (40 points total):**
- README.md exists
- .gitignore exists
- CLAUDE.md exists
- LICENSE exists

**HIGH (15 points total):**
- README has required sections
- docs/ directory with README
- GitHub Workflows exist

**MEDIUM (6 points total):**
- Issue templates exist
- ADR pattern implemented
- .claude/ configuration

**LOW (3 points total):**
- CONTRIBUTING.md
- SECURITY.md
- MkDocs config

### Compliance Tiers

| Score | Tier | Indicator |
|-------|------|-----------|
| 90-100% | Excellent | 🟢 |
| 75-89% | Good | 🟡 |
| 50-74% | Needs Improvement | 🟠 |
| 0-49% | Critical Issues | 🔴 |

## Repository-Specific Compliance

Each repository receives its own compliance issue when failing. The issue includes:

- Current compliance score and tier
- List of failed checks with priorities
- Link to COMPLIANCE.md requirements
- Link to full compliance report

Issues are automatically:
- Created when compliance falls below 50%
- Deduplicated (won't create duplicates)
- Labeled with `compliance` and `critical`

## Architecture Decisions

See [adr/](./adr/) for Architecture Decision Records documenting key decisions made about:

- Compliance framework design
- GitHub App integration approach
- Issue template format
- Deduplication strategy

## Contributing

When adding new compliance checks:

1. Review existing checks in `compliance/checks/`
2. Follow the standard script pattern
3. Document in COMPLIANCE.md
4. Update this documentation
5. Test locally before committing

## Troubleshooting

### Common Issues

**"Permission denied" when running checks:**
```bash
chmod +x compliance/checks/*.sh
chmod +x compliance/run-all-checks.sh
```

**"Repository not found" in workflow:**
- Check GitHub App is installed on target repository
- Verify APP_ID and APP_PRIVATE_KEY secrets are set

**Duplicate issues created:**
- Ensure latest workflow version is running
- Check deduplication logic in workflow

## References

- [ADR Pattern Documentation](https://adr.github.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Apps Documentation](https://docs.github.com/en/apps)

## Last Updated

2025-11-29
