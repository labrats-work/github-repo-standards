# GitHub Apps

This directory contains GitHub App manifests for the compliance framework.

## Documentation

Full documentation for the two-app architecture is available in the `docs/` directory:

- **[docs/apps/README.md](../docs/apps/README.md)** - Overview, setup instructions, and troubleshooting
- **[docs/apps/repo-standards.md](../docs/apps/repo-standards.md)** - Repo Standards Bot (public scanning app)
- **[docs/apps/internal-automation.md](../docs/apps/internal-automation.md)** - Internal Automation (private automation app)
- **[docs/adr/0004-two-app-architecture.md](../docs/adr/0004-two-app-architecture.md)** - Architecture decision record

## Quick Start

1. See [docs/apps/README.md](../docs/apps/README.md) for complete setup instructions
2. Create both apps using the manifests in `repo-standards/` and `internal-automation/`
3. Install App 1 (Repo Standards) on all repositories to monitor
4. Install App 2 (Internal Automation) only on github-repo-standards
5. Configure secrets in GitHub Actions

## App Manifests

- `repo-standards/github-app-manifest.json` - Public scanning app manifest
- `internal-automation/github-app-manifest.json` - Private automation app manifest
