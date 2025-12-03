#!/bin/bash
# COMP-006: Check if docs/ directory exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-006"
CHECK_NAME="docs/ Directory"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -d "$REPO_PATH/docs" ]; then
    # Check if docs/ has at least README.md
    if [ -f "$REPO_PATH/docs/README.md" ]; then
        FILE_COUNT=$(find "$REPO_PATH/docs" -type f -name "*.md" | wc -l)
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"docs/ directory exists with README.md and $FILE_COUNT markdown files\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"docs/ directory exists but missing README.md\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"docs/ directory not found\"}"
    exit 1
fi
