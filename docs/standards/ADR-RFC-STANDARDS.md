# Architecture Decision Records (ADR) and RFC Standards

## Purpose

This document establishes standards for writing Architecture Decision Records (ADRs) and Request for Comments (RFCs) across all repositories in the labrats-work organization. These standards ensure consistency, quality, and long-term value of architectural documentation.

## What is an ADR?

An **Architecture Decision Record (ADR)** is a document that captures the reasoning behind significant architectural decisions made during a project's lifecycle. It provides transparency in the decision-making process and creates a historical record that helps current and future team members understand the evolution of the system architecture.

### When to Write an ADR

Write an ADR for:
- **Strategic technical choices**: Framework selection, architectural patterns, infrastructure decisions
- **Significant design decisions**: Database schema changes, API design, security model
- **Cross-cutting concerns**: Logging, monitoring, authentication approaches
- **Technology adoption**: New tools, libraries, or platforms
- **Process changes**: Development workflow, deployment strategy, testing approach

Do NOT write an ADR for:
- Daily operational decisions
- Minor implementation details
- Personal preferences without architectural impact
- Routine bug fixes or refactoring

## ADR Format and Structure

### Required Sections

Every ADR must include these sections:

#### 1. Title
- **Format**: `ADR-XXX: [Descriptive Title]`
- **Numbering**: Use zero-padded sequential numbers (001, 002, 003)
- **Title**: Clear, concise description of the decision (not the problem)

**Examples:**
- ✅ `ADR-001: Use PostgreSQL for Primary Database`
- ✅ `ADR-012: Implement Event-Driven Architecture with Kafka`
- ❌ `ADR-005: Database` (too vague)
- ❌ `ADR-007: How to Handle Events` (question format)

#### 2. Status
Indicate the current state of the decision:
- **Proposed**: Under consideration, not yet implemented
- **Accepted**: Approved and active
- **Deprecated**: No longer recommended but still in use
- **Superseded**: Replaced by another ADR (reference the new ADR)
- **Rejected**: Considered but not adopted

**Format:**
```markdown
## Status

Accepted

**Date Accepted**: 2025-12-01
**Last Updated**: 2025-12-01
**Supersedes**: ADR-003 (if applicable)
```

#### 3. Context

Describe the situation that led to this decision:
- **Problem statement**: What challenge or requirement prompted this decision?
- **Business context**: Project goals, constraints, timeline considerations
- **Technical context**: Current architecture, existing systems, technical constraints
- **Stakeholders**: Who is affected by this decision?
- **Assumptions**: What assumptions are being made?

**Key principles:**
- Define the core challenge with situational background
- Include team discussions and perspectives
- Document constraints (time, budget, skills, regulations)
- Explain the "why" behind needing to make a decision

**Example:**
```markdown
## Context

Our meal planning application currently scrapes recipe data from multiple Polish websites.
We need to decide on a web scraping technology stack that can:
- Handle dynamic pagination across different sites
- Respect rate limits and robots.txt
- Track progress for long-running scrapes (450+ recipes)
- Run in GitHub Actions for automation

Constraints:
- No budget for paid scraping services
- Must run in free GitHub Actions tier
- Team has Python and Node.js experience
```

#### 4. Decision

State the architectural decision clearly and explicitly:
- **What**: Precisely what was decided
- **How**: High-level approach to implementation
- **Why**: Rationale for this specific choice
- **Scope**: What this decision covers and what it doesn't

**Key principles:**
- Maintain singular focus per entry (one decision per ADR)
- Be explicit and specific
- State the decision as a declarative statement
- Include key technical details without over-specifying implementation

**Example:**
```markdown
## Decision

We will use Python with BeautifulSoup4 for web scraping, with the following structure:

- **Base scraper class** providing common functionality (progress tracking, JSON output, error handling)
- **Individual scrapers** for each website inheriting from base class
- **Progress tracking** using JSON state files to enable resumable scraping
- **GitHub Actions workflow** for automated execution

Key technologies:
- Python 3.x
- BeautifulSoup4 for HTML parsing
- Requests library for HTTP calls
- JSON for data storage and state management

This decision applies to all recipe and ingredient scraping in the project.
```

#### 5. Alternatives Considered

Document the other options that were evaluated:
- **Minimum**: List 3-5 realistic alternatives
- **For each alternative**: Describe the approach, pros, cons, and why it wasn't chosen
- **Tradeoff analysis**: Explicitly compare alternatives against decision criteria

