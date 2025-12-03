#!/bin/bash
# COMP-012: Check if SECURITY.md exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-012"
CHECK_NAME="SECURITY.md"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -f "$REPO_PATH/SECURITY.md" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"SECURITY.md found\"}"
    exit 0
elif [ -f "$REPO_PATH/.github/SECURITY.md" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"SECURITY.md found in .github/\"}"
    exit 0
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"SECURITY.md not found\"}"
    exit 1
fi
