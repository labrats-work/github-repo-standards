#!/bin/bash
# COMP-018: Check if main is the default branch

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-018"
CHECK_NAME="Default Branch"

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

# Fetch repository information using GitHub API
REPO_INFO=$(gh api "repos/$OWNER/$REPO" 2>&1 || echo "ERROR")

if echo "$REPO_INFO" | grep -q "ERROR\|Not Found"; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Unable to fetch repository information (API error)\"}"
    exit 1
fi

# Get the default branch name
DEFAULT_BRANCH=$(echo "$REPO_INFO" | jq -r '.default_branch' 2>/dev/null || echo "")

if [ -z "$DEFAULT_BRANCH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Could not determine default branch\"}"
    exit 1
fi

# Check if default branch is 'main'
if [ "$DEFAULT_BRANCH" = "main" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Default branch is 'main'\"}"
    exit 0
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Default branch is '$DEFAULT_BRANCH', should be 'main'\"}"
    exit 1
fi
