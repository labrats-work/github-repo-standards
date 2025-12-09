# Compliance Fix Scripts

Automated scripts to fix CRITICAL and HIGH priority compliance failures for individual repositories.

## Available Scripts

Each script processes ONE repository at a time and requires `GITHUB_ORG` environment variable:

- **fix-comp-001-readme.sh** - Creates basic README.md files (CRITICAL)
- **fix-comp-002-license.sh** - Creates MIT LICENSE files (CRITICAL)
- **fix-comp-003-gitignore.sh** - Creates comprehensive .gitignore files (CRITICAL)
- **fix-comp-004-claudemd.sh** - Creates CLAUDE.md context files (CRITICAL)
- **fix-comp-016-branch-protection.sh** - Creates branch rulesets (HIGH)
- **fix-comp-017-repo-settings.sh** - Enables squash merge (HIGH)

## Usage

### Single Repository

Each script operates on exactly ONE repository passed as a parameter:

```bash
# Fix README for a single repository
GITHUB_ORG=your-org ./compliance/scripts/fix-comp-001-readme.sh my-repo

# Fix LICENSE for a single repository
GITHUB_ORG=your-org ./compliance/scripts/fix-comp-002-license.sh my-repo

# Fix repository settings for a single repository
GITHUB_ORG=your-org ./compliance/scripts/fix-comp-017-repo-settings.sh my-repo
```

### Multiple Repositories

To process multiple repositories, iterate in your caller script or shell:

```bash
# Fix README for multiple repositories
for repo in repo1 repo2 repo3; do
  GITHUB_ORG=your-org ./compliance/scripts/fix-comp-001-readme.sh $repo
done

# Fix all CRITICAL issues for specific repositories
for script in fix-comp-001-*.sh fix-comp-002-*.sh fix-comp-003-*.sh fix-comp-004-*.sh; do
  for repo in repo1 repo2; do
    GITHUB_ORG=your-org ./compliance/scripts/$script $repo
  done
done
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
- labrats-work as copyright holder

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

## Template System

Generated files use reusable templates from `compliance/scripts/templates/`:

- **README.md.tmpl** - Repository documentation template
- **LICENSE.tmpl** - MIT License template
- **gitignore.tmpl** - Comprehensive ignore patterns
- **CLAUDE.md.tmpl** - AI context documentation template
- **branch-ruleset.json.tmpl** - Branch protection ruleset configuration

### Template Variables

Templates use `{{VARIABLE}}` syntax for substitution:

- `{{REPO}}` - Repository name
- `{{DESCRIPTION}}` - Repository description from GitHub
- `{{OWNER}}` - Organization/owner name (from GITHUB_ORG)
- `{{YEAR}}` - Current year
- `{{REPO_TYPE}}` - Detected repository type (Terraform, Node.js, Python, etc.)
- `{{DATE}}` - Current date (YYYY-MM-DD)

### Customization

To customize generated content:

1. Edit template files in `compliance/scripts/templates/`
2. Add new variables to templates using `{{VARIABLE}}` syntax
3. Update corresponding script to perform substitution with `sed`

Example:
```bash
sed -e "s|{{REPO}}|$REPO|g" \
    -e "s|{{OWNER}}|$OWNER|g" \
    "$TEMPLATE_DIR/README.md.tmpl" > README.md
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