**Key principles:**
- Show that multiple options were evaluated
- Demonstrate thorough analysis
- Explain tradeoffs honestly
- Include why the chosen solution is better for this specific context

**Example:**
```markdown
## Alternatives Considered

### 1. Node.js with Puppeteer
- **Approach**: Headless browser automation
- **Pros**: Handles JavaScript rendering, can interact with dynamic content
- **Cons**: Higher resource usage (300MB+ per browser instance), slower execution (2-3x slower), more complex setup in CI/CD
- **Why not chosen**: Polish recipe sites use server-side rendering; JavaScript execution not needed

### 2. Scrapy Framework
- **Approach**: Python-based scraping framework with built-in features
- **Pros**: Built-in rate limiting, middleware, pipelines, extensive documentation
- **Cons**: Steeper learning curve, overkill for simple scraping, more complex project structure
- **Why not chosen**: Too much complexity for our use case; BeautifulSoup sufficient

### 3. Dedicated Scraping Service (ScrapingBee, Apify)
- **Approach**: Cloud-based scraping service
- **Pros**: Handles anti-bot measures, no maintenance, scalable
- **Cons**: Monthly cost ($50-200/mo), less control, privacy concerns with data
- **Why not chosen**: Budget constraint; don't need anti-bot features for target sites

### 4. Ruby with Nokogiri
- **Approach**: Ruby HTML parsing library
- **Pros**: Fast parsing, good documentation
- **Cons**: Less popular for scraping, smaller ecosystem, team lacks Ruby experience
- **Why not chosen**: Team expertise in Python; no compelling advantage
```

#### 6. Consequences

Describe the outcomes of this decision:

**Positive Consequences:**
- Expected benefits
- Problems solved
- New capabilities enabled

**Negative Consequences:**
- Known limitations
- Technical debt introduced
- Increased complexity

**Risks and Mitigation:**
- Potential issues and how to address them

**Key principles:**
- Be honest about tradeoffs
- Include both positive and negative impacts
- Consider short-term and long-term effects
- Document anticipated technical debt

**Example:**
```markdown
## Consequences

### Positive
- **Mature ecosystem**: BeautifulSoup4 is well-documented with extensive examples
- **Easy to maintain**: Python's readability makes scrapers easy to understand and modify
- **GitHub Actions support**: Python runs natively in GitHub Actions without special setup
- **Flexible parsing**: BeautifulSoup handles various HTML structures gracefully
- **Progress tracking**: Simple JSON files enable resumable scraping
- **No browser overhead**: Lightweight execution compared to headless browsers

### Negative
- **Limited JavaScript support**: Cannot handle client-side rendering without Selenium/Puppeteer
- **Manual rate limiting**: Must implement rate limiting ourselves (not built into BeautifulSoup)
- **Maintenance burden**: Website changes require scraper updates
- **Blocking risk**: Some websites may block Python user agents

### Risks and Mitigation
- **Risk**: Target websites change HTML structure
  - **Mitigation**: Implement automated scraping tests; monitor for failures
- **Risk**: IP blocking from aggressive scraping
  - **Mitigation**: Implement delays between requests; respect robots.txt
- **Risk**: JavaScript rendering becomes necessary
  - **Mitigation**: Can add Selenium later if needed; most Polish recipe sites use SSR
```

#### 7. Implementation Notes (Optional but Recommended)

Include practical implementation details:
- Code patterns or examples
- Configuration recommendations
- Migration steps (if replacing existing approach)
- Timeline or phases
- Success criteria

**Example:**
```markdown
## Implementation Notes

Each scraper follows this pattern:

```python
class RecipeScraper(BaseScraper):
    def scrape_index(self, page):
        # Scrape recipe URLs from listing page
        pass

    def scrape_detail(self, url):
        # Scrape full recipe from detail page
        pass
```

The base class provides:
- Progress tracking (resume from last page)
- JSON output formatting
- Error handling and logging
- Deduplication by URL

Implementation timeline:
1. Week 1: Base scraper class
2. Week 2: Ania Gotuje scraper
3. Week 3: Centrum Respo scraper
4. Week 4: GitHub Actions integration
```

#### 8. Related Decisions (Optional but Recommended)

Link to related ADRs:
- **Depends on**: ADRs that must be in place first
- **Related to**: ADRs addressing similar concerns
- **Supersedes**: Previous ADR being replaced
- **Superseded by**: Newer ADR (if deprecated)

