#!/bin/bash
# Script to enable branch rulesets for all repositories
# This script creates a default branch ruleset with basic protection

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default ruleset configuration
RULESET_NAME="Default Branch Protection"

# List of repositories to configure (from compliance failures)
REPOS=(
  "action-ansible"
  "action-terraform"
  "github-app-tools"
  "github-repo-standards"
  "infra"
  "labrats-compliance"
  "modules-ansible"
  "modules-terraform"
  "ops-images"
  "projector"
  "terraform-provider-opnsense"
  ".github"
  "actions.common"
  "actions.terraform"
)

OWNER="labrats-work"

echo "=========================================="
echo "Branch Ruleset Configuration Script"
echo "=========================================="
echo ""
echo "This script will create branch rulesets for ${#REPOS[@]} repositories"
echo "Owner: $OWNER"
echo ""

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
  echo -e "${RED}Error: GitHub CLI is not authenticated${NC}"
  echo "Please run: gh auth login"
  exit 1
fi

# Function to get default branch
get_default_branch() {
  local repo=$1
  gh api "repos/$OWNER/$repo" --jq '.default_branch' 2>/dev/null || echo "main"
}

# Function to check if repo is archived
is_repo_archived() {
  local repo=$1
  local archived=$(gh api "repos/$OWNER/$repo" --jq '.archived' 2>/dev/null || echo "false")
  [ "$archived" = "true" ]
}

# Function to check if rulesets exist
check_existing_rulesets() {
  local repo=$1
  gh api "repos/$OWNER/$repo/rulesets" --jq '. | length' 2>/dev/null || echo "0"
}

# Function to create branch ruleset
create_branch_ruleset() {
  local repo=$1
  local default_branch=$(get_default_branch "$repo")

  echo -e "${YELLOW}Creating ruleset for $repo (branch: $default_branch)...${NC}"

  # Create ruleset JSON
  local ruleset_json=$(cat <<EOF
{
  "name": "$RULESET_NAME",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/$default_branch"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [],
        "strict_required_status_checks_policy": false
      }
    }
  ],
  "bypass_actors": []
}
EOF
)

  # Create the ruleset
  if gh api -X POST "repos/$OWNER/$repo/rulesets" \
    --input - <<< "$ruleset_json" &>/dev/null; then
    echo -e "${GREEN}✓ Created ruleset for $repo${NC}"
    return 0
  else
    echo -e "${RED}✗ Failed to create ruleset for $repo${NC}"
    return 1
  fi
}

# Main execution
success_count=0
skip_count=0
fail_count=0

for repo in "${REPOS[@]}"; do
  echo ""
  echo "Processing: $repo"
  echo "------------------------------------------"

  # Check if repo is accessible
  if ! gh api "repos/$OWNER/$repo" &>/dev/null; then
    echo -e "${RED}✗ Repository not accessible: $repo${NC}"
    ((fail_count++))
    continue
  fi

  # Check if repo is archived
  if is_repo_archived "$repo"; then
    echo -e "${YELLOW}⊙ Repository is archived, skipping${NC}"
    ((skip_count++))
    continue
  fi

  # Check for existing rulesets
  existing_count=$(check_existing_rulesets "$repo")
  if [ "$existing_count" -gt 0 ]; then
    echo -e "${YELLOW}⊙ Repository already has $existing_count ruleset(s), skipping${NC}"
    ((skip_count++))
    continue
  fi

  # Create the ruleset
  if create_branch_ruleset "$repo"; then
    ((success_count++))
  else
    ((fail_count++))
  fi
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo -e "${GREEN}✓ Successfully created: $success_count${NC}"
echo -e "${YELLOW}⊙ Skipped (already configured): $skip_count${NC}"
echo -e "${RED}✗ Failed: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
  echo -e "${GREEN}All repositories processed successfully!${NC}"
  exit 0
else
  echo -e "${YELLOW}Some repositories failed. Check the output above for details.${NC}"
  exit 1
fi
