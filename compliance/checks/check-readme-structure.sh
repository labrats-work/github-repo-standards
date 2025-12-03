#!/bin/bash
# COMP-005: Check if README has standard structure

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-005"
CHECK_NAME="README Structure"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

if [ ! -f "$REPO_PATH/README.md" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"README.md not found, cannot check structure\"}"
    exit 1
fi

README_CONTENT=$(cat "$REPO_PATH/README.md")

# Required sections
REQUIRED_SECTIONS=("Purpose" "Quick Start" "Structure")
MISSING_SECTIONS=()

for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! echo "$README_CONTENT" | grep -qi "^##.*$section"; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [ ${#MISSING_SECTIONS[@]} -eq 0 ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"README contains all required sections\"}"
    exit 0
else
    MISSING_LIST=$(IFS=,; echo "${MISSING_SECTIONS[*]}")
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"README missing required sections: $MISSING_LIST\"}"
    exit 1
fi
