#!/bin/bash
# COMP-020: ARC Runner Usage Check
# Priority: MEDIUM
# Validates that workflows use ARC runners (k8s-local-tomp736) instead of GitHub-hosted or legacy runners

set -euo pipefail

REPO_PATH="${1:-.}"
CHECK_ID="COMP-020"
CHECK_NAME="ARC Runner Usage"

# ARC runner scale set name
ARC_RUNNER="k8s-local-tomp736"

# GitHub-hosted runner patterns
GITHUB_HOSTED_RUNNERS=(
    "ubuntu-latest"
    "ubuntu-22.04"
    "ubuntu-20.04"
    "windows-latest"
    "windows-2022"
    "windows-2019"
    "macos-latest"
    "macos-13"
    "macos-12"
)

# Legacy runner patterns
LEGACY_RUNNERS=(
    "self-hosted"
    "tomp736"
    "local"
)

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

# Track violations
VIOLATIONS=()
TOTAL_JOBS=0
ARC_JOBS=0

# Search for runs-on patterns in workflow files
while IFS= read -r workflow_file; do
    WORKFLOW_NAME=$(basename "$workflow_file")

    # Extract runs-on lines (handling both string and array formats)
    # This is a simple grep-based approach that works for most cases
    while IFS= read -r line; do
        # Skip comments
        if echo "$line" | grep -q "^[[:space:]]*#"; then
            continue
        fi

        # Check if line contains runs-on
        if echo "$line" | grep -q "runs-on:"; then
            TOTAL_JOBS=$((TOTAL_JOBS + 1))

            # Check for ARC runner
            if echo "$line" | grep -q "$ARC_RUNNER"; then
                ARC_JOBS=$((ARC_JOBS + 1))
                continue
            fi

            # Check for GitHub-hosted runners
            FOUND_VIOLATION=0
            for runner in "${GITHUB_HOSTED_RUNNERS[@]}"; do
                if echo "$line" | grep -qi "$runner"; then
                    VIOLATIONS+=("$WORKFLOW_NAME uses GitHub-hosted runner: $runner")
                    FOUND_VIOLATION=1
                    break
                fi
            done

            # Check for legacy runners (only if not already found a violation)
            if [ $FOUND_VIOLATION -eq 0 ]; then
                # Legacy runners typically use array format: [self-hosted, tomp736]
                for runner in "${LEGACY_RUNNERS[@]}"; do
                    if echo "$line" | grep -qi "$runner"; then
                        VIOLATIONS+=("$WORKFLOW_NAME uses legacy runner label: $runner")
                        FOUND_VIOLATION=1
                        break
                    fi
                done
            fi
        fi
    done < "$workflow_file"
done < <(find "$WORKFLOW_DIR" -name "*.yml" -o -name "*.yaml")

# Generate result
if [ $TOTAL_JOBS -eq 0 ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"skip\",\"message\":\"No jobs with runs-on found in $WORKFLOW_COUNT workflow(s)\"}"
    exit 2
fi

if [ ${#VIOLATIONS[@]} -eq 0 ]; then
    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass\",\"message\":\"All $TOTAL_JOBS job(s) use ARC runner ($ARC_RUNNER)\"}"
    exit 0
else
    # Build comma-delimited list
    VIOLATIONS_STR=""
    for item in "${VIOLATIONS[@]}"; do
        if [ -z "$VIOLATIONS_STR" ]; then
            VIOLATIONS_STR="$item"
        else
            VIOLATIONS_STR="$VIOLATIONS_STR; $item"
        fi
    done

    echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"fail\",\"message\":\"${#VIOLATIONS[@]} of $TOTAL_JOBS job(s) not using ARC runner: $VIOLATIONS_STR\"}"
    exit 1
fi
