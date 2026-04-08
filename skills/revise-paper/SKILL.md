---
name: revise-paper
description: Apply revisions from a review report to a manuscript. Reads the review, presents a prioritized revision plan, and applies fixes section-by-section with user approval. Make sure to use this skill whenever the user wants to systematically address issues from a review — not to draft a new paper or run a fresh review. Triggers include: "revise the paper", "apply the review", "fix the issues from the review", "address referee comments", "apply revisions", "work through the review report", "fix what the reviewer found", "address the major concerns", or any request to systematically apply fixes from an existing review report.
argument-hint: "[review report path, or leave blank to auto-detect]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task", "AskUserQuestion"]
---

# Revise Paper from Review Report

Systematically apply revisions from a review report to a manuscript. Follows Prose Track rules — never auto-edits without approval.

**Input:** `$ARGUMENTS` — path to a review report, or leave blank to auto-detect.

---

## Step 1: Locate the Review Report

If `$ARGUMENTS` is provided, use that path. Otherwise glob for:
- `quality_reports/paper_review_*.md`
- `quality_reports/*_substance_review.md`
- `quality_reports/*_proofread.md`

If multiple reports found, use AskUserQuestion:
- header: "Review Report"
- question: "Multiple review reports found. Which should I use for revisions?"
- options: list found reports (label: filename, description: date and type). User can select one.

---

## Step 2: Locate the Manuscript

Read the review report and extract the manuscript path from its `File:` field.

If the file doesn't exist at that path, glob for:
- `manuscripts/**/*.tex`
- `manuscripts/**/*.qmd`

If multiple manuscripts found, use AskUserQuestion to let the user pick.

Read the full manuscript.

---

## Step 3: Parse the Review Report

Extract all actionable items and classify them:

| Priority | Source Section | Action |
|----------|--------------|--------|
| **Critical** | Major Concerns with "CRITICAL" or "BLOCKING" | Must fix before any submission |
| **Major** | Major Concerns, Referee Objections | Should fix — a reviewer would flag these |
| **Minor** | Minor Concerns, Specific Comments | Polish — fix if time allows |

For each item, extract:
- The issue description
- The suggested fix (if provided)
- The location in the manuscript (section, line, table)

---

## Step 4: Present Revision Plan (WAIT FOR APPROVAL)

Present the revision plan grouped by priority:

```
## Revision Plan

### Critical (N items) — must fix
1. [MC1: Title] — Section X — [brief description of fix]
2. ...

### Major (N items) — should fix
1. [MC2: Title] — Section Y — [brief description of fix]
2. ...

### Minor (N items) — polish
1. [mc1: Title] — Section Z — [brief description of fix]
2. ...

Total: N revisions across M sections.
```

**Do NOT start editing until the user approves the plan or selects which items to address.**

---

## Step 5: Apply Approved Revisions

Work through approved items in this order:
1. Critical items first
2. Major items second
3. Minor items last

For each revision:
1. Show the current text and the proposed replacement
2. Apply the edit using the Edit tool
3. Move to the next item

**Prose Track rules apply:** If the user deferred any items, skip them and note them in the summary.

---

## Step 6: Post-Revision Review

After all approved revisions are applied, dispatch the `proofreader` agent via Task to catch any issues introduced by the edits:

```
Task prompt: "Review the manuscript at [path] for grammar, typos, layout issues,
and consistency. Focus on sections that were recently revised: [list changed sections].
Return your report — the calling skill handles saving."
```

Present any new issues found by the proofreader.

---

## Step 7: Save Revision Summary

Save to `quality_reports/revision_summary_[paper-name].md`:

```markdown
# Revision Summary: [Paper Name]

**Date:** [YYYY-MM-DD]
**Review report used:** [path]
**Manuscript:** [path]

## Revisions Applied

| # | Priority | Issue | Section | Status |
|---|----------|-------|---------|--------|
| 1 | Critical | [title] | Section X | APPLIED |
| 2 | Major | [title] | Section Y | APPLIED |
| 3 | Minor | [title] | Section Z | DEFERRED — user chose to skip |

## Issues Deferred

- [Item]: [reason deferred]

## Post-Revision Proofreader Findings

- [Any new issues introduced by edits]

## Recommended Next Steps

- **`/quality-gate`** — verify claim consistency after edits
- **`/validate-bib`** — check citations if references were added or changed
- **`/review-paper`** — run a fresh review to confirm issues are resolved
```

---

## Key Rules

- **Prose Track only.** Never apply edits without user approval.
- **Work from the review report.** Don't invent new issues — address what the review found.
- **Preserve author voice.** When rewriting prose, maintain the manuscript's existing style and tone.
- **Track everything.** Every revision applied or deferred must appear in the summary.
