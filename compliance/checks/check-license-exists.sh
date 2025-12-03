#!/bin/bash
# COMP-002: Check if LICENSE file exists

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-002"
CHECK_NAME="LICENSE File Exists"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

# Check for common LICENSE file names
if [ -f "$REPO_PATH/LICENSE" ] || [ -f "$REPO_PATH/LICENSE.md" ] || [ -f "$REPO_PATH/LICENSE.txt" ] || [ -f "$REPO_PATH/LICENCE" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"LICENSE file found\"}"
    exit 0
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"LICENSE file not found (checked LICENSE, LICENSE.md, LICENSE.txt, LICENCE)\"}"
    exit 1
fi
