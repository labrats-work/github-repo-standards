#!/bin/bash
# Script to fix COMP-002: LICENSE Missing
# Creates MIT LICENSE file for a repository

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Require GITHUB_ORG environment variable
if [ -z "${GITHUB_ORG:-}" ]; then
  echo "Error: GITHUB_ORG environment variable is required"
  echo "Usage: GITHUB_ORG=your-org $0 <repository>"
  exit 1
fi

# Check if repository was provided
if [ $# -ne 1 ]; then
  echo "Error: Exactly one repository name required"
  echo "Usage: GITHUB_ORG=your-org $0 <repository>"
  exit 1
fi

OWNER="$GITHUB_ORG"
REPO="$1"
CLONE_DIR="/tmp/fix-comp-002"
YEAR=$(date +%Y)

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
  echo -e "${RED}Error: GitHub CLI is not authenticated${NC}"
  exit 1
fi

# Check if repo is accessible
if ! gh api "repos/$OWNER/$REPO" &>/dev/null; then
  echo -e "${RED}✗ Repository not accessible: $REPO${NC}"
  exit 1
fi

# Check if repo is archived
archived=$(gh api "repos/$OWNER/$REPO" --jq '.archived' 2>/dev/null || echo "false")
if [ "$archived" = "true" ]; then
  echo -e "${YELLOW}⊙ Repository is archived, skipping${NC}"
  exit 0
fi

# Clean up and create clone directory
rm -rf "$CLONE_DIR"
mkdir -p "$CLONE_DIR"
cd "$CLONE_DIR"

# Clone repository
if ! gh repo clone "$OWNER/$REPO" 2>/dev/null; then
  echo -e "${RED}✗ Failed to clone $REPO${NC}"
  exit 1
fi

cd "$REPO"

# Check if LICENSE already exists
if [ -f "LICENSE" ]; then
  echo -e "${YELLOW}⊙ LICENSE already exists, skipping${NC}"
  cd ../..
  rm -rf "$CLONE_DIR"
  exit 0
fi

# Create MIT LICENSE
cat > LICENSE <<EOF
MIT License

Copyright (c) $YEAR $OWNER

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Commit and push
git add LICENSE
git commit -m "chore: Add MIT LICENSE

Addresses COMP-002 compliance requirement.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

if git push 2>/dev/null; then
  echo -e "${GREEN}✓ Created LICENSE for $REPO${NC}"
  exit_code=0
else
  echo -e "${RED}✗ Failed to push LICENSE for $REPO${NC}"
  exit_code=1
fi

# Clean up
cd ../..
rm -rf "$CLONE_DIR"

exit $exit_code
