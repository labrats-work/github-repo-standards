#!/bin/bash
# COMP-017: Check GitHub repository settings best practices

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-017"
CHECK_NAME="Repository Settings"

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

# Fetch repository settings using GitHub API
REPO_INFO=$(gh api "repos/$OWNER/$REPO" 2>&1 || echo "ERROR")

if echo "$REPO_INFO" | grep -q "ERROR\|Not Found"; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Unable to fetch repository information (API error)\"}"
    exit 1
fi

# Check repository settings
ISSUES_ENABLED=$(echo "$REPO_INFO" | jq -r '.has_issues' 2>/dev/null || echo "false")
WIKI_DISABLED=$(echo "$REPO_INFO" | jq -r '.has_wiki' 2>/dev/null || echo "true")
PROJECTS_DISABLED=$(echo "$REPO_INFO" | jq -r '.has_projects' 2>/dev/null || echo "true")
ALLOW_SQUASH=$(echo "$REPO_INFO" | jq -r '.allow_squash_merge' 2>/dev/null || echo "false")
ALLOW_MERGE_COMMIT=$(echo "$REPO_INFO" | jq -r '.allow_merge_commit' 2>/dev/null || echo "false")
ALLOW_REBASE=$(echo "$REPO_INFO" | jq -r '.allow_rebase_merge' 2>/dev/null || echo "false")
DELETE_BRANCH_ON_MERGE=$(echo "$REPO_INFO" | jq -r '.delete_branch_on_merge' 2>/dev/null || echo "false")

# Collect issues
ISSUES=()
WARNINGS=()

# Issues should be enabled for collaboration
if [ "$ISSUES_ENABLED" != "true" ]; then
    ISSUES+=("Issues disabled")
fi

# At least one merge method should be enabled
if [ "$ALLOW_SQUASH" != "true" ] && [ "$ALLOW_MERGE_COMMIT" != "true" ] && [ "$ALLOW_REBASE" != "true" ]; then
    ISSUES+=("No merge methods enabled")
fi

# Auto-delete branches after merge is a best practice
if [ "$DELETE_BRANCH_ON_MERGE" != "true" ]; then
    WARNINGS+=("Auto-delete branches on merge not enabled")
fi

# Check for vulnerability alerts (requires separate API call)
VULNERABILITY_ALERTS=$(gh api "repos/$OWNER/$REPO/vulnerability-alerts" 2>&1 || echo "NOT_ENABLED")
if echo "$VULNERABILITY_ALERTS" | grep -q "Not Found\|Vulnerability alerts are disabled"; then
    WARNINGS+=("Vulnerability alerts not enabled")
fi

# Determine pass/fail
if [ ${#ISSUES[@]} -eq 0 ]; then
    if [ ${#WARNINGS[@]} -eq 0 ]; then
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Repository settings follow best practices\"}"
        exit 0
    else
        WARNING_MSG=$(printf ", %s" "${WARNINGS[@]}")
        WARNING_MSG=${WARNING_MSG:2}  # Remove leading comma
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Repository settings acceptable (warnings: $WARNING_MSG)\"}"
        exit 0
    fi
else
    ISSUE_MSG=$(printf ", %s" "${ISSUES[@]}")
    ISSUE_MSG=${ISSUE_MSG:2}  # Remove leading comma
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository settings issues: $ISSUE_MSG\"}"
    exit 1
fi
