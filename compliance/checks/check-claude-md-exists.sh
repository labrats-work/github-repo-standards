#!/bin/bash
# COMP-004: Check if CLAUDE.md exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-004"
CHECK_NAME="CLAUDE.md Exists"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -f "$REPO_PATH/CLAUDE.md" ]; then
    # Check if CLAUDE.md has meaningful content (more than just a title)
    LINE_COUNT=$(wc -l < "$REPO_PATH/CLAUDE.md")
    if [ "$LINE_COUNT" -gt 5 ]; then
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"CLAUDE.md found with content ($LINE_COUNT lines)\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"CLAUDE.md exists but has minimal content (only $LINE_COUNT lines)\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"CLAUDE.md not found in repository root\"}"
    exit 1
fi
