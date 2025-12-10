# ADR-0001: Modular Compliance Checks

**Date:** 2025-11-29
**Status:** Accepted
**Deciders:** labrats-work

## Context

We needed a way to check compliance across multiple repositories with different standards and priorities. The system needed to be:

- **Extensible** - Easy to add new checks
- **Maintainable** - Each check independent and testable
- **Flexible** - Different formats (JSON, markdown)
- **Weighted** - Critical checks more important than optional ones

## Decision

Implement compliance checks as **modular bash scripts** in `compliance/checks/`:

1. Each check is a separate script (e.g., `check-readme-exists.sh`)
2. Each script outputs JSON with standard format
3. Exit code 0 = pass, 1 = fail
4. GitHub Actions workflow discovers and runs all checks
5. Check priorities defined in `check-priorities.json`
6. Weighted scoring: CRITICAL=10, HIGH=5, MEDIUM=2, LOW=1

## Consequences

### Positive

- **Easy to add checks** - Just create a new script in `checks/`
- **Independent testing** - Each check can be tested in isolation
- **Clear ownership** - One script, one responsibility
- **Simple debugging** - If a check fails, only look at that script
- **Language agnostic** - Can use bash, Python, etc. as needed
- **Discoverable** - Orchestrator auto-discovers new checks

### Negative

- **Bash limitations** - Not as expressive as Python for complex logic
- **JSON formatting** - Manual JSON construction in bash
- **No shared utilities** - Each script is independent

### Neutral

- **File proliferation** - Many small files in `checks/`
- **Naming convention** - Must follow naming pattern for discovery

## References

- [compliance/README.md](../../compliance/README.md) - Framework documentation
- [COMPLIANCE.md](../../COMPLIANCE.md) - Standards definition
- Issue #1 - Original standardization plan
