#!/bin/bash
# COMP-008: Check if issue templates exist

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-008"
CHECK_NAME="Issue Templates"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

TEMPLATE_DIR="$REPO_PATH/.github/ISSUE_TEMPLATE"

if [ -d "$TEMPLATE_DIR" ]; then
    TEMPLATE_COUNT=$(find "$TEMPLATE_DIR" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) | wc -l)
    if [ "$TEMPLATE_COUNT" -gt 0 ]; then
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Found $TEMPLATE_COUNT issue template(s)\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\".github/ISSUE_TEMPLATE/ exists but contains no templates\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"No issue templates found (.github/ISSUE_TEMPLATE/ not found)\"}"
    exit 1
fi
