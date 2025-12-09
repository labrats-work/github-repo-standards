# Repository Standards Compliance Bot

## Purpose

**Public GitHub App** for cross-repository compliance scanning and monitoring.

Can be installed by any organization or repository to monitor compliance with repository standards.

## Permissions

- `administration: read` - To check branch protection, repository settings, and default branch
- `contents: read` - To clone and scan repository files
- `issues: write` - To create/update/close compliance issues in failing repositories
- `metadata: read` - Automatic, required for basic repository information

## Installation

Install this app on **ALL repositories** you want to monitor for compliance.

## Workflow Usage

This app is used in the following workflow jobs:

### 1. discover-repos job
- Lists all repositories where the app is installed
- Creates the matrix for parallel compliance checking

### 2. check-compliance job (matrix)
- Clones each repository to scan for compliance
- Runs all compliance checks locally
- Uploads results as artifacts

### 3. aggregate-results job
- Creates/updates/closes issues in failing repositories
- Uses this app's token for cross-repository issue management

## Setup Instructions

1. Create the app using the manifest:
   ```bash
   # Generate the manifest URL
   cat github-app-manifest.json | jq -r . | pbcopy

   # Go to: https://github.com/organizations/your-org/settings/apps/new
   # Choose "From a manifest"
   # Paste the JSON
   ```

2. After creation, save the credentials:
   - App ID → GitHub Secrets as `REPO_STANDARDS_APP_ID`
   - Private Key → GitHub Secrets as `REPO_STANDARDS_APP_PRIVATE_KEY`

3. Install the app on all repositories to monitor

4. Update the workflow to use these new secret names

## Security Notes

- **Read-only** for repository contents (can clone but not modify)
- Can create issues but cannot modify code
- Should be installed broadly across all repos
- Uses separate credentials from internal automation
