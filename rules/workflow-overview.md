---
description: Social science research plugin — 5-step workflow, quality thresholds, and project structure. Loaded in every session.
paths: ["**/*"]
---

# Social Science Research Plugin

## The 5-Step Research Workflow

| Step | What You're Doing | Skill(s) | Output Location |
|------|------------------|----------|-----------------|
| 0. Setup | Configure field, journals, datasets, R colors | `/research-setup` | `references/domain-profile.md`, `CLAUDE.md` |
| 1. Idea | Interview → ideation → unified spec | `/new-project` | `quality_reports/project_spec_*.md` |
| 2a. Lit Review | Parallel journal + repo + citation search | `/lit-review` → `/validate-bib` | `quality_reports/lit_review_*.md` |
| 2b. Data | Find + assess datasets for the RQ | `/data-finder` | `quality_reports/data_exploration_*.md` |
| 3. Analysis | Run R or Python analysis | `/data-analysis` → `/review-r` | `output/tables/`, `output/figures/` |
| 4. Write | Draft, review, and revise the paper | `/write-paper` → `/review-paper` → `/revise-paper` | `manuscripts/[name]-draft.tex` |
| 5. Quality Gate | Verify analysis ↔ paper match | `/quality-gate` → `/proofread` | `quality_reports/quality_gate_*.md` |

---

## Core Principles

- **Plan first** — enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** — run code and confirm outputs at the end of every task
- **Quality gates** — nothing ships below 80/100

---

## Quality Gates

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

**Key deductions:** script failure −100, claimed result absent from output −50, domain bug −30, missing citation −15, broken table/figure ref −5.

---

## Recommended Project Structure

```
your-project/
├── CLAUDE.md                    # Project context (name, author, current state)
├── Bibliography_base.bib        # Centralized bibliography (protected)
├── data/                        # Raw data files
├── scripts/
│   ├── R/                       # R analysis scripts
│   └── python/                  # Python analysis scripts
├── notebooks/                   # Jupyter notebooks
├── output/
│   ├── tables/                  # Generated .tex and .html tables
│   └── figures/                 # Generated .pdf and .png figures
├── manuscripts/                 # Paper drafts (.tex, .qmd)
├── quality_reports/             # Plans, session logs, review reports
│   ├── plans/
│   ├── session_logs/
│   ├── specs/
│   └── merges/
└── references/
    ├── domain-profile.md        # Field, journals, datasets, key researchers
    └── papers/                  # Reference papers and PDFs
```
