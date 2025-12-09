# Compliance Fix Scripts

This directory contains automated scripts to fix CRITICAL and HIGH priority compliance failures across all organization repositories.

## Available Scripts

### Individual Fix Scripts

Each script addresses a specific compliance check:

- **fix-comp-001-readme.sh** - Creates basic README.md files (CRITICAL)
- **fix-comp-002-license.sh** - Creates MIT LICENSE files (CRITICAL)
- **fix-comp-003-gitignore.sh** - Creates comprehensive .gitignore files (CRITICAL)
- **fix-comp-004-claudemd.sh** - Creates CLAUDE.md context files (CRITICAL)
- **fix-comp-016-branch-protection.sh** - Creates branch rulesets (HIGH)
- **fix-comp-017-repo-settings.sh** - Enables squash merge (HIGH)

### Master Script

- **fix-all-critical-high.sh** - Runs all fix scripts in the optimal order

## Usage

### Run All Fixes

To fix all CRITICAL and HIGH priority compliance issues:

```bash
cd /path/to/github-repo-standards
./compliance/scripts/fix-all-critical-high.sh
```

### Run Individual Fixes

To address specific compliance issues:

```bash
# Fix repository settings only
./compliance/scripts/fix-comp-017-repo-settings.sh

# Fix branch protection only
./compliance/scripts/fix-comp-016-branch-protection.sh

# Fix missing README files only
./compliance/scripts/fix-comp-001-readme.sh
```

## How It Works

### API-Based Fixes (COMP-016, COMP-017)

These scripts use the GitHub API to update repository settings and create branch rulesets without cloning repositories.

- **COMP-017**: Enables squash merge as the default merge method
- **COMP-016**: Creates branch rulesets using `~DEFAULT_BRANCH` pattern

### File-Based Fixes (COMP-001, COMP-002, COMP-003, COMP-004)

These scripts clone each repository, create the missing file, commit, and push:

1. Clone repository to `/tmp/fix-comp-XXX/`
2. Check if file already exists (skip if yes)
3. Create file with appropriate content
4. Commit with standardized message
5. Push to remote
6. Clean up temporary directory

## Prerequisites

## Initial Setup

Before running fix scripts, you need to configure which repositories to process.

### Method 1: Edit Script Directly

Open the fix script and uncomment/populate the REPOS array:

```bash
vim compliance/scripts/fix-comp-001-readme.sh
```

```bash
REPOS=(
  "my-repo-1"
  "my-repo-2"
  "my-repo-3"
)
```

### Method 2: Dynamic Discovery

Use GitHub CLI to discover repositories automatically:

```bash
# Edit script to use dynamic discovery
REPOS=($(gh repo list your-org --limit 1000 --json name --jq ".[].name"))
```

### Method 3: Filter by Topic

Discover repositories with specific topics:

```bash
# Get all repos with "infrastructure" topic
REPOS=($(gh repo list your-org --topic infrastructure --json name --jq ".[].name"))
```

### Example: Running After Configuration

```bash
# 1. Set your organization
export GITHUB_ORG="my-organization"

# 2. Edit script to add repositories
vim compliance/scripts/fix-comp-001-readme.sh

# 3. Run the script
./compliance/scripts/fix-comp-001-readme.sh
```


- GitHub CLI (`gh`) must be installed and authenticated
- User must have push access to all repositories
- Internet connection required

## Safety Features

- Skips archived repositories automatically
- Checks if file/setting already exists before creating
- Provides summary of successes, skips, and failures
- Uses transactions (all-or-nothing per repository)
- Temporary directories are cleaned up automatically

## Output

Each script provides:
- Real-time progress updates
- Color-coded status messages (green=success, yellow=skip, red=error)
- Final summary with counts

## What Gets Created

### README.md
Basic structure with:
- Repository title and description
- Purpose section (requires manual completion)
- Quick Start placeholder
- Project Structure placeholder
- Related repositories links

### LICENSE
MIT License with:
- Current year
- Your Organization as copyright holder

### .gitignore
Comprehensive ignore patterns for:
- Operating system files
- IDE/editor files
- Build directories (node_modules, .terraform, etc.)
- Environment files and secrets
- Logs and temporary files
- Language-specific artifacts (Python, Go, etc.)

### CLAUDE.md
AI assistant context file with:
- Repository overview
- Project architecture placeholders
- Common operations section
- Dependencies and configuration notes
- Important files documentation
- Guidelines for AI assistants
- Related repositories links

**Note**: Generated CLAUDE.md files include intelligent defaults based on repository type (Terraform, Ansible, Flux, etc.)

### Branch Rulesets
Creates "Default Branch Protection" ruleset with:
- Pull request requirement (0 approvals initially)
- Required status checks (none initially)
- `~DEFAULT_BRANCH` pattern for future-proofing

### Repository Settings
Updates to:
- `allow_squash_merge`: true
- `allow_merge_commit`: false
- `allow_rebase_merge`: false
- `delete_branch_on_merge`: true

## Customization

To customize the content of generated files, edit the heredoc sections in each script:

```bash
cat > FILENAME <<EOF
Your custom content here
EOF
```

## Troubleshooting

### Authentication Errors

```bash
gh auth login
gh auth status
```

### Permission Errors

Ensure you have push access to all repositories.

### Script Fails on Specific Repo

Check the output - the script will continue with other repositories even if one fails.

## After Running

1. Review generated files in each repository
2. Customize template content (README purpose, CLAUDE.md details, etc.)
3. Run compliance checks again to verify:

```bash
./compliance/run-all-checks.sh --all --format markdown
```

## Expected Impact

### Before
- Typical repository score: 13-43% (Critical Issues)
- Missing essential files
- No branch protection
- No merge strategy

### After
- Expected repository score: 70-85% (Good to Needs Improvement)
- All CRITICAL checks passing
- All HIGH checks passing
- Remaining issues are mostly MEDIUM/LOW priority

## Next Steps

After running these scripts, focus on:
- COMP-005 (HIGH): Improve README structure with required sections
- COMP-006 (HIGH): Add docs/ directory with README
- Medium and low priority items as time permits

## Configuration

### Environment Variables

The fix scripts use the following environment variable:

- **GITHUB_ORG** - Your GitHub organization name (default: "your-org")

Set before running scripts:

```bash
export GITHUB_ORG="my-organization"
./scripts/fix-all-critical-high.sh
```

Or inline:

```bash
GITHUB_ORG="my-organization" ./scripts/fix-all-critical-high.sh
```

### Repository-Specific Configuration

Each fix script automatically:
- Detects repository ownership from git remote
- Skips archived repositories
- Checks existing files/settings before creating
- Uses the organization from GITHUB_ORG environment variable

