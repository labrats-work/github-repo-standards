#!/bin/bash
# Automated setup script for github-repo-standards compliance framework
# This script guides you through creating GitHub Apps and configuring the compliance scanner

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║  GitHub Repo Standards - Compliance Framework Setup      ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v gh &> /dev/null; then
    echo -e "${RED}✗ GitHub CLI (gh) is not installed${NC}"
    echo "Install from: https://cli.github.com/"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗ jq is not installed${NC}"
    echo "Install with: sudo apt-get install jq  # or brew install jq"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo -e "${RED}✗ GitHub CLI is not authenticated${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}\n"

# Get organization name
read -p "Enter your GitHub organization name: " GITHUB_ORG
if [ -z "$GITHUB_ORG" ]; then
    echo -e "${RED}Organization name is required${NC}"
    exit 1
fi

# Get repository name
read -p "Enter the repository name [github-repo-standards]: " REPO_NAME
REPO_NAME=${REPO_NAME:-github-repo-standards}

# Confirm repository exists
if ! gh api "repos/$GITHUB_ORG/$REPO_NAME" &>/dev/null; then
    echo -e "${RED}✗ Repository $GITHUB_ORG/$REPO_NAME not found${NC}"
    echo "Please create the repository first or check the name"
    exit 1
fi

echo -e "${GREEN}✓ Repository $GITHUB_ORG/$REPO_NAME found${NC}\n"

# Check if using the github-app-tools repository
APP_TOOLS_PATH="../github-app-tools"
if [ ! -d "$APP_TOOLS_PATH" ]; then
    echo -e "${YELLOW}⚠ github-app-tools not found at $APP_TOOLS_PATH${NC}"
    echo "For easier app creation, clone github-app-tools alongside this repo:"
    echo "  git clone https://github.com/labrats-work/github-app-tools.git"
    echo ""
    USE_MANUAL_SETUP=true
else
    USE_MANUAL_SETUP=false
fi

