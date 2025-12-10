# Repository Standards Internal Automation

## Purpose

**Private GitHub App** for internal automation of the github-repo-standards repository.

Handles automated commits, PR creation, and PR merging for compliance reports. This app is private and only for use within your-org organization.

## Permissions

- `contents: write` - To create branches and commit compliance reports
- `pull_requests: write` - To create and auto-merge PRs
- `metadata: read` - Automatic, required for basic repository information

## Installation

Install this app **ONLY on github-repo-standards** repository.

## Workflow Usage

This app is used in the following workflow job:

### aggregate-results job
- Creates a new branch with compliance reports
- Commits the aggregated compliance results
- Creates a PR with the reports
- Enables auto-merge on the PR (squash merge)
- PR auto-merges when branch protection requirements are met

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
   - App ID → GitHub Secrets as `INTERNAL_AUTOMATION_APP_ID`
   - Private Key → GitHub Secrets as `INTERNAL_AUTOMATION_APP_PRIVATE_KEY`

3. Install the app ONLY on `github-repo-standards` repository

4. Add the app to branch protection bypass rules:
   - Go to: Repository Settings → Rulesets
   - Edit the main branch ruleset
   - Add "Repository Standards Internal Automation" to bypass actors
   - This allows the app to auto-merge PRs without review

5. Update the workflow to use these new secret names for the aggregate-results job

## Security Notes

- **Write access** to github-repo-standards only
- Can create and merge PRs automatically
- Should NOT be installed on other repositories
- Uses separate credentials from repo standards app
- Has branch protection bypass to enable auto-merge

## Auto-merge Behavior

When a compliance report PR is created:
1. App creates branch with reports
2. App commits changes
3. App creates PR
4. App enables auto-merge with squash
5. PR auto-merges immediately (if app has bypass) or waits for approval
6. Branch is automatically deleted after merge
