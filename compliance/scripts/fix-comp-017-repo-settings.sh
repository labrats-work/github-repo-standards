#!/bin/bash
# Script to fix COMP-017: Repository Settings
# Enables squash merge as the default merge method

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

# Enable squash merge (most common for clean history)
echo -e "${YELLOW}Enabling squash merge for $REPO...${NC}"
if gh api -X PATCH "repos/$OWNER/$REPO" \
  -f allow_squash_merge=true \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f delete_branch_on_merge=true &>/dev/null; then
  echo -e "${GREEN}✓ Enabled squash merge for $REPO${NC}"
  exit 0
else
  echo -e "${RED}✗ Failed to update settings for $REPO${NC}"
  exit 1
fi
