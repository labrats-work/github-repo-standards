#!/bin/bash
# COMP-014: Check ADR quality and conformance
# Evaluates ADRs based on required sections and content quality

set -e

REPO_PATH="${1:-.}"
CHECK_ID="COMP-014"
CHECK_NAME="ADR Quality"

if [ ! -d "$REPO_PATH" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Repository path does not exist: $REPO_PATH\"}"
    exit 1
fi

ADR_DIR="$REPO_PATH/docs/adr"

# If no ADR directory exists, skip this check (handled by COMP-009)
if [ ! -d "$ADR_DIR" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"ADR directory not found (checked by COMP-009)\"}"
    exit 0
fi

# Find all ADR files (numbered format)
ADR_FILES=$(find "$ADR_DIR" -type f -name "[0-9][0-9][0-9][0-9]-*.md" -o -name "ADR-[0-9][0-9][0-9]-*.md" 2>/dev/null || true)

if [ -z "$ADR_FILES" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"No ADR files found (checked by COMP-009)\"}"
    exit 0
fi

# Quality evaluation criteria
TOTAL_ADRS=0
QUALITY_SCORE=0
ISSUES=()

# Function to check if ADR has required sections
check_adr_sections() {
    local file="$1"
    local score=0
    local max_score=7

    # Required sections based on ADR-RFC-STANDARDS.md
    local has_status=false
    local has_context=false
    local has_decision=false
    local has_alternatives=false
    local has_consequences=false
    local alternatives_count=0
    local has_status_date=false

    # Read file content
    local content=$(cat "$file")

    # Check for Status - either as section or inline metadata
    if echo "$content" | grep -qi "^## Status" || echo "$content" | grep -qi "^\*\*Status:\*\*"; then
        has_status=true
        score=$((score + 1))
    fi

    # Check if status includes date information (anywhere in file)
    if echo "$content" | grep -qi "date.*:.*[0-9]\{4\}"; then
        has_status_date=true
        score=$((score + 1))
    fi

    # Check for Context section
    if echo "$content" | grep -qi "^## Context"; then
        has_context=true
        score=$((score + 1))
    fi

    # Check for Decision section
    if echo "$content" | grep -qi "^## Decision"; then
        has_decision=true
        score=$((score + 1))
    fi

    # Check for Alternatives section (various phrasings)
    if echo "$content" | grep -qi "^## Alternatives"; then
        has_alternatives=true

        # Count alternatives (looking for ### headers under Alternatives section)
        # Use awk to find section and count subsections
        alternatives_count=$(echo "$content" | awk '
            /^## Alternatives/ { in_section=1; next }
            /^## / && in_section { in_section=0 }
            in_section && /^### / { count++ }
            END { print count+0 }
        ')

        # Score point if 3 or more alternatives documented
        if [ "$alternatives_count" -ge 3 ]; then
            score=$((score + 1))
        fi
    fi

    # Check for Consequences section
    if echo "$content" | grep -qi "^## Consequences"; then
        has_consequences=true
        score=$((score + 1))
    fi

    # Return score as percentage
    echo "$score:$max_score:$alternatives_count:$has_status_date"
}

# Evaluate each ADR
while IFS= read -r adr_file; do
    if [ -f "$adr_file" ]; then
        TOTAL_ADRS=$((TOTAL_ADRS + 1))

        # Get quality score for this ADR
        result=$(check_adr_sections "$adr_file")
        score=$(echo "$result" | cut -d: -f1)
        max=$(echo "$result" | cut -d: -f2)
        alt_count=$(echo "$result" | cut -d: -f3)
        has_date=$(echo "$result" | cut -d: -f4)

        QUALITY_SCORE=$((QUALITY_SCORE + score))

        # Track issues for ADRs scoring at or below 4/7 (57%)
        if [ "$score" -le 4 ]; then
            filename=$(basename "$adr_file")
            ISSUES+=("$filename: $score/$max sections")
        fi
    fi
done <<< "$ADR_FILES"

# Calculate average quality percentage
if [ "$TOTAL_ADRS" -gt 0 ]; then
    MAX_POSSIBLE=$((TOTAL_ADRS * 7))
    QUALITY_PERCENT=$((QUALITY_SCORE * 100 / MAX_POSSIBLE))

    # Determine pass/fail
    # Pass threshold: 60% (approximately 4 of 7 required sections)
    if [ "$QUALITY_PERCENT" -ge 60 ]; then
        if [ ${#ISSUES[@]} -eq 0 ]; then
            echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"$TOTAL_ADRS ADR(s) with $QUALITY_PERCENT% avg quality (all meet standards)\"}"
        else
            # Build comma-delimited list
            issue_list=""
            for issue in "${ISSUES[@]}"; do
                if [ -z "$issue_list" ]; then
                    issue_list="$issue"
                else
                    issue_list="$issue_list, $issue"
                fi
            done
            echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"$TOTAL_ADRS ADR(s) with $QUALITY_PERCENT% avg quality (${#ISSUES[@]} below standard: $issue_list)\"}"
        fi
        exit 0
    else
        # Build comma-delimited list
        issue_list=""
        for issue in "${ISSUES[@]}"; do
            if [ -z "$issue_list" ]; then
                issue_list="$issue"
            else
                issue_list="$issue_list, $issue"
            fi
        done
        echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"$TOTAL_ADRS ADR(s) with only $QUALITY_PERCENT% avg quality. ADRs below standard: $issue_list\"}"
        exit 1
    fi
else
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"No ADR files to evaluate\"}"
    exit 0
fi