# Step 1: Create GitHub Apps
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 1: Create GitHub Apps${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo "We need to create 2 GitHub Apps:"
echo "  1. Scanner Bot - Scans repositories and creates issues"
echo "  2. Automation App - Commits reports and manages PRs"
echo ""

if [ "$USE_MANUAL_SETUP" = true ]; then
    echo -e "${YELLOW}Manual Setup Required${NC}"
    echo "Please create the apps manually following docs/setup.md"
    echo "Then run this script again to configure secrets."
    echo ""
    read -p "Have you already created the apps? (y/n): " APPS_CREATED
    if [ "$APPS_CREATED" != "y" ]; then
        echo "Please create the apps first, then re-run this script"
        exit 0
    fi
else
    # Create manifests
    MANIFEST_DIR="./.setup-temp"
    mkdir -p "$MANIFEST_DIR"

    # Create scanner bot manifest
    cat > "$MANIFEST_DIR/manifest-scanner.json" <<EOF
{
  "name": "${GITHUB_ORG}-repo-standards-bot",
  "url": "https://github.com/${GITHUB_ORG}/${REPO_NAME}",
  "description": "Automated compliance checking for ${GITHUB_ORG} repositories. Scans repos, runs checks, generates reports, and creates issues for critical failures.",
  "hook_attributes": {
    "url": "https://example.com/webhook"
  },
  "redirect_url": "https://github.com/${GITHUB_ORG}/${REPO_NAME}",
  "public": false,
  "default_permissions": {
    "administration": "read",
    "contents": "read",
    "issues": "write",
    "metadata": "read"
  },
  "default_events": []
}
EOF

    # Create automation app manifest
    cat > "$MANIFEST_DIR/manifest-automation.json" <<EOF
{
  "name": "${GITHUB_ORG}-repo-standards-automation",
  "url": "https://github.com/${GITHUB_ORG}/${REPO_NAME}",
  "description": "Manages compliance reports and PRs in the ${REPO_NAME} repository.",
  "hook_attributes": {
    "url": "https://example.com/webhook"
  },
  "redirect_url": "https://github.com/${GITHUB_ORG}/${REPO_NAME}",
  "public": false,
  "default_permissions": {
    "contents": "write",
    "pull_requests": "write",
    "metadata": "read"
  },
  "default_events": []
}
EOF

    echo -e "${YELLOW}Creating Scanner Bot app...${NC}"
    echo "1. The browser will open for you to create the app"
    echo "2. After creation, copy the 'code' from the redirect URL"
    echo ""
    read -p "Press Enter to continue..."

    cd "$APP_TOOLS_PATH"
    ./create-app.sh "../${REPO_NAME}/${MANIFEST_DIR}/manifest-scanner.json" "$GITHUB_ORG"

    # Save credentials
    SCANNER_APP_ID=$(cat github-app-credentials.txt | grep "App ID:" | awk '{print $3}')
    mv github-app-private-key.pem "../${REPO_NAME}/${MANIFEST_DIR}/scanner-app-key.pem"
    mv github-app-credentials.txt "../${REPO_NAME}/${MANIFEST_DIR}/scanner-app-credentials.txt"

    echo -e "\n${YELLOW}Creating Automation app...${NC}"
    echo "1. The browser will open for you to create the app"
    echo "2. After creation, copy the 'code' from the redirect URL"
    echo ""
    read -p "Press Enter to continue..."

    ./create-app.sh "../${REPO_NAME}/${MANIFEST_DIR}/manifest-automation.json" "$GITHUB_ORG"

    # Save credentials
    AUTOMATION_APP_ID=$(cat github-app-credentials.txt | grep "App ID:" | awk '{print $3}')
    mv github-app-private-key.pem "../${REPO_NAME}/${MANIFEST_DIR}/automation-app-key.pem"
    mv github-app-credentials.txt "../${REPO_NAME}/${MANIFEST_DIR}/automation-app-credentials.txt"

    cd - > /dev/null

    echo -e "${GREEN}✓ GitHub Apps created${NC}\n"
fi

# Get App IDs and keys if manual setup
if [ "$USE_MANUAL_SETUP" = true ] || [ -z "$SCANNER_APP_ID" ]; then
    read -p "Enter Scanner Bot App ID: " SCANNER_APP_ID
    read -p "Enter path to Scanner Bot private key (.pem file): " SCANNER_KEY_PATH
    read -p "Enter Automation App ID: " AUTOMATION_APP_ID
    read -p "Enter path to Automation App private key (.pem file): " AUTOMATION_KEY_PATH
else
    SCANNER_KEY_PATH="${MANIFEST_DIR}/scanner-app-key.pem"
    AUTOMATION_KEY_PATH="${MANIFEST_DIR}/automation-app-key.pem"
fi

# Step 2: Install Apps
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 2: Install GitHub Apps${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo "Install the apps on your repositories:"
echo ""
echo "1. Scanner Bot:"
echo "   - Install on: All repositories (or selected repos you want to scan)"
echo "   - URL: https://github.com/settings/apps/${GITHUB_ORG}-repo-standards-bot/installations/new"
echo ""
echo "2. Automation App:"
echo "   - Install on: ONLY ${REPO_NAME}"
echo "   - URL: https://github.com/settings/apps/${GITHUB_ORG}-repo-standards-automation/installations/new"
echo ""
read -p "Press Enter after you've installed both apps..."

# Step 3: Configure Secrets
echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 3: Configure GitHub Secrets${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Setting GitHub Secrets...${NC}"

# Set secrets
echo "$SCANNER_APP_ID" | gh secret set REPO_STANDARDS_APP_ID -R "$GITHUB_ORG/$REPO_NAME"
gh secret set REPO_STANDARDS_APP_PRIVATE_KEY -R "$GITHUB_ORG/$REPO_NAME" < "$SCANNER_KEY_PATH"
echo "$AUTOMATION_APP_ID" | gh secret set INTERNAL_AUTOMATION_APP_ID -R "$GITHUB_ORG/$REPO_NAME"
gh secret set INTERNAL_AUTOMATION_APP_PRIVATE_KEY -R "$GITHUB_ORG/$REPO_NAME" < "$AUTOMATION_KEY_PATH"

echo -e "${GREEN}✓ Secrets configured${NC}\n"

# Step 4: Configure Variables
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 4: Configure Repository Variables${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Set STANDARDS_REPO_NAME if not default
if [ "$REPO_NAME" != "github-repo-standards" ]; then
    echo -e "${YELLOW}Setting STANDARDS_REPO_NAME=${REPO_NAME}${NC}"
    gh variable set STANDARDS_REPO_NAME --body "$REPO_NAME" --repo "$GITHUB_ORG/$REPO_NAME"
    echo -e "${GREEN}✓ STANDARDS_REPO_NAME configured${NC}\n"
else
    echo "Using default repository name, no variable needed\n"
fi

# Step 5: Fix Repository Settings
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 5: Configure Repository for Compliance${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Applying compliance fixes to ${REPO_NAME}...${NC}"

# Enable merge methods
echo "→ Enabling squash merge..."
GITHUB_ORG="$GITHUB_ORG" ./compliance/scripts/fix-comp-017-repo-settings.sh "$REPO_NAME"

# Enable branch protection
echo "→ Enabling branch protection..."
gh api -X PUT "repos/$GITHUB_ORG/$REPO_NAME/branches/main/protection" \
  --input - <<'EOF' > /dev/null 2>&1 || echo "Note: Branch protection may already be configured"
{
  "required_status_checks": null,
  "enforce_admins": null,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": false,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": false,
  "lock_branch": false,
  "allow_fork_syncing": false
}
EOF

echo -e "${GREEN}✓ Repository configured${NC}\n"

# Step 6: Trigger Workflow
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 6: Test Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

read -p "Trigger a test compliance check now? (y/n): " RUN_TEST
if [ "$RUN_TEST" = "y" ]; then
    echo -e "${YELLOW}Triggering compliance check workflow...${NC}"
    gh workflow run compliance-check.yml --repo "$GITHUB_ORG/$REPO_NAME"
    sleep 3

    RUN_ID=$(gh run list --repo "$GITHUB_ORG/$REPO_NAME" --limit 1 --json databaseId --jq '.[0].databaseId')
    echo "Workflow started: https://github.com/$GITHUB_ORG/$REPO_NAME/actions/runs/$RUN_ID"
    echo ""
    echo "Watch the run with:"
    echo "  gh run watch $RUN_ID --repo $GITHUB_ORG/$REPO_NAME"
fi

# Cleanup
if [ -d "$MANIFEST_DIR" ]; then
    echo -e "\n${YELLOW}Cleaning up temporary files...${NC}"
    rm -rf "$MANIFEST_DIR"
fi

# Summary
echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete! 🎉                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}\n"

echo "Next steps:"
echo "  1. Review the workflow run at:"
echo "     https://github.com/$GITHUB_ORG/$REPO_NAME/actions"
echo ""
echo "  2. Check for compliance issues created in your repositories"
echo ""
echo "  3. Review generated reports in reports/"
echo ""
echo "  4. See docs/setup.md for advanced configuration"
echo ""

echo -e "${YELLOW}Important:${NC} Delete the private key files securely:"
if [ "$USE_MANUAL_SETUP" != true ]; then
    echo "  - Scanner key at: $SCANNER_KEY_PATH"
    echo "  - Automation key at: $AUTOMATION_KEY_PATH"
fi
