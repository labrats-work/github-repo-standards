#!/bin/bash
# COMP-001: Check if README.md exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-001"
CHECK_NAME="README.md Exists"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -f "$REPO_PATH/README.md" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"README.md found\"}"
    exit 0
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"README.md not found in repository root\"}"
    exit 1
fi
