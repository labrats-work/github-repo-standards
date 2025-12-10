#!/bin/bash
# Script to fix COMP-016: Branch Protection Missing
# Creates branch protection ruleset for default branch

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

# Check for existing rulesets
existing_count=$(gh api "repos/$OWNER/$REPO/rulesets" --jq 'length' 2>/dev/null || echo "0")
if [ "$existing_count" -gt 0 ]; then
  echo -e "${YELLOW}⊙ Repository already has $existing_count ruleset(s), skipping${NC}"
  exit 0
fi

# Create branch protection ruleset from template
TEMPLATE_DIR="$(dirname "$0")/templates"

echo -e "${YELLOW}Creating branch protection ruleset for $REPO...${NC}"
if cat "$TEMPLATE_DIR/branch-ruleset.json.tmpl" | gh api "repos/$OWNER/$REPO/rulesets" --input - &>/dev/null; then
  echo -e "${GREEN}✓ Created branch protection ruleset for $REPO${NC}"
  exit 0
else
  echo -e "${RED}✗ Failed to create ruleset for $REPO${NC}"
  exit 1
fi
