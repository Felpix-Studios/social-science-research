# Social Science Research

A Claude Code plugin based on Pedro Sant'Anna's Claude Code workflow designed for producing social science research.

Provides 12 slash commands, 7 specialized agents, 9 auto-loading rules, and 4 hooks that guide you through project setup, literature review, data discovery, statistical analysis, paper drafting, and quality verification.

---

## Table of Contents

- [What This Plugin Does](#what-this-plugin-does)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [The Research Workflow](#the-research-workflow)
- [Skills Reference](#skills-reference)
- [Agents Reference](#agents-reference)
- [Rules Reference](#rules-reference)
- [Hooks Reference](#hooks-reference)
- [Quality Scoring](#quality-scoring)
- [Project Structure](#project-structure)
- [Customization](#customization)
- [How Components Connect](#how-components-connect)
- [Troubleshooting](#troubleshooting)

---

## What This Plugin Does

This plugin turns Claude Code into a research assistant that knows social science methodology. It provides slash commands for every stage of empirical research — formulating research questions, searching the literature, finding datasets, running analysis in R or Python, drafting LaTeX or Quarto manuscripts, and verifying that every claim in your paper traces back to an output file.

Behind the scenes, skills dispatch specialized agents in parallel (e.g., multiple librarian agents searching different journal databases simultaneously), enforce coding standards through auto-loading rules, and run quality gates that score your work on a 0–100 scale before anything ships.

```
Setup → Idea → Lit Review + Data → Analysis → Write → Quality Gate
```

---

## Prerequisites

- **Claude Code** with plugin support
- **R** (>= 4.0) and/or **Python** (>= 3.9) — for `/data-analysis`
- **LaTeX distribution** — for paper compilation (optional; only needed for `/write-paper` with `.tex` output)
- **Ghostscript** — for processing large PDFs in `master_supporting_docs/` (optional)
- **Python 3** — for the compaction hooks (`pre-compact.py`, `post-compact-restore.py`)

---

## Installation

1. **Add the marketplace** in Claude Code:

   ```
   /plugin marketplace add Felpix-Studios/social-science-research
   ```

2. **Install the plugin:**

   ```
   /plugin install social-science-research@felpix-research
   ```

   Or run `/plugin` to open the interactive plugin manager, browse to **felpix-research**, and install from there.

3. **Open any project directory** and start a Claude Code session. On first launch, the `setup-project-dirs.sh` hook automatically:
   - Creates `quality_reports/plans/`, `quality_reports/session_logs/`, `quality_reports/specs/`, and `quality_reports/merges/`
   - Copies starter templates into `templates/` and `references/` (never overwrites your edits)

4. **Run `/research-setup`** to configure your field, institution, journals, datasets, and institutional colors. This writes your domain profile and customizes R figure themes to match your institution's visual identity.

After setup, your project has a `references/domain-profile.md` with your field's journals, datasets, and key researchers — which the literature and data-finding skills will use automatically.

---

## Quick Start

```
/research-setup                          # Configure field, journals, datasets, colors
/new-project effect of minimum wage      # Structured interview → project spec
/lit-review minimum wage employment      # Parallel agents search journals + NBER/SSRN + citations
/validate-bib                            # Check all citations exist in your .bib file
/data-finder from spec                   # Parallel agents find + rank datasets
/data-analysis data/cps_merged.csv       # End-to-end R or Python analysis
/write-paper                             # Draft manuscript from analysis outputs
/quality-gate                            # Verify every claim traces to an output file
```

---

## The Research Workflow

| Step | What You Do | Skill(s) | Output |
|------|-------------|----------|--------|
| 0. Setup | Configure field, journals, datasets, R colors | `/research-setup` | `references/domain-profile.md`, `CLAUDE.md` |
| 1. Idea | Interview → ideation → unified project spec | `/new-project` | `quality_reports/specs/project_spec_*.md` |
| 2a. Literature | Parallel journal + working paper + citation search | `/lit-review` then `/validate-bib` | `quality_reports/lit_review_*.md` |
| 2b. Data | Find and assess datasets for the research question | `/data-finder` | `quality_reports/data_exploration_*.md` |
| 3. Analysis | Run R or Python analysis, review code quality | `/data-analysis` then `/review-r` | `output/tables/`, `output/figures/`, `scripts/` |
| 4. Write | Draft and review the manuscript | `/write-paper` then `/review-paper` | `paper/[name]-draft.tex` |
| 5. Verify | Check analysis-paper consistency, proofread | `/quality-gate` then `/proofread` | `quality_reports/quality_gate_*.md` |

### Step 0: Setup

Run `/research-setup` once per project. It asks grouped questions about your field, institution, target journals, common datasets, key researchers, and institutional colors. Answers are saved to `references/domain-profile.md` (used by literature and data skills) and `rules/r-code-conventions.md` (institutional color palette for R figures).

### Step 1: Idea

Run `/new-project [topic]`. A three-phase structured interview: conversational questioning about your research idea, then Claude generates 3–5 research questions with identification strategies (DiD, RDD, IV, etc.), and finally produces a unified project specification with hypotheses, data requirements, and priority ranking.

### Step 2a: Literature Review

Run `/lit-review [topic]`. Dispatches 3–5 librarian agents in parallel — each searching a different angle (top-5 journals, secondary journals, NBER/SSRN/IZA working papers, backward citations, forward citations via Semantic Scholar). Results are consolidated into a thematic report with 20–40 papers and BibTeX entries. Follow up with `/validate-bib` to check all citations exist in your `.bib` file.

### Step 2b: Data Discovery

Run `/data-finder [topic]`. Dispatches two explorer agents in parallel (institutional/admin data vs. international/novel sources), then an explorer-critic stress-tests each candidate across five dimensions: measurement validity, sample selection, external validity, identification compatibility, and known issues. Produces a ranked list with feasibility grades (A–D).

### Step 3: Analysis

Run `/data-analysis [dataset]`. Autodetects R or Python, then runs through: setup, exploratory data analysis, main analysis, publication-ready output, and save. All scripts follow `rules/r-code-conventions.md` conventions. After writing code, run `/review-r` to get a quality review covering reproducibility, style, domain correctness, and figure standards.

### Step 4: Write

Run `/write-paper`. Drafts a manuscript using your analysis outputs, project spec, and lit review. Sections are drafted in order: data, empirical strategy, results, robustness, literature, introduction, abstract, conclusion. References actual output files via `\input{}` and `\includegraphics{}`. After drafting, run `/review-paper` for a top-journal-style review covering 6 dimensions.

### Step 5: Quality Gate

Run `/quality-gate`. Extracts every quantitative claim from your paper (coefficients, sample sizes, p-values, table/figure references) and cross-references against `output/`. Reports MATCHED, UNVERIFIED, or MISSING FILE for each claim. Follow up with `/proofread` for grammar, typos, layout, and consistency checks.

---

## Skills Reference

### `/research-setup`

Interactive wizard to configure a new project. Asks grouped questions about your field, institution, journals, datasets, key researchers, and institutional R color palette.

- **Writes:** `references/domain-profile.md`, `rules/r-code-conventions.md` (color palette), `CLAUDE.md` (project name/institution)
- **Depends on:** Nothing. Designed to run first on a blank project.

### `/new-project`

Structured three-phase interview to formalize a research idea into a project spec with research questions and identification strategies.

- **Argument:** Topic or research question (e.g., `/new-project effect of minimum wage on employment`)
- **Writes:** `quality_reports/specs/project_spec_[topic].md`
- **Depends on:** Nothing required. Richer output if `CLAUDE.md` has project identity.

### `/lit-review`

Dispatches 3–5 parallel librarian agents to search journals, NBER/SSRN/IZA, and citation chains. Consolidates results into a thematic report with BibTeX entries.

- **Argument:** Topic or research question
- **Agents:** `librarian` (3–5 instances in parallel)
- **Reads:** `quality_reports/specs/project_spec_*.md`, `references/domain-profile.md`, existing `.bib` file
- **Writes:** `quality_reports/lit_review_[topic].md`
- **Depends on:** `references/domain-profile.md` for journal list and key researchers.
- **External:** WebSearch, WebFetch, Semantic Scholar API

### `/validate-bib`

Scans all `.tex` and `.qmd` source files for citation keys and cross-references against the `.bib` file. Reports missing entries, unused references, and potential typos.

- **Reads:** `paper/**/*.tex`, `manuscripts/**/*.tex`, `Quarto/**/*.qmd`, `Bibliography_base.bib`
- **Writes:** Nothing (report printed inline)
- **Depends on:** A `.bib` file at project root.

### `/data-finder`

Dispatches parallel explorer agents to find datasets, then an explorer-critic to stress-test each candidate. Produces a ranked list with feasibility grades.

- **Argument:** Topic, or `from spec` to use the most recent project spec
- **Agents:** `explorer` (2 instances in parallel), `explorer-critic`
- **Reads:** `quality_reports/specs/project_spec_*.md`, `references/domain-profile.md`
- **Writes:** `quality_reports/data_exploration_[topic].md`
- **External:** WebSearch, WebFetch

### `/data-analysis`

End-to-end data analysis workflow. Autodetects R or Python, then runs through exploration, analysis, and publication-ready output.

- **Argument:** Dataset path (e.g., `/data-analysis data/my_dataset.csv`)
- **Reads:** `rules/r-code-conventions.md` (R track), dataset files
- **Writes:** `scripts/R/[name].R` or `scripts/python/[name].py`, `output/tables/`, `output/figures/`, `output/analysis/`, `output/diagnostics/`
- **Depends on:** `rules/r-code-conventions.md` for R standards.

### `/review-r`

Reviews R scripts against project coding conventions. Produces a quality report without editing files.

- **Argument:** File path, or `all` for all R scripts
- **Agents:** `r-reviewer`
- **Reads:** Target `.R` file(s), `rules/r-code-conventions.md`
- **Writes:** `quality_reports/[script_name]_r_review.md`
- **Depends on:** `rules/r-code-conventions.md` (required — this is the standard the agent checks against).

### `/write-paper`

Drafts a full academic manuscript from analysis outputs, project spec, and lit review. Inserts `\input{}` and `\includegraphics{}` references to actual output files.

- **Agents:** `domain-reviewer` (post-draft review)
- **Reads:** `quality_reports/specs/`, `quality_reports/lit_review_*.md`, `output/tables/**`, `output/figures/**`
- **Writes:** `paper/[project-name]-draft.tex` (or `.qmd`)
- **Depends on:** Completed analysis outputs in `output/`.

### `/review-paper`

Comprehensive manuscript review covering argument structure, identification strategy, econometric specification, literature positioning, writing quality, and presentation. Generates 3–5 "referee objections."

- **Argument:** File path to paper
- **Agents:** `domain-reviewer`
- **Reads:** Target paper, `master_supporting_docs/supporting_papers/`, `rules/`, `Bibliography_base.bib`
- **Writes:** `quality_reports/paper_review_[name].md`

### `/quality-gate`

Verifies every quantitative claim in the paper is traceable to an output file. Checks for missing citations, stale numbers, and unreferenced outputs.

- **Agents:** `verifier`
- **Reads:** Paper draft (`paper/**`), `output/tables/**`, `output/figures/**`, `Bibliography_base.bib`
- **Writes:** `quality_reports/quality_gate_[YYYY-MM-DD]_[paper-name].md`
- **Depends on:** Analysis outputs must exist in `output/`.

### `/proofread`

Proofreading protocol for academic writing. Checks grammar, typos, layout, consistency, and academic quality. Does not edit files — produces a report, then waits for your approval before applying any changes.

- **Argument:** File path, or `all` for all manuscripts
- **Agents:** `proofreader` (one per file when `all` is passed)
- **Reads:** Target `.tex`, `.qmd`, or `.md` file
- **Writes:** `quality_reports/[filename]_report.md`

### `/deep-audit`

Launches 4 parallel specialist agents to audit the entire repository for inconsistencies, cross-document errors, and broken references. Loops until clean (max 5 rounds). Primarily for plugin development — not typical research use.

- **Reads:** All files in `hooks/`, `skills/`, `rules/`, `agents/`, `README.md`
- **Writes:** Fixes applied directly to files with confirmed errors

---

## Agents Reference

Agents are specialized subagents launched by skills. You never invoke them directly.

| Agent | Role | Launched By |
|-------|------|-------------|
| `librarian` | Searches one literature angle (journals, working papers, or citation chain) | `/lit-review` |
| `explorer` | Finds candidate datasets across one source category | `/data-finder` |
| `explorer-critic` | Stress-tests dataset candidates across 5 dimensions | `/data-finder` |
| `proofreader` | Grammar, typos, layout, and consistency review | `/proofread` |
| `domain-reviewer` | Substantive correctness through 5 configurable lenses | `/review-paper`, `/write-paper` |
| `r-reviewer` | R code quality, reproducibility, and figure standards | `/review-r` |
| `verifier` | Traces paper claims to output files, checks bibliography | `/quality-gate` |

### librarian

Searches ONE assigned angle: top journals, secondary journals, NBER/SSRN/IZA working papers, backward citations, or forward citations. Uses Semantic Scholar API for citation chains. Returns verified BibTeX entries with confidence ratings. Multiple instances run in parallel (3–5 per lit review).

### explorer

Searches ONE assigned category of data sources: public microdata (CPS, ACS, NHIS), administrative data (Medicare, IRS, vital stats), survey panels (PSID, HRS, NLSY), international sources (World Bank, OECD, IPUMS), or novel/alternative sources (satellite, web scrape, RCT registries). Returns candidate datasets with feasibility grades (A–D).

### explorer-critic

Stress-tests dataset candidates from explorer agents across five dimensions: measurement validity, sample selection, external validity, identification compatibility, and known issues in the literature. Adjusts feasibility grades and flags deal-breakers. Runs after both explorer agents complete.

### proofreader

Reviews academic prose for grammar (subject-verb agreement, articles, tense), typos (misspellings, search-and-replace artifacts), layout issues (overfull hbox, table overflow), consistency (citation format, notation, variable naming), and academic quality (informal language, awkward phrasing). Produces a structured report — never edits files directly.

### domain-reviewer

Acts as a top-journal referee reviewing through 5 configurable lenses: assumption stress test, derivation verification, citation fidelity, code-theory alignment, and backward logic check. Customizable for field-specific standards by editing lines 9–26 of `agents/domain-reviewer.md`.

### r-reviewer

Reviews R scripts across 10 categories: script structure, console hygiene, reproducibility, function design, domain correctness, figure quality, RDS pattern, comments, error handling, and professional polish. Produces a detailed report with line numbers and proposed fixes, graded Critical/High/Medium/Low.

### verifier

Checks that scripts run cleanly (exit code 0), output files exist and are non-empty, spot-checks estimate plausibility, and verifies bibliography consistency (all cited keys present in `.bib`). Reports PASS/FAIL per check.

---

## Rules Reference

Rules are markdown files that auto-load based on file path matchers. You never invoke them — they activate when matching files are in context.

| Rule | Path Matcher | Purpose |
|------|-------------|---------|
| `workflow-overview.md` | `**/*` | Master orientation: 5-step workflow, skill/agent lists, quality thresholds |
| `plan-first-workflow.md` | `**/*` | Requires plan mode before non-trivial tasks |
| `orchestrator-protocol.md` | `**/*` | Autonomous execution loop after plan approval (Code vs. Prose tracks) |
| `r-code-conventions.md` | `**/*.R` | R coding standards: reproducibility, style, visual identity, RDS pattern |
| `quality-gates.md` | `**/*.tex`, `**/*.R`, `**/*.py`, etc. | 0–100 scoring rubric with deduction tables |
| `proofreading-protocol.md` | `**/*.tex`, `**/*.qmd` | Three-phase review: propose → approve → apply (never auto-edits) |
| `analysis-verification.md` | `scripts/**`, `output/**` | Requires running scripts and verifying outputs after writing analysis code |
| `replication-protocol.md` | `scripts/**`, `notebooks/**` | Replication-first workflow with tolerance thresholds |
| `pdf-processing.md` | `master_supporting_docs/**` | Safe PDF splitting (Ghostscript, 5-page chunks) for large documents |

### workflow-overview.md

Loaded every session. The master orientation document describing the 5-step research workflow, listing all skills and agents, explaining quality thresholds, and mapping the recommended project directory structure. This is the first thing Claude sees.

### plan-first-workflow.md

Loaded every session. Instructs Claude to enter plan mode before any non-trivial task, get your approval, then execute. Plans are saved to `quality_reports/plans/`. Specifications for complex tasks use the template at `templates/requirements-spec.md`.

### orchestrator-protocol.md

Loaded every session. After you approve a plan, Claude runs autonomously using one of two tracks:
- **Code Track:** implement → verify → score (max 2 retries if score < 80)
- **Prose Track:** implement → review → propose fixes → wait for your approval → apply → re-verify (max 5 rounds, never edits without approval)

### r-code-conventions.md

Loaded when any `.R` file is in context. Defines: one `set.seed()` call, `library()` not `require()`, relative paths only, `dir.create()` before saving, `saveRDS()` for all computed objects, snake_case function names, visual identity colors (institutional hex values), ggplot2 theme, figure dimensions, and line length policy (100 characters).

**Configurable:** Section 4 (Visual Identity) — institutional hex colors. Set automatically by `/research-setup` or edit manually.

### quality-gates.md

Loaded when scripts, papers, or notebooks are in context. Defines the 0–100 scoring rubric with deduction tables per file type. Key deductions: script failure (−100), claimed result absent from outputs (−50), domain bug (−30), missing citation (−15), broken table/figure reference (−5), style inconsistency (−1 each).

### proofreading-protocol.md

Loaded when `.tex` or `.qmd` files are in context. Enforces a three-phase workflow: (1) agent produces a report proposing changes, (2) you review and approve selectively, (3) agent applies only approved changes. The agent never edits files without explicit approval.

### analysis-verification.md

Loaded when working with scripts or outputs. Requires actually running scripts after writing any analysis code. Verification checklist: exit code is 0, output files exist with size > 0, spot-check one estimate for plausibility, no missing package warnings. Also checks bibliography consistency.

### replication-protocol.md

Loaded when working in `scripts/`, `notebooks/`, or `explorations/`. Four phases: inventory and baseline (record gold-standard numbers), translate and execute (match original spec exactly), verify match (tolerance thresholds: integers exact, point estimates < 0.01, SEs < 0.05), then extend. Includes Stata/R/Python translation pitfall tables.

### pdf-processing.md

Loaded when working in `master_supporting_docs/`. Specifies how to safely process large PDFs: check properties with `pdfinfo`, split with Ghostscript into 5-page chunks, process one chunk at a time, identify the most relevant sections for deep reading.

---

## Hooks Reference

Hooks run shell or Python scripts automatically on Claude Code events.

| Script | Trigger | Matcher | Purpose |
|--------|---------|---------|---------|
| `setup-project-dirs.sh` | SessionStart | (all) | Creates project scaffold, copies templates and references |
| `protect-files.sh` | PostToolUse | `Edit\|Write` | Blocks edits to protected files |
| `pre-compact.py` | PreCompact | (all) | Saves active plan and recent decisions before context compression |
| `post-compact-restore.py` | SessionStart | `compact\|resume` | Restores context after compaction |

### setup-project-dirs.sh

Runs on every session start. Creates `quality_reports/{plans,session_logs,specs,merges}/` directories. Copies all files from the plugin's `templates/` and `references/` directories into your project (no-clobber — your edits are never overwritten). This is how `references/domain-profile.md` and the starter templates arrive in your project.

### protect-files.sh

Runs after every Edit or Write tool call. Reads the tool input to extract the target file path and checks it against a configurable list of protected patterns. Currently protects `Bibliography_base.bib` and `settings.json`. If matched, exits with code 2 to block the edit. To customize, edit the `PROTECTED_PATTERNS` array in `hooks/protect-files.sh`.

### pre-compact.py

Runs before every context compaction. Captures your current work state: finds the most recent non-completed plan in `quality_reports/plans/`, extracts its status and current task, pulls recent decisions from the most recent session log, and saves everything to `~/.claude/sessions/[project-hash]/pre-compact-state.json`. Appends a compaction timestamp to the session log. Fails open (never blocks Claude).

### post-compact-restore.py

Runs on session start when the session matches "compact" or "resume." Reads the state file written by `pre-compact.py`, prints a formatted restoration message with the active plan, current task, and recovery instructions, then deletes the state file. This is how Claude picks up where it left off after context compression.

---

## Quality Scoring

All work is scored on a 0–100 scale:

| Score | Gate | Meaning |
|-------|------|---------|
| **80** | Commit | Good enough to save |
| **90** | PR | Ready for review/deployment |
| **95** | Excellence | Aspirational target |

### Key Deductions

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Script syntax error or failure | -100 |
| Critical | Claimed result absent from analysis outputs | -50 |
| Critical | Domain bug (wrong estimator, wrong SE method) | -30 |
| Critical | Hardcoded absolute path | -20 |
| Critical | Citation in paper not in bibliography | -15 |
| Major | Broken table or figure reference | -5 |
| Major | Writing quality blocks comprehension | -5 |
| Minor | Style inconsistency | -1 each |

The orchestrator protocol enforces these gates: work scoring below 80 triggers automatic fix-and-retry (max 2 rounds for code, max 5 for prose). Prose fixes always require your approval before applying.

---

## Project Structure

The recommended directory layout for a research project using this plugin:

```
your-project/
├── CLAUDE.md                         # Project context (name, author, current state)
├── Bibliography_base.bib             # Centralized bibliography (protected from edits)
├── references/
│   └── domain-profile.md            # Your field, journals, datasets, key researchers
├── templates/                        # Starter templates (copied from plugin on first session)
├── data/                             # Raw data files
├── scripts/
│   ├── R/                            # R analysis scripts
│   └── python/                       # Python analysis scripts
├── notebooks/                        # Jupyter notebooks
├── output/
│   ├── tables/                       # Generated .tex and .html tables
│   ├── figures/                      # Generated .pdf and .png figures
│   ├── analysis/                     # Analysis objects (.rds, .pkl)
│   └── diagnostics/                  # Diagnostic outputs
├── paper/                            # Manuscript drafts (.tex, .qmd)
├── quality_reports/
│   ├── plans/                        # Approved plans before implementation
│   ├── session_logs/                 # Session documentation
│   ├── specs/                        # Project specifications
│   └── merges/                       # Merge quality reports
├── master_supporting_docs/
│   └── supporting_papers/            # Reference papers and PDFs
└── explorations/                     # Exploratory analysis branches
```

The `quality_reports/` subdirectories and `templates/`/`references/` files are created automatically by the session-start hook.

---

## Customization

### Domain Profile

Edit `references/domain-profile.md` to change your field, target journals, common datasets, and key researchers. These are used by `/lit-review` (librarian agents search your journals) and `/data-finder` (explorer agents prioritize your datasets). Or re-run `/research-setup` to reconfigure interactively.

### Institutional Colors

Edit Section 4 (Visual Identity) of `rules/r-code-conventions.md` to set your institution's hex color palette. These colors are applied to all ggplot2 figures generated by `/data-analysis`. Set automatically by `/research-setup`.

### Protected Files

Edit the `PROTECTED_PATTERNS` array in `hooks/protect-files.sh` to add or remove files that Claude cannot edit. By default: `Bibliography_base.bib` and `settings.json`.

### Quality Thresholds

Edit `rules/quality-gates.md` to adjust score thresholds (80/90/95) and deduction values per issue type.

### Replication Tolerances

Edit `rules/replication-protocol.md` to adjust tolerance bands for numerical replication (point estimates, standard errors, p-values).

### Domain Reviewer Lenses

Edit lines 9–26 of `agents/domain-reviewer.md` to customize the 5 review lenses for your specific field.

---

## How Components Connect

```
/research-setup ──writes──► references/domain-profile.md
                             rules/r-code-conventions.md (colors)
                             CLAUDE.md

references/domain-profile.md ──read by──► /lit-review → librarian agents
                                          /data-finder → explorer agents

/new-project ──writes──► quality_reports/specs/project_spec_*.md
                              └──read by──► /lit-review
                                            /data-finder
                                            /write-paper

/lit-review ──writes──► quality_reports/lit_review_*.md
                              └──read by──► /write-paper

/data-analysis ──writes──► output/tables/, output/figures/, output/**/*.rds
                              └──read by──► /write-paper
                                            /quality-gate → verifier agent

/write-paper ──writes──► paper/[name]-draft.tex
                              └──read by──► /quality-gate
                                            /proofread
                                            /review-paper

setup-project-dirs.sh ──copies──► references/domain-profile.md (no-clobber)
                                   templates/*.md (no-clobber)

pre-compact.py ──writes──► ~/.claude/sessions/[hash]/pre-compact-state.json
post-compact-restore.py ──reads──► ~/.claude/sessions/[hash]/pre-compact-state.json
```

---

## Troubleshooting

**"I see directory creation messages when I start a session."**
Normal. The `setup-project-dirs.sh` hook creates `quality_reports/` subdirectories and copies templates on every session start. It is idempotent and never overwrites your files.

**"Claude won't edit my .bib file."**
The `protect-files.sh` hook blocks edits to `Bibliography_base.bib` by default. Edit the file manually, or remove it from the `PROTECTED_PATTERNS` array in `hooks/protect-files.sh`.

**"Context was compacted and Claude forgot what it was doing."**
The pre-compact and post-compact hooks handle this automatically. If context was lost, start a new message — the post-compact-restore hook will print a summary of the active plan and current task.

**"Which skill should I run first?"**
Start with `/research-setup` to configure your domain profile, then `/new-project` to formalize your research question. The rest follows the workflow order.

**"Can I skip steps in the workflow?"**
Yes. Each skill works independently. You can run `/data-analysis` without a lit review, or `/proofread` without running `/quality-gate` first. Skills produce richer output when prior steps have been completed, but nothing is strictly required except the dependencies listed in each skill's reference entry.

**"How do I add a new journal or dataset to the search list?"**
Edit `references/domain-profile.md` directly. Add journals to the "Top Journals" or "Secondary Journals" section, and datasets to "Common Datasets." The librarian and explorer agents read this file automatically.

---

*Author: Felpix | Version 1.0.0*
