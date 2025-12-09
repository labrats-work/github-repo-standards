#!/bin/bash
# Script to fix COMP-003: .gitignore Missing
# Creates comprehensive .gitignore file for a repository

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Require GITHUB_ORG environment variable
if [ -z "${GITHUB_ORG:-}" ]; then
  echo "Error: GITHUB_ORG environment variable is required"
  echo "Usage: GITHUB_ORG=your-org $0 <repository>"
  exit 1
fi

# Check if repository was provided
if [ $# -ne 1 ]; then
  echo "Error: Exactly one repository name required"
  echo "Usage: GITHUB_ORG=your-org $0 <repository>"
  exit 1
fi

OWNER="$GITHUB_ORG"
REPO="$1"
CLONE_DIR="/tmp/fix-comp-003"

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
  echo -e "${RED}Error: GitHub CLI is not authenticated${NC}"
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

# Clone repository
if ! gh repo clone "$OWNER/$REPO" 2>/dev/null; then
  echo -e "${RED}✗ Failed to clone $REPO${NC}"
  exit 1
fi

cd "$REPO"

# Check if .gitignore already exists
if [ -f ".gitignore" ]; then
  echo -e "${YELLOW}⊙ .gitignore already exists, skipping${NC}"
  cd ../..
  rm -rf "$CLONE_DIR"
  exit 0
fi

# Create comprehensive .gitignore
cat > .gitignore <<'EOF'
# OS Files
.DS_Store
Thumbs.db
*~

# IDE
.vscode/
.idea/
*.swp
*.swo

# Build artifacts
dist/
build/
*.pyc
__pycache__/
node_modules/
.terraform/
*.tfstate
*.tfstate.backup

# Logs
*.log
logs/

# Environment
.env
.env.local
*.key
*.pem

# Temporary files
tmp/
temp/
*.tmp
EOF

# Commit and push
git add .gitignore
git commit -m "chore: Add .gitignore

Addresses COMP-003 compliance requirement.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

if git push 2>/dev/null; then
  echo -e "${GREEN}✓ Created .gitignore for $REPO${NC}"
  exit_code=0
else
  echo -e "${RED}✗ Failed to push .gitignore for $REPO${NC}"
  exit_code=1
fi

# Clean up
cd ../..
rm -rf "$CLONE_DIR"

exit $exit_code
