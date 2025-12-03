#!/bin/bash
# Run all compliance checks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECKS_DIR="$SCRIPT_DIR/checks"

# Default values
REPO_PATH=""
FORMAT="json"
ALL_REPOS=false
PARENT_DIR="/home/u0/code/labrats-work"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            ALL_REPOS=true
            shift
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --parent-dir)
            PARENT_DIR="$2"
            shift 2
            ;;
        *)
            REPO_PATH="$1"
            shift
            ;;
    esac
done

# Priority weights
declare -A WEIGHTS
WEIGHTS[CRITICAL]=10
WEIGHTS[HIGH]=5
WEIGHTS[MEDIUM]=2
WEIGHTS[LOW]=1

# Check definitions with priorities
declare -A CHECK_PRIORITIES
CHECK_PRIORITIES[check-readme-exists.sh]="CRITICAL"
CHECK_PRIORITIES[check-license-exists.sh]="CRITICAL"
CHECK_PRIORITIES[check-gitignore-exists.sh]="CRITICAL"
CHECK_PRIORITIES[check-claude-md-exists.sh]="CRITICAL"
CHECK_PRIORITIES[check-readme-structure.sh]="HIGH"
CHECK_PRIORITIES[check-docs-directory.sh]="HIGH"
CHECK_PRIORITIES[check-workflows.sh]="HIGH"
CHECK_PRIORITIES[check-issue-templates.sh]="MEDIUM"
CHECK_PRIORITIES[check-adr-pattern.sh]="MEDIUM"
CHECK_PRIORITIES[check-claude-config.sh]="MEDIUM"
CHECK_PRIORITIES[check-contributing.sh]="LOW"
CHECK_PRIORITIES[check-security.sh]="LOW"
CHECK_PRIORITIES[check-mkdocs.sh]="LOW"

# Function to read disabled checks from .compliance.yml
get_disabled_checks() {
    local repo_path="$1"
    local compliance_file="$repo_path/.compliance.yml"

    if [ -f "$compliance_file" ]; then
        # Extract disabled_checks array from YAML (simple parsing)
        grep -A 100 "^disabled_checks:" "$compliance_file" | \
        grep "^  - " | \
        sed 's/^  - //' | \
        sed 's/ *#.*//' | \
        tr -d '\r'
    fi
}

# Function to check if a check is disabled
is_check_disabled() {
    local check_id="$1"
    local disabled_list="$2"

    echo "$disabled_list" | grep -q "^$check_id$"
}

# Function to run checks on a single repo
run_checks_on_repo() {
    local repo_path="$1"
    local repo_name=$(basename "$repo_path")

    local passed=0
    local failed=0
    local skipped=0
    local total_score=0
    local max_score=0
    local results=()

    # Get list of disabled checks for this repo
    local disabled_checks=$(get_disabled_checks "$repo_path")

    # Run all check scripts
    for check_script in "$CHECKS_DIR"/*.sh; do
        if [ -f "$check_script" ]; then
            local check_name=$(basename "$check_script")
            local priority="${CHECK_PRIORITIES[$check_name]:-MEDIUM}"
            local weight="${WEIGHTS[$priority]}"

            # Extract CHECK_ID from script (assumes format: # COMP-XXX: in script)
            local check_id=$(grep "^# COMP-" "$check_script" | head -1 | sed 's/.*\(COMP-[0-9]*\).*/\1/')

            # Check if this check is disabled
            if [ -n "$check_id" ] && is_check_disabled "$check_id" "$disabled_checks"; then
                skipped=$((skipped + 1))
                # Create a skip result
                local skip_msg="{\"check_id\":\"$check_id\",\"name\":\"Skipped\",\"status\":\"skip\",\"message\":\"Disabled in .compliance.yml\"}"
                results+=("{\"script\":\"$check_name\",\"priority\":\"$priority\",\"result\":$skip_msg}")
                continue
            fi

            max_score=$((max_score + weight))

            # Run check and capture output
            if output=$("$check_script" "$repo_path" 2>&1); then
                passed=$((passed + 1))
                total_score=$((total_score + weight))
                results+=("{\"script\":\"$check_name\",\"priority\":\"$priority\",\"result\":$output}")
            else
                failed=$((failed + 1))
                results+=("{\"script\":\"$check_name\",\"priority\":\"$priority\",\"result\":$output}")
            fi
        fi
    done

    # Calculate compliance percentage
    local compliance_pct=0
    if [ $max_score -gt 0 ]; then
        compliance_pct=$((total_score * 100 / max_score))
    fi

    # Determine tier
    local tier="🔴 Critical Issues"
    if [ $compliance_pct -ge 90 ]; then
        tier="🟢 Excellent"
    elif [ $compliance_pct -ge 75 ]; then
        tier="🟡 Good"
    elif [ $compliance_pct -ge 50 ]; then
        tier="🟠 Needs Improvement"
    fi

    # Output based on format
    if [ "$FORMAT" = "markdown" ]; then
        echo "## $repo_name"
        echo ""
        echo "**Compliance Score:** $compliance_pct% ($total_score/$max_score points) - $tier"
        echo ""
        echo "**Summary:** $passed passed, $failed failed"
        echo ""
        echo "| Check | Priority | Status | Message |"
        echo "|-------|----------|--------|---------|"

        for result in "${results[@]}"; do
            # Parse JSON result
            local script=$(echo "$result" | jq -r '.script')
            local priority=$(echo "$result" | jq -r '.priority')
            local check_result=$(echo "$result" | jq -r '.result')
            local status=$(echo "$check_result" | jq -r '.status')
            local message=$(echo "$check_result" | jq -r '.message')
            local check_name=$(echo "$check_result" | jq -r '.name')

            local status_icon="❌"
            if [ "$status" = "pass" ]; then
                status_icon="✅"
            fi

            echo "| $check_name | $priority | $status_icon | $message |"
        done
        echo ""
    else
        # JSON format
        local results_json=$(printf '%s\n' "${results[@]}" | jq -s '.')
        echo "{\"repository\":\"$repo_name\",\"path\":\"$repo_path\",\"compliance_score\":$compliance_pct,\"tier\":\"$tier\",\"passed\":$passed,\"failed\":$failed,\"total_score\":$total_score,\"max_score\":$max_score,\"checks\":$results_json}"
    fi
}

# Main execution
if [ "$ALL_REPOS" = true ]; then
    # Run on all my-* repos
    if [ "$FORMAT" = "markdown" ]; then
        echo "# Repository Compliance Report"
        echo ""
        echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
    else
        echo "{"
        echo "  \"generated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
        echo "  \"repositories\": ["
    fi

    first=true
    for repo_dir in "$PARENT_DIR"/my-*; do
        if [ -d "$repo_dir" ]; then
            if [ "$FORMAT" = "json" ]; then
                if [ "$first" = false ]; then
                    echo ","
                fi
                first=false
            fi
            run_checks_on_repo "$repo_dir"
        fi
    done

    if [ "$FORMAT" = "json" ]; then
        echo ""
        echo "  ]"
        echo "}"
    fi
else
    # Run on single repo
    if [ -z "$REPO_PATH" ]; then
        echo "Error: Repository path required" >&2
        echo "Usage: $0 [--all] [--format json|markdown] [--parent-dir PATH] [REPO_PATH]" >&2
        exit 1
    fi

    if [ ! -d "$REPO_PATH" ]; then
        echo "Error: Repository path does not exist: $REPO_PATH" >&2
        exit 1
    fi

    run_checks_on_repo "$REPO_PATH"
fi
