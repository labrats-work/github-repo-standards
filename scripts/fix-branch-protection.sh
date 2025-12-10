#!/bin/bash
# Quick script to enable branch rulesets for repos missing protection

OWNER="labrats-work"

# Simplified ruleset - just require pull requests
create_ruleset() {
  local repo=$1

  echo "Creating ruleset for $repo..."

  gh api -X POST "repos/$OWNER/$repo/rulesets" --input - <<EOF
{
  "name": "Default",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["~DEFAULT_BRANCH"],
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
    }
  ],
  "bypass_actors": []
}
EOF
}

# Process only non-archived repos without existing rulesets
for repo in github-repo-standards infra github-app-tools modules-ansible modules-terraform ops-images projector terraform-provider-opnsense; do
  # Check if archived
  archived=$(gh api "repos/$OWNER/$repo" --jq '.archived' 2>/dev/null || echo "true")
  if [ "$archived" = "true" ]; then
    echo "⊙ Skipping archived repo: $repo"
    continue
  fi

  # Check if has rulesets
  ruleset_count=$(gh api "repos/$OWNER/$repo/rulesets" --jq 'length' 2>/dev/null || echo "0")
  if [ "$ruleset_count" -gt 0 ]; then
    echo "✓ $repo already has rulesets"
    continue
  fi

  # Create ruleset
  if create_ruleset "$repo" 2>&1; then
    echo "✓ Created ruleset for $repo"
  else
    echo "✗ Failed to create ruleset for $repo"
  fi
  echo ""
done

echo "Done!"
