## 📊 Compliance Check Pipeline Metrics

**Workflow Run:** [#{{RUN_NUMBER}}]({{RUN_URL}})
**Triggered:** {{TRIGGER_TYPE}}
**Completed:** {{COMPLETION_TIME}}

---

### ⏱️ Execution Time

- **Total Duration:** {{TOTAL_DURATION}}
- **Checkout & Setup:** {{SETUP_DURATION}}
- **Compliance Checks:** {{CHECKS_DURATION}}
- **Report Generation:** {{REPORT_DURATION}}
- **Issue Management:** {{ISSUE_DURATION}}

---

### 📈 Repository Summary

**Total Repositories Checked:** {{TOTAL_REPOS}}

{{REPO_SUMMARY}}

---

### 📊 Check Statistics

**Overall pass/fail rates for each compliance check across all repositories:**

{{CHECK_STATISTICS}}

---

### ✅ Success Metrics

- **Passing Repositories (≥50%):** {{PASSING_COUNT}} ({{PASSING_PERCENT}}%)
- **Repositories Needing Work (<50%):** {{FAILING_COUNT}} ({{FAILING_PERCENT}}%)
- **Issues Created:** {{ISSUES_CREATED}}
- **Issues Updated:** {{ISSUES_UPDATED}}
- **Issues Closed:** {{ISSUES_CLOSED}}

---

### 🎯 Compliance Tiers

{{TIER_BREAKDOWN}}

---

### 📋 Top Issues Across Repositories

{{TOP_FAILING_CHECKS}}

---

### 🔄 Trend Analysis

{{TREND_DATA}}

---

### 📎 Resources

- **Full Report (Markdown):** [compliance-report-{{DATE}}.md](https://github.com/tomp736/my-repos/blob/main/reports/compliance-report-{{DATE}}.md)
- **Full Report (JSON):** [compliance-report-{{DATE}}.json](https://github.com/tomp736/my-repos/blob/main/reports/compliance-report-{{DATE}}.json)
- **Workflow Run:** {{RUN_URL}}
- **Compliance Standards:** [COMPLIANCE.md](https://github.com/tomp736/my-repos/blob/main/COMPLIANCE.md)

---

*This issue was automatically created by the [My-Repos Compliance Checker](https://github.com/tomp736/my-repos).*
*Generated: {{DATE}} {{TIME}}*
