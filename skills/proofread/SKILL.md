---
name: proofread
description: "Proofread papers and manuscripts. Checks grammar, typos, layout, consistency, writing quality. Produces report without editing files. Use when finding surface-level errors, not substantive academic critique."
when_to_use: "proofread, check typos, grammar check, look for errors, proofread all, polish this, check my writing, any mistakes, proofread before sending, clean-up pass"
argument-hint: "[filename, 'all', or path to manuscript]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task", "AskUserQuestion"]
---

# Proofread Academic Writing

Run the mandatory proofreading protocol on papers or manuscripts. Produces a report of all issues WITHOUT editing any source files.

## Steps

1. **Identify files to review:**
   - If `$ARGUMENTS` is a specific filename: review that file only
   - If `$ARGUMENTS` is `all`: review all files in `manuscripts/` and `Quarto/` (if it exists)
   - If `$ARGUMENTS` is a file in `manuscripts/`: treat as manuscript (not slides)
   - If `$ARGUMENTS` is empty or ambiguous and multiple files exist, use AskUserQuestion:
     - header: "Files"
     - question: "Which files should I proofread?"
     - multiSelect: true
     - options: list up to 4 found files (label: filename, description: directory and file type). User can select multiple or choose "Other" to specify a path.

2. **For each file, launch the `proofreader` agent** (via Task). It checks grammar, typos, layout issues, consistency, and academic quality — the agent definition owns the full category specifications, so do not restate them here.

3. **Produce a detailed report** for each file listing every finding with:
   - Location (line number or section heading)
   - Current text (what's wrong)
   - Proposed fix (what it should be)
   - Category and severity

4. **Save each report** to `quality_reports/`:
   - For `.tex` slide files: `quality_reports/FILENAME_report.md`
   - For `.qmd` slide files: `quality_reports/FILENAME_qmd_report.md`
   - For manuscript files: `quality_reports/FILENAME_proofread.md`

5. **IMPORTANT: Do NOT edit any source files.**
   Read `${CLAUDE_PLUGIN_ROOT}/skills/proofread/references/proofreading-protocol.md`. Only produce the report. Fixes are applied separately after user review.

6. **Present summary** to the user:
   - Total issues found per file
   - Breakdown by category
   - Most critical issues highlighted
