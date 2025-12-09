#!/bin/bash
# Script to fix COMP-001: README.md Missing
# Creates basic README.md files for repositories that don't have them

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Require GITHUB_ORG environment variable
if [ -z "${GITHUB_ORG:-}" ]; then
  echo "Error: GITHUB_ORG environment variable is required"
  echo "Usage: GITHUB_ORG=your-org $0"
  exit 1
fi

OWNER="$GITHUB_ORG"
CLONE_DIR="/tmp/fix-comp-001"

# Check if repository was provided
if [ $# -ne 1 ]; then
  echo "Error: Exactly one repository name required"
  echo "Usage: GITHUB_ORG=your-org $0 <repository>"
  echo ""
  echo "Example:"
  echo "  GITHUB_ORG=labrats-work $0 my-repo"
  echo ""
  echo "To process multiple repos, use a loop:"
  echo "  for repo in repo1 repo2; do"
  echo "    GITHUB_ORG=labrats-work $0 \$repo"
  echo "  done"
  exit 1
fi

REPO="$1"

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
  echo -e "${RED}Error: GitHub CLI is not authenticated${NC}"
  echo "Please run: gh auth login"
  exit 1
fi

# Check if repo is accessible
if ! gh api "repos/$OWNER/$REPO" &>/dev/null; then
  echo -e "${RED}✗ Repository not accessible: $REPO${NC}"
  exit 1
fi

# Check if repo is archived
archived=$(gh api "repos/$OWNER/$REPO" --jq '.archived' 2>/dev/null || echo "false")
if [ "$archived" = "true" ]; then
  echo -e "${YELLOW}⊙ Repository is archived, skipping${NC}"
  exit 0
fi

# Clean up and create clone directory
rm -rf "$CLONE_DIR"
mkdir -p "$CLONE_DIR"
cd "$CLONE_DIR"

# Get repository description
description=$(gh api "repos/$OWNER/$REPO" --jq '.description // ""' 2>/dev/null || echo "")

# Clone repository
if ! gh repo clone "$OWNER/$REPO" 2>/dev/null; then
  echo -e "${RED}✗ Failed to clone $REPO${NC}"
  exit 1
fi

cd "$REPO"

# Check if README.md already exists
if [ -f "README.md" ]; then
  echo -e "${YELLOW}⊙ README.md already exists, skipping${NC}"
  cd ..
  rm -rf "$REPO"
  rm -rf "$CLONE_DIR"
  exit 0
fi

# Create README.md with basic content
cat > README.md <<EOF
# $REPO

$description

## Purpose

[Describe the purpose and goals of this repository]

## Quick Start

\`\`\`bash
# Add quick start instructions here
\`\`\`

## Project Structure

\`\`\`
[Describe the repository structure]
\`\`\`

## Related Repositories

- [$OWNER](https://github.com/$OWNER) - Organization repositories

## License

[Specify license]
EOF

# Commit and push
git add README.md
git commit -m "docs: Add initial README.md

Addresses COMP-001 compliance requirement.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

if git push 2>/dev/null; then
  echo -e "${GREEN}✓ Created README.md for $REPO${NC}"
  exit_code=0
else
  echo -e "${RED}✗ Failed to push README.md for $REPO${NC}"
  exit_code=1
fi

# Clean up
cd ..
rm -rf "$REPO"
rm -rf "$CLONE_DIR"

exit $exit_code
