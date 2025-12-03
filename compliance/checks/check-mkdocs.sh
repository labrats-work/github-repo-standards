#!/bin/bash
# COMP-013: Check if MkDocs is configured

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-013"
CHECK_NAME="MkDocs Configuration"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -f "$REPO_PATH/mkdocs.yml" ]; then
    # Check if docs/ directory exists with content
    if [ -d "$REPO_PATH/docs" ]; then
        DOC_COUNT=$(find "$REPO_PATH/docs" -type f -name "*.md" | wc -l)
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"MkDocs configured with $DOC_COUNT markdown files\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"mkdocs.yml exists but docs/ directory not found\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"mkdocs.yml not found\"}"
    exit 1
fi
