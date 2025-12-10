# Contributing to labrats-compliance

Thank you for your interest in contributing to labrats-compliance! This document provides guidelines for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Compliance Check Development](#compliance-check-development)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and collaborative environment. Be considerate, constructive, and professional in all interactions.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/labrats-compliance.git
   cd labrats-compliance
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/labrats-work/labrats-compliance.git
   ```

## How to Contribute

### Areas for Contribution

- **New compliance checks**: Add checks for additional best practices
- **Improve existing checks**: Enhance accuracy and reliability
- **Documentation**: Improve docs, examples, and guides
- **Bug fixes**: Fix issues in existing checks or workflows
- **Workflow improvements**: Enhance automation and reporting

## Development Workflow

### Creating a Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name
```

### Making Changes

1. Make your changes following the project structure
2. Test your changes locally
3. Commit with descriptive messages
4. Push to your fork

## Compliance Check Development

### Adding a New Check

1. **Create the check script** in `compliance/checks/`:
   ```bash
   touch compliance/checks/check-your-feature.sh
   chmod +x compliance/checks/check-your-feature.sh
   ```

2. **Follow the standard format**:
   ```bash
   #!/bin/bash
   # COMP-XXX: Check description

   set -e

   REPO_PATH="${1:-.}"
   CHECK_ID="COMP-XXX"
   CHECK_NAME="Your Check Name"

   # Your check logic here

   # Output JSON result
   echo "{\"check_id\":\"$CHECK_ID\",\"name\":\"$CHECK_NAME\",\"status\":\"pass|fail|skip\",\"message\":\"Descriptive message\"}"
   exit 0  # or exit 1 for failure
   ```

3. **Update documentation**:
   - Add check to `COMPLIANCE.md`
   - Update `API_PERMISSIONS.md` if GitHub API is used
   - Add example to `docs/` if needed

4. **Assign priority** in `compliance/check-priorities.json`:
   ```json
   {
     "COMP-XXX": {
       "name": "Your Feature Check",
       "priority": "HIGH",
       "points": 5
     }
   }
   ```

### Check Guidelines

- **Return proper exit codes**: 0 for pass, 1 for fail
- **Output valid JSON**: Always return structured JSON
- **Handle errors gracefully**: Don't crash on missing files/permissions
- **Be fast**: Checks should complete in < 5 seconds
- **Document API usage**: Note any GitHub API endpoints used

## Testing

### Test Locally

```bash
# Test a single check
./compliance/checks/check-your-feature.sh /path/to/test/repo

# Run all checks manually
for check in compliance/checks/check-*.sh; do
  bash "$check" /path/to/test/repo
done

# Test via workflow
gh workflow run compliance-check.yml --repo YOUR_ORG/github-repo-standards
```

### Test Cases

Ensure your check handles:
- ✅ Passing cases (when requirements are met)
- ❌ Failing cases (when requirements are not met)
- ⏭️ Skip cases (when check doesn't apply)
- 🔒 Permission errors (when files are unreadable)
- 🚫 Missing directories/files
- 🌐 API errors (if using GitHub API)

## Pull Request Process

### Before Submitting

- [ ] Code follows existing patterns and style
- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Commit messages are clear and descriptive
- [ ] Branch is up to date with main

### Submitting

1. **Push your changes**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub:
   - Use a descriptive title
   - Reference any related issues
   - Describe what changed and why
   - Include test results if applicable

3. **PR Description Template**:
   ```markdown
   ## Summary
   Brief description of changes

   ## Changes
   - Bullet list of changes

   ## Testing
   How you tested the changes

   ## Related Issues
   Fixes #123
   ```

### Review Process

- Maintainers will review your PR
- Address any feedback or requested changes
- Once approved, your PR will be merged
- Your contribution will be credited

## Reporting Issues

### Bug Reports

When reporting bugs, include:
- **Description**: What is the bug?
- **Steps to reproduce**: How can we see the bug?
- **Expected behavior**: What should happen?
- **Actual behavior**: What actually happens?
- **Environment**: OS, versions, etc.
- **Logs/output**: Any relevant output

### Feature Requests

When requesting features, include:
- **Use case**: Why is this needed?
- **Proposed solution**: How might it work?
- **Alternatives**: Other options considered?
- **Impact**: Who benefits from this?

## Questions?

- **GitHub Issues**: For bugs and features
- **Discussions**: For questions and ideas
- **Documentation**: Check CLAUDE.md and docs/

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Thank You!

Your contributions make this project better for everyone. Thank you for taking the time to contribute!
