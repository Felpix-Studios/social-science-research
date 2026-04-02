---
name: quality-gate
description: Verify that every quantitative claim in the paper is traceable to an analysis output file, and that no important output was omitted. Make sure to use this skill whenever the user wants to check that the paper and analysis are consistent before submission. Triggers include: "run the quality gate", "check the paper matches the analysis", "verify consistency", "does the paper match my results", "check my numbers", "are my tables right", "quality check before submission", "verify my claims", "make sure everything is consistent", "double-check the paper against my output files", or any pre-submission integrity check between paper text and computed results.
argument-hint: "[paper file path, or leave blank to auto-detect]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Quality Gate: Paper ↔ Analysis Consistency

Cross-check every numerical claim in the paper against analysis output files. Reports only — never edits.

**Input:** `$ARGUMENTS` — path to the paper draft, or leave blank to auto-detect.

---

## Step 1: Locate the Paper Draft

If `$ARGUMENTS` is provided, use that path. Otherwise glob for:
- `paper/**/*.tex`
- `paper/**/*.qmd`
- `manuscripts/**/*.tex`

If multiple drafts found, list them and ask the user to confirm which to check.

---

## Step 2: Extract Numerical Claims

Read the full manuscript and extract every quantitative claim:

- **Coefficients and standard errors** — e.g., "The effect is 0.23 (SE = 0.04)"
- **Sample sizes** — e.g., "N = 4,521 observations"
- **Percentages and proportions** — e.g., "42% of firms..."
- **Means, medians, ranges** — e.g., "average income of $45,000"
- **Table and figure references** — e.g., "Table 2 shows...", "as seen in Figure 1"
- **p-values and significance statements** — e.g., "statistically significant at the 1% level"

Record location (section, paragraph, line number if available) for each claim.

---

## Step 3: Inventory Output Files

Glob for all output files:
- `output/tables/**/*.tex` — regression and summary tables
- `output/tables/**/*.html` — HTML versions
- `output/figures/**/*.pdf`, `output/figures/**/*.png` — figures
- `output/**/*.rds`, `output/**/*.pkl`, `output/**/*.parquet`, `output/**/*.csv` — saved objects

Build an inventory with file paths and sizes.

---

## Step 4: Verify Each Claim

For each numerical claim extracted in Step 2:

1. **Table references:** Find the referenced table file. Read it and confirm the specific number appears.
2. **Figure references:** Verify the referenced figure file exists at the expected path.
3. **Inline numbers:** Search output files (`.tex` tables, `.csv`, `.html`) for the exact value or a value within tolerance.
4. **Sample size claims:** Check table notes or summary stats files for the stated N.

Label each claim:
- **MATCHED** — found in an output file
- **UNVERIFIED** — could not locate in any output file (needs manual check)
- **MISSING FILE** — referenced file does not exist

---

## Step 5: Reverse Check — Unreferenced Outputs

Scan `output/tables/` and `output/figures/` for files NOT referenced in the paper:

- A table or figure in `output/` that is never cited in the manuscript may represent omitted results
- Flag each unreferenced file: the user should either reference it in the paper or explain why it was excluded

---

## Step 6: Check Citations

Grep the manuscript for all citation keys (`\cite{key}`, `\citet{key}`, `\citep{key}`, `@key`).
Grep the bibliography file (`Bibliography_base.bib` or any `.bib` in the project root) for each key.
Flag any key used in the paper but missing from the bibliography as CRITICAL.

---

## Step 7: Save Report

Save to `quality_reports/quality_gate_[YYYY-MM-DD]_[paper-name].md`:

```markdown
# Quality Gate Report: [Paper Name]
**Date:** [YYYY-MM-DD]
**Paper:** [file path]

## Verdict: PASS / CONDITIONAL PASS / FAIL

PASS = all claims matched, no missing citations, no unexplained unreferenced outputs
CONDITIONAL PASS = minor unverified claims or informational unreferenced outputs
FAIL = unverified critical claims or missing citations

---

## Claim Verification

| Claim | Location | Found in Output? | Source File | Status |
|-------|----------|-----------------|-------------|--------|
| β = 0.23 (SE = 0.04) | Section 4, para 2 | Yes | output/tables/main_regs.tex | MATCHED |
| N = 4,521 | Table 2 note | Yes | output/tables/main_regs.tex | MATCHED |
| 42% of firms | Intro, para 1 | No | — | UNVERIFIED |

---

## Unreferenced Outputs

Files in output/ not referenced in the paper:

| File | Size | Recommended Action |
|------|------|-------------------|
| output/tables/robustness_het.tex | 4.2 KB | Reference in Section 7 or explain exclusion |

---

## Missing Citations

| Key | Used At | Status |
|-----|---------|--------|
| SmithJones2021 | Section 3, para 1 | NOT IN BIBLIOGRAPHY — CRITICAL |

---

## Summary

- Claims verified: N / M total
- Claims unverified: K (see table above)
- Unreferenced outputs: J
- Missing citations: L

## Recommended Actions (Priority Order)
1. [BLOCKING] ...
2. [RECOMMENDED] ...
```

---

## Key Rules

- **Report only — never edit.** All fixes are the user's responsibility after reviewing the report.
- **Tolerance:** For inline numbers, a claim is MATCHED if the value appears in any output file within reasonable display rounding (±0.005 for 2-decimal numbers).
- **False positives are OK.** Flag uncertainties as UNVERIFIED rather than guessing MATCHED.
- **Missing files are always BLOCKING** — a figure reference pointing to a non-existent file is a FAIL.
