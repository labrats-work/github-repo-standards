#!/bin/bash
# COMP-003: Check if .gitignore exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-003"
CHECK_NAME=".gitignore Exists"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -f "$REPO_PATH/.gitignore" ]; then
    # Check if .gitignore is not empty
    if [ -s "$REPO_PATH/.gitignore" ]; then
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\".gitignore found and not empty\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\".gitignore exists but is empty\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\".gitignore not found in repository root\"}"
    exit 1
fi
