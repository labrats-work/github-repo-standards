#!/bin/bash
# COMP-016: Check if main branch has protection rules enabled

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-016"
CHECK_NAME="Branch Protection"

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

# Check branch protection using GitHub API
PROTECTION_RESPONSE=$(gh api "repos/$OWNER/$REPO/branches/$DEFAULT_BRANCH/protection" 2>&1 || echo "NOT_PROTECTED")

if echo "$PROTECTION_RESPONSE" | grep -q "Branch not protected"; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Branch '$DEFAULT_BRANCH' is not protected\"}"
    exit 1
elif echo "$PROTECTION_RESPONSE" | grep -q "Not Found"; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Branch '$DEFAULT_BRANCH' not found or repository not accessible\"}"
    exit 1
elif echo "$PROTECTION_RESPONSE" | grep -q "NOT_PROTECTED"; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Unable to check branch protection (API error)\"}"
    exit 1
else
    # Branch protection is enabled, let's check for specific rules
    PROTECTION_JSON="$PROTECTION_RESPONSE"

    # Check for required pull request reviews
    HAS_PR_REVIEWS=$(echo "$PROTECTION_JSON" | jq -r '.required_pull_request_reviews != null' 2>/dev/null || echo "false")

    if [ "$HAS_PR_REVIEWS" = "true" ]; then
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Branch '$DEFAULT_BRANCH' is protected with PR reviews required\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Branch '$DEFAULT_BRANCH' is protected (basic protection enabled)\"}"
        exit 0
    fi
fi
