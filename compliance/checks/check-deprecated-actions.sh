#!/bin/bash
# COMP-015: Deprecated Actions Check
# Priority: HIGH
# Validates that workflows don't use deprecated GitHub Actions

set -euo pipefail

REPO_PATH="${1:-.}"
CHECK_ID="COMP-015"
CHECK_NAME="Deprecated Actions"

# Path to deprecated actions list
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPRECATED_LIST="$SCRIPT_DIR/../deprecated-actions.txt"

# Check if deprecated actions list exists
if [ ! -f "$DEPRECATED_LIST" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Deprecated actions list not found: $DEPRECATED_LIST\"}"
    exit 1
fi

# Check if .github/workflows directory exists
WORKFLOW_DIR="$REPO_PATH/.github/workflows"
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"No workflows directory found\"}"
    exit 2
fi

# Check if there are any workflow files
WORKFLOW_COUNT=$(find "$WORKFLOW_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null | wc -l)
if [ "$WORKFLOW_COUNT" -eq 0 ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"No workflow files found\"}"
    exit 2
fi

# Load deprecated actions (filter out comments and empty lines)
DEPRECATED_ACTIONS=$(grep -v "^#" "$DEPRECATED_LIST" | grep -v "^$" || true)

if [ -z "$DEPRECATED_ACTIONS" ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"No deprecated actions defined\"}"
    exit 0
fi

# Search for deprecated actions in workflow files
FOUND_DEPRECATED=()
WORKFLOW_FILES=()

while IFS= read -r deprecated_action; do
    # Search all workflow files for this deprecated action
    while IFS= read -r workflow_file; do
        if grep -q "uses:.*$deprecated_action" "$workflow_file" 2>/dev/null; then
            WORKFLOW_NAME=$(basename "$workflow_file")
            FOUND_DEPRECATED+=("$deprecated_action in $WORKFLOW_NAME")
        fi
    done < <(find "$WORKFLOW_DIR" -name "*.yml" -o -name "*.yaml")
done <<< "$DEPRECATED_ACTIONS"

# Generate result
if [ ${#FOUND_DEPRECATED[@]} -eq 0 ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"No deprecated actions found in $WORKFLOW_COUNT workflow(s)\"}"
    exit 0
else
    # Build comma-delimited list
    DEPRECATED_STR=""
    for item in "${FOUND_DEPRECATED[@]}"; do
        if [ -z "$DEPRECATED_STR" ]; then
            DEPRECATED_STR="$item"
        else
            DEPRECATED_STR="$DEPRECATED_STR, $item"
        fi
    done

    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"Found ${#FOUND_DEPRECATED[@]} deprecated action(s): $DEPRECATED_STR\"}"
    exit 1
fi
