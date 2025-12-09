#!/bin/bash
# COMP-019: Verify repository uses branch rulesets instead of classic branch protection

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-019"
CHECK_NAME="Branch Rulesets (not Classic Protection)"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

# Check if this is a git repository
if [ ! -d "$REPO_PATH/.git" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"Not a git repository\"}"
    exit 0
fi

# Extract repository owner and name from git remote
cd "$REPO_PATH"
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"No git remote configured\"}"
    exit 0
fi

# Parse owner/repo from URL (handles both HTTPS and SSH formats)
# Handles repos with dots in names like .github, actions.common, etc.
if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    # Remove .git suffix if present
    REPO="${REPO%.git}"
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"Could not parse GitHub repository from remote URL\"}"
    exit 0
fi

# Determine the default branch (main or master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Check for classic branch protection
CLASSIC_PROTECTION=$(gh api "repos/$OWNER/$REPO/branches/$DEFAULT_BRANCH/protection" 2>&1 || echo "NOT_PROTECTED")

# Check for branch rulesets
RULESETS_RESPONSE=$(gh api "repos/$OWNER/$REPO/rulesets" 2>&1 || echo "ERROR")

if echo "$RULESETS_RESPONSE" | grep -q "ERROR\|Not Found"; then
    # Can't check rulesets - might be permissions issue
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"Unable to check branch rulesets (API error or insufficient permissions)\"}"
    exit 0
fi

# Parse rulesets to check if any apply to the default branch
HAS_RULESETS=false
RULESET_COUNT=$(echo "$RULESETS_RESPONSE" | jq '. | length' 2>/dev/null || echo "0")

if [ "$RULESET_COUNT" -gt 0 ]; then
    # Check if any ruleset targets the default branch
    for i in $(seq 0 $((RULESET_COUNT - 1))); do
        RULESET_ID=$(echo "$RULESETS_RESPONSE" | jq -r ".[$i].id" 2>/dev/null || echo "")
        RULESET_TARGET=$(echo "$RULESETS_RESPONSE" | jq -r ".[$i].target" 2>/dev/null || echo "")

        # Check if ruleset targets branches
        if [ "$RULESET_TARGET" = "branch" ]; then
            # Fetch full ruleset details (list endpoint doesn't include conditions)
            RULESET_DETAIL=$(gh api "repos/$OWNER/$REPO/rulesets/$RULESET_ID" 2>/dev/null || echo "{}")
            RULESET_CONDITIONS=$(echo "$RULESET_DETAIL" | jq -r '.conditions.ref_name.include[]?' 2>/dev/null || echo "")

            # Check if it applies to the default branch (via pattern or explicit name)
            if echo "$RULESET_CONDITIONS" | grep -q "~DEFAULT_BRANCH\|~ALL\|\*\|refs/heads/$DEFAULT_BRANCH"; then
                HAS_RULESETS=true
                break
            fi
        fi
    done
fi

# Check if classic protection is being used
HAS_CLASSIC_PROTECTION=false
if ! echo "$CLASSIC_PROTECTION" | grep -q "Branch not protected\|NOT_PROTECTED"; then
    HAS_CLASSIC_PROTECTION=true
fi

# Determine compliance status
if [ "$HAS_CLASSIC_PROTECTION" = "true" ] && [ "$HAS_RULESETS" = "false" ]; then
    # FAIL: Using classic protection without rulesets
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Branch '$DEFAULT_BRANCH' uses classic branch protection. Migrate to branch rulesets instead.\"}"
    exit 1
elif [ "$HAS_CLASSIC_PROTECTION" = "false" ] && [ "$HAS_RULESETS" = "false" ]; then
    # FAIL: No protection at all
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Branch '$DEFAULT_BRANCH' has no protection. Configure branch rulesets.\"}"
    exit 1
elif [ "$HAS_CLASSIC_PROTECTION" = "true" ] && [ "$HAS_RULESETS" = "true" ]; then
    # WARN: Using both (migration in progress)
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Branch '$DEFAULT_BRANCH' uses both classic protection and rulesets. Complete migration by removing classic protection.\"}"
    exit 1
else
    # PASS: Using only rulesets
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Branch '$DEFAULT_BRANCH' is protected using branch rulesets (count: $RULESET_COUNT)\"}"
    exit 0
fi