**Example:**
```markdown
## Related Decisions

- **Depends on**: ADR-001 (Data Storage Strategy) - Scrapers output to JSON format
- **Related to**: ADR-004 (Rate Limiting Strategy) - How to avoid IP blocking
- **Supersedes**: None (initial decision)
```

#### 9. References (Optional but Recommended)

Include supporting materials:
- Documentation links
- Articles or blog posts
- Internal discussions (issue numbers, PR links)
- Relevant code repositories
- Standards or compliance requirements

**Example:**
```markdown
## References

- BeautifulSoup4 Documentation: https://www.crummy.com/software/BeautifulSoup/bs4/doc/
- GitHub Issue #42: Initial scraping approach discussion
- robots.txt standard: https://www.robotstxt.org/
- Comparison article: "Web Scraping in 2024" (saved in artifacts/)
```

### Optional Sections

Consider adding these sections when relevant:

#### Decision Criteria
Explicit factors used to evaluate alternatives:
```markdown
## Decision Criteria

Weighted criteria (1-5 scale):
- Cost: 5 (must be free or low-cost)
- Maintainability: 4 (team must be able to debug)
- Performance: 3 (good enough for daily scraping)
- Flexibility: 3 (can adapt to different sites)
```

#### Follow-up Items
Actions needed after implementation:
```markdown
## Follow-up Items

- [ ] Monitor scraping success rate for 2 weeks
- [ ] Document CSS selector patterns for each site
- [ ] Create runbook for handling scraper failures
- [ ] Set up alerting for failed scraping runs
```

#### Revision History
For long-lived ADRs that evolve:
```markdown
## Revision History

- 2025-12-01: Initial version
- 2025-12-15: Added Selenium integration note after discovering JS rendering
- 2026-01-10: Marked as Superseded by ADR-025 (migration to Puppeteer)
```

## ADR Scoring Rubric

Use this rubric to evaluate ADR quality:

| Criteria | Weight | Excellent (5) | Good (3) | Poor (1) |
|----------|--------|---------------|----------|----------|
| **Structure** | 2x | All required sections, well-organized | Most sections present | Missing key sections |
| **Context** | 3x | Comprehensive problem statement with constraints | Problem stated clearly | Vague or missing context |
| **Decision** | 3x | Clear, specific, actionable | Understandable but could be clearer | Unclear or ambiguous |
| **Alternatives** | 3x | 5+ alternatives with detailed pros/cons | 3-4 alternatives with basic analysis | 0-2 alternatives or minimal detail |
| **Consequences** | 3x | Honest positive/negative/risks with mitigation | Basic consequences listed | Missing or incomplete |
| **Clarity** | 2x | Easy to understand, well-written | Understandable with effort | Confusing or poorly written |
| **Completeness** | 2x | All sections thorough, no gaps | Adequate coverage | Incomplete information |

**Scoring formula:**
```
Total Score = (Structure × 2) + (Context × 3) + (Decision × 3) +
              (Alternatives × 3) + (Consequences × 3) +
              (Clarity × 2) + (Completeness × 2)

Maximum Possible: 90 points
```

**Rating bands:**
- **90-75 points**: Excellent - Exemplary ADR, suitable as template
- **74-60 points**: Good - Solid ADR, minor improvements possible
- **59-45 points**: Adequate - Functional but needs enhancement
- **44-30 points**: Poor - Missing critical elements, needs rework
- **29-0 points**: Inadequate - Does not meet ADR standards

## Best Practices

### 1. Define the Core Challenge with Situational Background
- Start by clearly identifying the specific problem or requirement
- Include business context, not just technical details
- Document the "why now" - what triggered this decision

