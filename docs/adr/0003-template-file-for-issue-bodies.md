# ADR-0003: Template File for Issue Bodies

**Date:** 2025-11-29
**Status:** Accepted
**Deciders:** tomp736

## Context

When creating compliance issues in target repositories, we needed to:
- Generate issue bodies with dynamic content
- Support multiline content (failed checks list)
- Avoid YAML parsing errors in GitHub Actions
- Make templates version-controlled and maintainable

**Initial approach:** Used bash heredoc in workflow YAML
**Problem:** YAML parser errors with special characters (**, ---, etc.) and multiline values in sed substitution

## Decision

Use a **template file** approach:

1. Create `.github/ISSUE_TEMPLATE_COMPLIANCE_FAILURE.md`
2. Use `{{PLACEHOLDER}}` syntax for dynamic values
3. Copy template to temp file in workflow
4. Replace simple placeholders with sed
5. Replace multiline placeholders with awk
6. Pass temp file to `gh issue create --body-file`

## Consequences

### Positive

- **Version controlled** - Template is in repo, tracked in git
- **Maintainable** - Easy to update issue format
- **No YAML escaping** - Template file is pure markdown
- **Cleaner workflow** - Less inline script in YAML
- **Testable** - Can preview template locally
- **Reusable** - Same template used for all repos

### Negative

- **Extra file** - Additional file to maintain
- **Two-step replacement** - sed for simple, awk for multiline
- **Temp file management** - Must clean up temp files

### Neutral

- **Placeholder syntax** - Chose `{{VAR}}` over `$VAR` or `%VAR%`
- **File location** - In `.github/` directory

## References

- Template: `.github/ISSUE_TEMPLATE_COMPLIANCE_FAILURE.md`
- Workflow: `.github/workflows/compliance-check.yml`
- Related commits: dc1494f, 9597f23
