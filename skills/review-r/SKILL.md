---
name: review-r
description: Run the R code review protocol on R scripts. Checks code quality, reproducibility, domain correctness, and professional standards. Produces a report without editing files. Make sure to use this skill whenever the user wants their existing R code evaluated or audited — not when they want new analysis written. Triggers include: "review my R script", "check my R code", "is my code replication-ready", "audit this R file", "does this code follow conventions", "will this reproduce", "check my analysis script", "code review", "review-r", or when the user has an existing .R file and wants quality feedback rather than new code.
argument-hint: "[filename, 'all', or analysis name pattern]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review R Scripts

Run the comprehensive R code review protocol.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.R` filename: review that file only
   - If `$ARGUMENTS` is a name pattern (e.g., `model_name`): review all R scripts matching that pattern
   - If `$ARGUMENTS` is `all`: review all R scripts in `scripts/R/` and `Figures/*/`

2. **For each script, launch the `r-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `rules/r-code-conventions.md` for current standards
   - Save report to `quality_reports/[script_name]_r_review.md`

3. **After all reviews complete**, present a summary:
   - Total issues found per script
   - Breakdown by severity (Critical / High / Medium / Low)
   - Top 3 most critical issues

4. **IMPORTANT: Do NOT edit any R source files.**
   Only produce reports. Fixes are applied after user review.