### 2. Maintain Singular Focus Per Entry
- One decision per ADR (don't combine multiple choices)
- If decisions are tightly coupled, reference them but keep separate ADRs
- Split complex decisions into multiple ADRs if needed

### 3. Standardize with Flexible Templates
- Use the template provided in this document
- Adapt sections as needed for your specific context
- Maintain consistency within a repository

### 4. Include Timestamps and Version Information
- Date when decision was proposed
- Date when decision was accepted
- Last updated date
- System version affected (if applicable)

### 5. Establish Clear Decision Status Indicators
- Always include current status
- Update status when circumstances change
- When superseding, explain why in the new ADR

### 6. Document Thoroughly Before Implementation
- Write ADR during the decision process, not after
- Use ADR as a tool for thinking through options
- Share draft ADRs for review before finalizing

### 7. Store ADRs with Your Codebase
- Keep in version control (Git)
- Standard location: `docs/adr/` or `docs/architecture/`
- Version alongside the code they describe

### 8. Review and Update Regularly
- Review ADRs during major refactoring
- Update status when decisions change
- Archive outdated ADRs (don't delete)

## Naming and Organization

### File Naming Convention

**Standard format:**
```
ADR-XXX-descriptive-title.md
```

**Examples:**
- `ADR-001-use-postgresql.md`
- `ADR-012-event-driven-architecture.md`
- `ADR-025-migrate-to-kubernetes.md`

**Rules:**
- Use zero-padded numbers (001, not 1)
- Use lowercase with hyphens
- Keep titles concise but descriptive
- Use `.md` extension (Markdown)

### Directory Structure

**Standard location:**
```
repository/
├── docs/
│   └── adr/
│       ├── INDEX.md              # Index of all ADRs
│       ├── 0000-adr-template.md  # Template file
│       ├── ADR-001-first-decision.md
│       ├── ADR-002-second-decision.md
│       └── ADR-003-third-decision.md
```

**INDEX.md format:**
```markdown
# Architecture Decision Records

## Active Decisions

- [ADR-001: Use PostgreSQL for Primary Database](ADR-001-use-postgresql.md) - Accepted 2025-01-15
- [ADR-002: Implement Event-Driven Architecture](ADR-002-event-driven-architecture.md) - Accepted 2025-02-01

## Deprecated Decisions

- [ADR-003: Use MongoDB for Logging](ADR-003-mongodb-logging.md) - Deprecated 2025-06-01, superseded by ADR-012

## Proposed Decisions

- [ADR-013: Migrate to Kubernetes](ADR-013-kubernetes-migration.md) - Proposed 2025-11-01

## Template

- [ADR Template](0000-adr-template.md)
```

### Numbering Strategy

**Sequential numbering:**
- Start at 001 (not 000, which is reserved for template)
- Increment by 1 for each new ADR
- Never reuse numbers (even for superseded ADRs)
- Gaps in sequence are acceptable (don't renumber)

**Status tracking:**
- Use INDEX.md to show current status
- Group by status in index (Active, Deprecated, Proposed)
- Keep all ADRs in repository (don't delete deprecated ones)

## Request for Comments (RFC)

### When to Use RFC vs ADR

**Use RFC when:**
- Decision is still being debated (not yet made)
- You want broad input from stakeholders
- Multiple teams or repositories affected
- Decision has significant organizational impact

**Use ADR when:**
- Decision has been made (even if not yet implemented)
- Decision is specific to one repository/system
- You're documenting the rationale after the fact

### RFC Format

RFCs follow a similar structure to ADRs but with these differences:

**Additional sections:**
- **Open Questions**: Areas needing more research or discussion
- **Stakeholder Feedback**: Summary of input received
- **Timeline**: Proposed review and decision timeline

**Different status values:**
- **Draft**: Initial proposal, seeking feedback
- **In Review**: Actively being discussed
- **Final Comment**: Last call for feedback before decision
- **Accepted**: Approved, becomes an ADR
- **Withdrawn**: Proposal withdrawn by author

**RFC template structure:**
```markdown
# RFC-XXX: [Title]

## Status
Draft / In Review / Final Comment / Accepted / Withdrawn

**Review Period**: 2025-12-01 to 2025-12-15

## Summary
One paragraph explaining the proposal.

## Motivation
Why are we doing this? What problems does it solve?

## Proposal
Detailed explanation of the proposed solution.

## Alternatives Considered
What other approaches were considered?

## Open Questions
- What aspects need more research?
- What feedback are we seeking?

## Stakeholder Feedback
Summary of input received during review.

## Timeline
- Draft: 2025-12-01
- Review: 2025-12-01 to 2025-12-15
- Decision: 2025-12-15
```

## Common Pitfalls to Avoid

### ❌ Writing ADRs After Implementation
- **Problem**: Missing crucial context and alternatives that were considered
- **Solution**: Write ADR during decision process, before coding

### ❌ Combining Multiple Decisions
- **Problem**: Difficult to reference specific decisions, confusing evolution
- **Solution**: One decision per ADR, link related ADRs

### ❌ Insufficient Alternative Analysis
- **Problem**: Looks like decision was made without due diligence
- **Solution**: Document at least 3-5 realistic alternatives with honest pros/cons

### ❌ Vague or Missing Context
- **Problem**: Future readers can't understand why decision was made
- **Solution**: Include business context, constraints, and assumptions

### ❌ Ignoring Negative Consequences
- **Problem**: Creates unrealistic expectations, hides technical debt
- **Solution**: Be honest about tradeoffs and limitations

### ❌ Too Much Implementation Detail
- **Problem**: ADR becomes outdated as implementation evolves
- **Solution**: Focus on architectural direction, not code specifics

### ❌ No Status Updates
- **Problem**: Outdated decisions treated as current
- **Solution**: Review and update status regularly

### ❌ Deleting Deprecated ADRs
- **Problem**: Loss of institutional knowledge
- **Solution**: Keep all ADRs, update status to Deprecated or Superseded

## Tools and Automation

### Recommended Tools

**ADR creation and management:**
- **adr-tools**: CLI for creating and managing ADRs in Markdown
  ```bash
  adr new "Use PostgreSQL for Primary Database"
  ```
- **Log4brains**: Static site generator for browsable ADR documentation
- **VS Code extensions**: ADR templates and snippets

**Quality checking:**
- **Markdown linters**: Enforce consistent formatting
- **Compliance checks**: Verify required sections present (can integrate with repo-standards compliance framework)

### Template File

Create `docs/adr/0000-adr-template.md` in each repository:

```markdown
# ADR-XXX: [Title]

## Status

Proposed

**Date Proposed**: YYYY-MM-DD
**Date Accepted**: (pending)
**Last Updated**: YYYY-MM-DD

## Context

[Describe the problem, situation, and context that led to this decision]

## Decision

[State the architectural decision clearly and explicitly]

## Alternatives Considered

### 1. [Alternative Name]
- **Approach**:
- **Pros**:
- **Cons**:
- **Why not chosen**:

### 2. [Alternative Name]
- **Approach**:
- **Pros**:
- **Cons**:
- **Why not chosen**:

## Consequences

### Positive
-

### Negative
-

### Risks and Mitigation
- **Risk**:
  - **Mitigation**:

## Related Decisions

- **Depends on**:
- **Related to**:
- **Supersedes**:

## References

-
```

## Compliance Integration

### ADR Quality Check (COMP-009)

The repo-standards compliance framework checks for ADR presence. To meet the standard:

**Minimum requirements:**
- `docs/adr/` directory exists
- `INDEX.md` file present
- At least one ADR file (ADR-001 or higher)

**Quality indicators:**
- ADRs follow standard naming convention
- All ADRs include required sections
- INDEX.md is up to date
- Status indicators are current

### Future Compliance Enhancements

Potential additions to compliance checking:
- Verify ADR structure (required sections present)
- Check for outdated ADRs (no updates in 2+ years)
- Validate INDEX.md matches actual ADR files
- Flag ADRs missing alternatives or consequences

## Examples from labrats-work Repositories

### Excellent Examples

**my-health ADR-001 (Health Provider Selection)**
- Extremely detailed context (full medical history)
- 8+ alternatives considered with thorough analysis
- Comprehensive consequences (positive, negative, risks)
- Implementation tracking and follow-up items
- Related ADRs cross-referenced

**my-diet ADR-012 (Ingredient Matching False Positives)**
- Evidence-based decision (analyzed 12,855 ingredients)
- Clear problem statement with metrics
- Multiple solutions tested with results
- Implementation notes with code examples
- References to GitHub issues

**my-homelab ADR-001 (VLAN Segmentation)**
- Professional network architecture documentation
- Clear security rationale
- Detailed VLAN schema
- Implementation guidance

### Areas for Improvement

**repo-standards ADRs (001-003)**
- Good technical decisions but brief
- Could expand consequences sections
- Limited alternatives (2-3 vs ideal 5+)
- Missing implementation notes

**my-resume ADR-001 duplicate**
- Two ADRs cover same topic (Zettelkasten)
- Should be consolidated or differentiated

## Summary

High-quality ADRs are:
1. **Focused**: One decision per document
2. **Contextual**: Explain why decision was needed
3. **Thorough**: Consider multiple alternatives
4. **Honest**: Document negative consequences and tradeoffs
5. **Timely**: Written during decision process, not after
6. **Maintained**: Updated as circumstances change
7. **Accessible**: Stored with code, easy to find

Following these standards ensures that architectural decisions are well-documented, reviewable, and valuable for years to come.

## References

- Michael Nygard's ADR template (2016): https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- ADR GitHub organization: https://adr.github.io/
- "8 Best Practices for Creating Architecture Decision Records" (TechTarget, 2025)
- Log4brains documentation: https://github.com/thomvaill/log4brains
- adr-tools: https://github.com/npryce/adr-tools

## Last Updated

2025-12-01
