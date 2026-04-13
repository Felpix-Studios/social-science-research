---
name: write-paper
description: Draft a full academic paper manuscript from analysis outputs, project spec, and lit review. Make sure to use this skill whenever the user wants to turn completed analysis into a written paper — not to run analysis or review existing writing. Triggers include: "write the paper", "draft the manuscript", "write up the results", "start the paper", "turn my results into a paper", "write the introduction", "draft the empirics section", "I have my results, now write the paper", "help me write this up", "write the abstract", or any request to produce academic prose from existing research outputs.
argument-hint: "[paper title, research question, or 'from spec']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Write Paper Draft

Draft an academic manuscript from existing analysis outputs. Follows propose-first — the outline is always shown for approval before writing begins.

**Input:** `$ARGUMENTS` — a paper title, research question, or `from spec` to read from `quality_reports/specs/`.

---

## Step 1: Orient

Read project context:
- `CLAUDE.md` — project name, author, institution
- `references/domain-profile.md` — field (used to calibrate outline conventions in Step 3)
- Most recent file in `quality_reports/specs/` — research question and identification strategy
- Most recent file in `quality_reports/lit_review_*.md` — related literature (if it exists)
- Most recent file in `quality_reports/research_ideation_*.md` — hypotheses (if it exists)

If no spec exists, ask the user for the core research question before proceeding.

---

## Step 2: Inventory Analysis Outputs

Glob for available outputs:
- `output/tables/**/*.tex` — regression tables
- `output/tables/**/*.html` — HTML table versions
- `output/figures/**/*.pdf`, `output/figures/**/*.png` — figures
- `output/**/*.rds`, `output/**/*.pkl`, `output/**/*.parquet` — saved objects

List what exists. Note any gaps (e.g., "no summary statistics table found").

---

## Step 3: Propose Outline (WAIT FOR APPROVAL)

Draft a paper outline using this standard structure:

```
1. Abstract
2. Introduction
3. Background
4. Data & Methods
5. Results
6. Discussion
7. Appendix
References
```

**The structure is flexible.** Default to the hardcoded outline above unless (a) the user requests a different structure, or (b) the field in `references/domain-profile.md` has strong conventions that warrant deviation (e.g., merging Background into Introduction, splitting Data & Methods into separate Data and Empirical Strategy sections, or reordering sections). If you deviate from the default, state explicitly why and confirm with the user before writing.

**Adapt the writing style** — not the structure, by default — to the field from `references/domain-profile.md`. A political science paper reads differently than an econometrics paper even with the same section headings: econ prose leads with identification and is terse about theory; poli sci prose leads with theoretical framing and treats measurement validity as a first-class concern; sociology leans on theoretical framework prose. Mirror the conventions of the field's top journals when drafting each section.

Present the outline with a one-sentence description of each section's content, linking specific output files to each section (e.g., "Table 2 → Section 5, Results"). **Do NOT start writing until the user approves the outline or requests changes.**

---

## Step 4: Draft Section by Section

Write in this order (minimizes backtracking):

1. **Data & Methods** — describe the dataset and summary statistics (reference `output/tables/summary_stats.tex` if it exists), then the identification or estimation approach from the research spec.
2. **Results** — one paragraph per main finding. Reference each table/figure with `\input{}` or `\includegraphics{}` — do NOT copy table content inline.
3. **Discussion** — interpret the findings, discuss robustness checks, acknowledge limitations, and state implications.
4. **Appendix** — additional robustness tables, derivations, and supplementary figures. Reference output files only.
5. **Background** — synthesize from the lit review document if one exists; position the contribution against prior work.
6. **Introduction** — write after results are known. State the question, preview the findings, and map the paper.
7. **Abstract** — write last: one sentence each for motivation, question, method, finding, and implication.

---

## Step 5: Save the Draft

Save to `manuscripts/[project-name]-draft.tex` (or `.qmd` if the user prefers Quarto).

Create `manuscripts/` directory if it does not exist.

Use `\input{}` for tables and `\includegraphics{}` for figures — reference the actual files in `output/`, do not embed content directly.

---

## Step 6: Structural Smoke Test

Before handing off to review skills, run a quick structural check on the draft to catch drafting-artifact errors that full substance review doesn't focus on. This is **not** a substance review — `/review-paper` handles that. This catches broken references and left-behind placeholders that would embarrass the author if the draft went out as-is.

Do this inline (no agent dispatch). Read the saved draft and check:

1. **Table references resolve.** For every `\input{...}` command in the draft, confirm the referenced file exists in `output/`. Grep the draft for `\input\{`; for each hit, Glob the referenced path. List any misses.

2. **Figure references resolve.** For every `\includegraphics{...}` command, confirm the referenced file exists in `output/figures/`. Same approach: grep, then glob.

3. **No placeholders left behind.** Grep the draft for `TODO`, `FIXME`, `XXX`, `[placeholder]`, `[TK]`, `???`, and square-bracketed all-caps tokens like `[PLACEHOLDER]`. List every hit with its line number.

4. **Required sections present.** Confirm the draft contains an abstract, an introduction, and a conclusion (by section heading or equivalent markup). Flag any missing.

5. **No fabricated numbers.** Grep the draft for numeric patterns in prose (e.g., `\d+\.\d+%`, `\$\d+`, `p\s*<\s*0\.\d+`). For each, note whether a corresponding output file was referenced nearby. This is a heuristic — flag likely orphans for the user to verify, not definitive.

Present the results as a short checklist:

```
## Structural Smoke Test Results

[OK]      Table references: 8/8 resolve
[FAIL]    Figure references: 3/4 resolve — missing output/figures/heterogeneity.pdf
[OK]      No placeholders found
[OK]      Required sections present (abstract, introduction, conclusion)
[WARN]    4 numeric claims in prose may lack nearby output references — see list below
```

Do **not** run a substance review here. If any structural issues are flagged, offer to fix them before handoff. Bibliography checking is deferred to `/validate-bib`; claim-to-output traceability is deferred to `/quality-gate`; substance review is deferred to `/review-paper`.

---

## Step 7: Recommend Next Steps

Inform the user:
- **`/review-paper`** — for a full top-journal-style review of the manuscript
- **`/validate-bib`** — to check all citations are in the bibliography
- **`/quality-gate`** — to verify every claim in the paper is backed by an output file

---

## Key Rules

- **Propose outline first.** Never start writing without outline approval.
- **Reference, don't embed.** Tables and figures go in `output/`; the paper references them by path.
- **No fabrication.** Only write results that exist in output files. If a number isn't in `output/`, flag it rather than guessing.
- **Smoke test, don't substance-review.** Step 6 catches drafting artifacts only — broken refs, placeholders, missing sections. Substance review is `/review-paper`'s job.
