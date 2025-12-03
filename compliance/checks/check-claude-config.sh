#!/bin/bash
# COMP-010: Check if .claude/ configuration exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-010"
CHECK_NAME=".claude/ Configuration"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -d "$REPO_PATH/.claude" ]; then
    # Check for any configuration files
    CONFIG_COUNT=$(find "$REPO_PATH/.claude" -type f | wc -l)
    if [ "$CONFIG_COUNT" -gt 0 ]; then
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\".claude/ directory exists with $CONFIG_COUNT file(s)\"}"
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\".claude/ directory exists but is empty\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\".claude/ directory not found\"}"
    exit 1
fi
