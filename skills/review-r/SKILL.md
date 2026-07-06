---
name: review-r
description: "R code review on existing scripts. Checks quality, reproducibility, domain correctness, professional standards. Produces report without editing files. Use when evaluating or auditing existing R code, not writing new analysis."
when_to_use: "review R script, check R code, replication-ready, audit R file, follow conventions, will this reproduce, check analysis script, code review, review-r, quality feedback on .R file"
argument-hint: "[filename, 'all', or analysis name pattern]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task", "AskUserQuestion"]
---

# Review R Scripts

Run the comprehensive R code review protocol.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.R` filename: review that file only
   - If `$ARGUMENTS` is a name pattern (e.g., `model_name`): glob for matching `.R` files. If multiple matches, use AskUserQuestion:
     - header: "Scripts"
     - question: "Multiple R scripts match that pattern. Which should I review?"
     - multiSelect: true
     - options: list up to 4 matched files (label: filename, description: path and last modified). User can select multiple.
   - If `$ARGUMENTS` is `all`: review all R scripts in `scripts/R/` and `Figures/*/`
   - If `$ARGUMENTS` is empty, glob for all `.R` files. If multiple found, use AskUserQuestion as above.

2. **For each script, launch the `r-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `${CLAUDE_PLUGIN_ROOT}/rules/r-code-conventions.md` for current standards
   - Save report to `quality_reports/[script_name]_r_review.md`

3. **After all reviews complete**, present a summary:
   - Total issues found per script
   - Breakdown by severity (Critical / High / Medium / Low)
   - Top 3 most critical issues

4. **IMPORTANT: Do NOT edit any R source files.**
   Only produce reports. Fixes are applied after user review.
