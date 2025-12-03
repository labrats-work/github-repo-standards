#!/bin/bash
# COMP-009: Check if ADR pattern is implemented

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-009"
CHECK_NAME="ADR Pattern"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

ADR_DIR="$REPO_PATH/docs/adr"

if [ -d "$ADR_DIR" ]; then
    # Check for ADR files (numbered like 0001-*.md)
    ADR_COUNT=$(find "$ADR_DIR" -type f -name "[0-9][0-9][0-9][0-9]-*.md" | wc -l)

    # Check for INDEX.md
    HAS_INDEX=false
    if [ -f "$ADR_DIR/INDEX.md" ]; then
        HAS_INDEX=true
    fi

    if [ "$ADR_COUNT" -gt 0 ]; then
        if [ "$HAS_INDEX" = true ]; then
            echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Found $ADR_COUNT ADR(s) with INDEX.md\"}"
        else
            echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"Found $ADR_COUNT ADR(s) but missing INDEX.md\"}"
        fi
        exit 0
    else
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"docs/adr/ exists but contains no ADR files\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"ADR directory not found (docs/adr/)\"}"
    exit 1
fi
