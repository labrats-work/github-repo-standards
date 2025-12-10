# Changelog

All notable changes to the github-repo-standards compliance framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2025-12-10

### ⚠️ BREAKING CHANGES

This release introduces environment-based configuration which requires manual setup of GitHub Secrets and Variables.

**Migration Required:** See [upgrade.md](docs/upgrade.md) for detailed upgrade instructions.

**Impact:**
- Workflows will fail without proper configuration
- 4 required secrets must be configured
- 6 optional variables available (all have defaults)

### Added

- **Environment-based configuration** for organization-specific customization
- **docs/setup.md** - Comprehensive setup guide for new installations
- **docs/upgrade.md** - Migration guide for existing installations
- **CHANGELOG.md** - Version history and changelog
- **.env.example** - Configuration reference with all options documented
- **6 configurable variables** with sensible defaults:
  - `STANDARDS_REPO_NAME` (default: `github-repo-standards`)
  - `MAX_PARALLEL_JOBS` (default: `10`)
  - `ARTIFACT_RETENTION_DAYS` (default: `30`)
  - `DEFAULT_BRANCH` (default: `main`)
  - `COMPLIANCE_LABEL` (default: `compliance`)
  - `CRITICAL_LABEL` (default: `critical`)

### Changed

- **Workflow configuration** now uses environment variables instead of hardcoded values
- **Repository references** now use `STANDARDS_REPO_NAME` variable
- **Parallelism** now configurable via `MAX_PARALLEL_JOBS` variable
- **Issue labels** now configurable via `COMPLIANCE_LABEL` and `CRITICAL_LABEL` variables
- **Documentation structure** reorganized with dedicated setup and upgrade guides

### Fixed

- Repository name assumptions now configurable (supports renamed repositories)
- Parallel job limits now adjustable (prevents rate limiting issues)
- Label names now customizable (supports organization-specific conventions)

### Security

- **Clear separation** between secrets (sensitive) and variables (configuration)
- **Documented security model** in SETUP.md and SECURITY.md
- **Private key format validation** guidance in UPGRADE.md

---

## [1.9.0] - 2025-12-09

### Added

- **New compliance checks:**
  - COMP-014: ADR Quality validation
  - COMP-015: Deprecated Actions detection
  - COMP-016: Branch Protection verification
  - COMP-017: Repository Settings validation
  - COMP-018: Default Branch checking
  - COMP-019: Branch Rulesets enforcement

- **Documentation:**
  - API_PERMISSIONS.md - Comprehensive API permissions reference
  - SECURITY.md - Security policy and vulnerability reporting
  - CONTRIBUTING.md - Contribution guidelines

- **Automated fix scripts:**
  - `fix-comp-001-readme.sh` - README creation
  - `fix-comp-002-license.sh` - LICENSE addition
  - `fix-comp-003-gitignore.sh` - .gitignore creation
  - `fix-comp-004-claudemd.sh` - CLAUDE.md generation
  - `fix-comp-016-branch-protection.sh` - Branch rulesets setup
  - `fix-comp-017-repo-settings.sh` - Repository settings configuration

- **Infrastructure:**
  - Two-app architecture (Repo Standards Bot + Internal Automation)
  - Template system for generated files
  - Compliance reports directory with historical data
  - Top-level utility scripts for branch management

### Changed

- **Compliance scoring** updated to 81 total points (from 68)
- **Check priorities** rebalanced with new HIGH-priority API checks
- **Workflow** enhanced with better logging and issue creation
- **Documentation** expanded with detailed setup instructions

---

## [1.0.0] - 2025-12-03

### Added

- Initial release of compliance framework
- **13 compliance checks** (COMP-001 through COMP-013):
  - 4 CRITICAL: README, LICENSE, .gitignore, CLAUDE.md
  - 3 HIGH: README structure, docs/, workflows
  - 3 MEDIUM: Issue templates, ADRs, .claude/ config
  - 3 LOW: CONTRIBUTING, SECURITY, MkDocs

- **Compliance scoring system:**
  - Weighted scoring by priority
  - Tier system (Excellent, Good, Needs Improvement, Critical)
  - Automated issue creation for failures

- **Automation:**
  - Weekly scheduled checks (Mondays 9 AM UTC)
  - Parallel execution using matrix strategy
  - Automated report generation
  - Pull request creation for reports

- **Documentation:**
  - COMPLIANCE.md - Standards definition
  - GITHUB_APP_SETUP.md - GitHub App creation guide
  - README.md - Project overview and quick start

---

## Version Compatibility

| Version | GitHub Actions | GitHub Apps | Node.js | Bash |
|---------|----------------|-------------|---------|------|
| 2.0.0   | ≥ v4          | v1          | ≥ 16    | ≥ 4  |
| 1.x     | ≥ v3          | v1          | ≥ 16    | ≥ 4  |

---

## Migration Guides

- **v1.x → v2.0:** See [upgrade.md](docs/upgrade.md)

---

## Support

- **New installations:** Follow [setup.md](docs/setup.md)
- **Existing installations:** Follow [upgrade.md](docs/upgrade.md)
- **Issues:** Open an issue with the appropriate label (`bug`, `upgrade`, `enhancement`)
- **Security:** Follow [SECURITY.md](SECURITY.md) for vulnerability reporting

---

[2.0.0]: https://github.com/labrats-work/github-repo-standards/compare/v1.9.0...v2.0.0
[1.9.0]: https://github.com/labrats-work/github-repo-standards/compare/v1.0.0...v1.9.0
[1.0.0]: https://github.com/labrats-work/github-repo-standards/releases/tag/v1.0.0
