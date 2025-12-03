# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) documenting significant decisions made about the my-repos compliance framework.

## What is an ADR?

An Architecture Decision Record (ADR) captures an important architectural decision made along with its context and consequences. For this repository, we use ADRs to document:

- Compliance framework design decisions
- Automation architecture choices
- Standard definitions and rationale
- Tool selections and integrations

## ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0000](0000-adr-template.md) | ADR Template | Template | - |
| [0001](0001-modular-compliance-checks.md) | Modular Compliance Checks | Accepted | 2025-11-29 |
| [0002](0002-github-app-for-cross-repo-access.md) | GitHub App for Cross-Repo Access | Accepted | 2025-11-29 |
| [0003](0003-template-file-for-issue-bodies.md) | Template File for Issue Bodies | Accepted | 2025-11-29 |

## Creating a New ADR

1. Copy `0000-adr-template.md` to a new file with the next number: `000X-short-title.md`
2. Fill in all sections
3. Update this INDEX.md with the new ADR
4. Commit with message: `Add ADR-000X: [title]`

## ADR Statuses

- **Proposed** - Decision proposed but not yet finalized
- **Accepted** - Decision has been made and is being implemented
- **Rejected** - Proposal was considered but rejected
- **Deprecated** - Decision no longer applies
- **Superseded** - Replaced by a newer ADR

## References

- [ADR GitHub Organization](https://adr.github.io/)
- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)

## Last Updated

2025-11-29
