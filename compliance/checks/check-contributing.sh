#!/bin/bash
# COMP-011: Check if CONTRIBUTING.md exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-011"
CHECK_NAME="CONTRIBUTING.md"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ -f "$REPO_PATH/CONTRIBUTING.md" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"CONTRIBUTING.md found\"}"
    exit 0
elif [ -f "$REPO_PATH/.github/CONTRIBUTING.md" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"CONTRIBUTING.md found in .github/\"}"
    exit 0
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"CONTRIBUTING.md not found\"}"
    exit 1
fi
