#!/bin/bash
# Script to fix COMP-004: CLAUDE.md Missing
# Creates CLAUDE.md AI context file for a repository

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
CLONE_DIR="/tmp/fix-comp-004"

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

# Get repository description
description=$(gh api "repos/$OWNER/$REPO" --jq '.description // ""' 2>/dev/null || echo "")

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

# Check if CLAUDE.md already exists
if [ -f "CLAUDE.md" ]; then
  echo -e "${YELLOW}⊙ CLAUDE.md already exists, skipping${NC}"
  cd ../..
  rm -rf "$CLONE_DIR"
  exit 0
fi

# Detect repository type for intelligent defaults
repo_type="General"
if [[ "$REPO" =~ terraform ]] || [ -f "main.tf" ]; then
  repo_type="Terraform"
elif [[ "$REPO" =~ ansible ]] || [ -f "playbook.yml" ]; then
  repo_type="Ansible"
elif [[ "$REPO" =~ flux ]] || [ -d "clusters" ]; then
  repo_type="Flux"
elif [ -f "package.json" ]; then
  repo_type="Node.js"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  repo_type="Python"
fi

# Create CLAUDE.md from template
TEMPLATE_DIR="$(dirname "$0")/templates"
sed -e "s|{{REPO}}|$REPO|g" \
    -e "s|{{DESCRIPTION}}|$description|g" \
    -e "s|{{REPO_TYPE}}|$repo_type|g" \
    -e "s|{{OWNER}}|$OWNER|g" \
    -e "s|{{DATE}}|$(date +%Y-%m-%d)|g" \
    "$TEMPLATE_DIR/CLAUDE.md.tmpl" > CLAUDE.md

# Commit and push
git add CLAUDE.md
git commit -m "docs: Add CLAUDE.md AI context file

Addresses COMP-004 compliance requirement.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

if git push 2>/dev/null; then
  echo -e "${GREEN}✓ Created CLAUDE.md for $REPO${NC}"
  exit_code=0
else
  echo -e "${RED}✗ Failed to push CLAUDE.md for $REPO${NC}"
  exit_code=1
fi

# Clean up
cd ../..
rm -rf "$CLONE_DIR"

exit $exit_code
