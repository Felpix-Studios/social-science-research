---
description: Social science research plugin — the 5-step workflow pipeline from setup through quality gate. Loaded in every session.
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
