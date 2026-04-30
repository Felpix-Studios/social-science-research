# CLAUDE.md — Plugin Development

**This directory is the plugin source** — not a research project using the plugin.
Files here are plugin assets being authored. When users install the plugin, the
folders below ship as part of the plugin install. Nothing is scaffolded into the
user's project directory automatically — `/research-setup` seeds project config
on demand, and other skills create folders only when they have something to write.

---

## What Ships with the Plugin

```
social-science-research/
├── .claude-plugin/plugin.json   # Plugin manifest
├── agents/                      # 9 subagent definitions
├── hooks/                       # 3 hooks (hooks.json + 3 scripts)
├── references/                  # domain-profile.md (seeded into project by /research-setup when missing)
├── rules/                       # 8 always-loaded rule files
├── skills/                      # 13 user-invocable skills
└── templates/                   # Read by skills/rules from ${CLAUDE_PLUGIN_ROOT}; never copied into the user's project
```

**Does NOT transfer:** `CLAUDE.md` (this file), `quality_reports/`, `.git/`

---

## Skills

Each skill lives at `skills/<name>/SKILL.md` and is invoked via `/<name>`.

---

### `/research-setup`
Interactive wizard to configure a new project. Asks grouped questions about field, institution, journals, datasets, key researchers, and R colors. Also the sole bootstrap entry point — seeds project config files when missing.

- **Reads:** `${CLAUDE_PLUGIN_ROOT}/references/domain-profile.md` (seed source), `./CLAUDE.md`, `./references/domain-profile.md`
- **Writes:**
  - `./references/domain-profile.md` — seeded from plugin via `cp` if missing, then populated with field, journals, datasets, researchers, and an "Institutional Colors" section
  - `./CLAUDE.md` — 4-line placeholder if missing, then project name, author, and institution
- **Depends on:** Nothing. Designed to run first on a blank project. Requires Bash for the seed `cp`.

---

### `/new-project`
Structured interview to formalize a research idea. Produces a project spec with research questions and identification strategies.

- **Reads:** `CLAUDE.md` (for project name/institution if available), `quality_reports/specs/` (for prior specs)
- **Writes:** `quality_reports/project_spec_[topic].md`
- **Depends on:** Nothing required. Richer output if `CLAUDE.md` has project identity filled in.

---

### `/lit-review`
Dispatches 3–5 parallel Librarian agents to search journals, NBER/SSRN/IZA, and citation chains. Consolidates results into a thematic report with BibTeX.

- **Reads:** `quality_reports/project_spec_*.md`, `references/papers/`, `Bibliography_base.bib` (or any `.bib` at project root), `references/domain-profile.md`
- **Writes:** `quality_reports/lit_review_[topic].md`
- **Agents used:** `librarian` (3–5 instances in parallel via Task)
- **Depends on:** `references/domain-profile.md` for journal list and key researchers. Falls back to asking the user if missing.
- **External calls:** WebSearch, WebFetch (Semantic Scholar API for citation chains)

---

### `/data-finder`
Dispatches parallel Explorer agents to find datasets for a research question, then an Explorer-Critic to stress-test each candidate. Produces a ranked list with feasibility grades.

- **Reads:** `quality_reports/project_spec_*.md`, `references/domain-profile.md`
- **Writes:** `quality_reports/data_exploration_[topic].md`
- **Agents used:** `explorer` (2 instances in parallel), `explorer-critic`
- **Depends on:** `references/domain-profile.md` for field-specific dataset list (Common Datasets section). More accurate with a project spec present.
- **External calls:** WebSearch, WebFetch

---

### `/write-paper`
Drafts a full academic manuscript from analysis outputs, project spec, and lit review. Inserts `\input{}` and `\includegraphics{}` references to actual output files.

- **Reads:** `CLAUDE.md`, `quality_reports/specs/`, `quality_reports/lit_review_*.md`, `quality_reports/research_ideation_*.md`, `output/tables/**/*.tex`, `output/tables/**/*.html`, `output/figures/**/*.pdf`, `output/figures/**/*.png`, `output/**/*.rds`, `output/**/*.pkl`, `output/**/*.parquet`
- **Writes:** `manuscripts/[project-name]-draft.tex` (or `.qmd`)
- **Depends on:** Completed analysis outputs in `output/`. Richer output with project spec and lit review present.

---

### `/data-analysis`
End-to-end data analysis workflow in R or Python. Writes analysis scripts and saves all outputs.

- **Reads:** `rules/r-code-conventions.md` (R track), dataset files provided by user
- **Writes:**
  - R track: `scripts/R/[name].R`, `output/analysis/`, `output/diagnostics/`, `output/figures/`, `output/tables/`
  - Python track: `scripts/python/[name].py`, `output/analysis/`, `output/diagnostics/`, `output/figures/`
- **Depends on:** `rules/r-code-conventions.md` for R standards. Dataset path or description required as argument.

---

### `/proofread`
Runs the proofreading protocol on slides or manuscripts. Produces a structured report without editing source files.

- **Reads:** Target file (`.tex`, `.qmd`, or `.md`) from `manuscripts/` or `Quarto/`
- **Writes:** `quality_reports/[filename]_report.md` (slides), `quality_reports/[filename]_qmd_report.md` (Quarto), or `quality_reports/[filename]_proofread.md` (manuscripts)
- **Agents used:** `proofreader` (one per file when `all` is passed, in parallel)
- **Depends on:** `rules/proofreading-protocol.md` (loaded automatically by path matcher)

---

### `/review-r`
Reviews R scripts against project coding conventions. Produces a quality report without editing files.

- **Reads:** Target `.R` file(s) from `scripts/R/` or `Figures/`, `rules/r-code-conventions.md`
- **Writes:** `quality_reports/[script_name]_r_review.md`
- **Agents used:** `r-reviewer`
- **Depends on:** `rules/r-code-conventions.md` — this is the authoritative standards source. Review is meaningless without it.

---

### `/review-paper`
Comprehensive manuscript review covering argument structure, econometric specification, citation completeness, and likely referee objections.

- **Reads:** Target paper (`.tex`, `.pdf`, or `.qmd`) — from argument or searched in `references/papers/`, `rules/`, `Bibliography_base.bib`
- **Writes:** `quality_reports/paper_review_[name].md`
- **Agents used:** `domain-reviewer`, `adversarial-reviewer`, `fresh-eyes-reviewer` (dispatched in parallel)
- **Depends on:** `references/papers/` and `rules/` for cross-referencing. Paper file required.

---

### `/revise-paper`
Applies revisions from a review report to a manuscript. Reads the review, presents a prioritized revision plan, and applies fixes section-by-section with user approval.

- **Reads:** `quality_reports/paper_review_*.md` or `quality_reports/*_substance_review.md`, manuscript in `manuscripts/`
- **Writes:** Edits to manuscript, `quality_reports/revision_summary_[paper-name].md`
- **Agents used:** `proofreader` (post-revision check)
- **Depends on:** A review report from `/review-paper` or `/proofread`. Manuscript must exist.

---

### `/quality-gate`
Verifies every quantitative claim in the paper is traceable to an output file. Checks for missing citations, stale numbers, and unreferenced outputs.

- **Reads:** Paper draft (`manuscripts/**/*.tex` or `manuscripts/**/*.qmd`), `output/tables/**`, `output/figures/**`, `output/**/*.rds`, `Bibliography_base.bib`
- **Writes:** `quality_reports/quality_gate_[YYYY-MM-DD]_[paper-name].md`
- **Agents used:** `verifier`
- **Depends on:** Analysis outputs must exist in `output/`. Bibliography file must exist. Paper draft required.

---

### `/validate-bib`
Scans all source files for citation keys and cross-references against the `.bib` file. Reports missing entries and unused references.

- **Reads:** `manuscripts/**/*.tex`, `Quarto/**/*.qmd`, `Bibliography_base.bib` (or any `.bib` at project root)
- **Writes:** Nothing (report printed inline)
- **Depends on:** A `.bib` file at project root. No agents used.

---

### `/session-log`
Create or update a session log to capture decisions, changes, and progress.

- **Reads:** `quality_reports/plans/*.md`, `quality_reports/session_logs/*.md`, `${CLAUDE_PLUGIN_ROOT}/templates/session-log.md`, git log
- **Writes:** `quality_reports/session_logs/YYYY-MM-DD_[description].md`
- **Depends on:** Nothing required. More useful when a plan exists.

---

## Agents

Agents are subagents launched by skills via `Task`. They are not directly invoked by users.

---

### `librarian`
Searches a single angle (top journals, NBER/SSRN/IZA, or citation chain) and returns structured BibTeX results.

- **Launched by:** `/lit-review`
- **Reads:** Web (WebSearch, WebFetch), Semantic Scholar API for citation chains
- **Returns:** BibTeX entries + summary to calling skill. Does not write files directly.
- **Depends on:** Search angle and topic passed in Task prompt. Journal list sourced from `domain-profile.md` via the calling skill.

---

### `explorer`
Searches a category of data sources (government, academic, international, etc.) for datasets matching a research question.

- **Launched by:** `/data-finder`
- **Reads:** Web (WebSearch, WebFetch), `references/domain-profile.md` (Common Datasets section, passed in via Task prompt)
- **Returns:** Dataset candidates with metadata to calling skill. Does not write files directly.
- **Depends on:** Research question, empirical strategy, and variable details passed in Task prompt.

---

### `explorer-critic`
Stress-tests dataset candidates produced by Explorer agents. Evaluates coverage, access barriers, and fit to identification strategy.

- **Launched by:** `/data-finder` (after explorer agents complete)
- **Reads:** Dataset list passed in Task prompt, Web for verification
- **Returns:** Ranked, graded dataset list to calling skill.
- **Depends on:** Explorer output. Must run after Explorer agents, not in parallel.

---

### `proofreader`
Reviews a single document for grammar, typos, layout, consistency, and academic writing quality.

- **Launched by:** `/proofread`
- **Reads:** Target file passed in Task prompt
- **Returns:** Structured report to calling skill. Does not write files directly (the skill writes the report).
- **Depends on:** `rules/proofreading-protocol.md` (loaded via path matcher when `.tex`/`.qmd`/`.md` files are in context)

---

### `domain-reviewer`
Reviews a paper or analysis for substantive correctness through 5 configurable lenses (assumptions, derivations, citations, code-theory alignment, logical consistency).

- **Launched by:** `/review-paper`
- **Reads:** Target document, `references/papers/`, `rules/`
- **Returns:** Structured review report. Does not write files directly.
- **Customize:** Lines 9–26 of `agents/domain-reviewer.md` contain instructions for adapting the 5 lenses to a specific field.
- **Depends on:** `rules/` and `references/papers/` for cross-referencing; both are optional but improve review quality.

---

### `adversarial-reviewer`
Hostile-referee stress test. Actively tries to kill the paper through 5 attack lenses (fatal flaw hunt, over-claim detection, alternative explanations, identification weakest link, desk-editor rejection letter).

- **Launched by:** `/review-paper` (in parallel with `domain-reviewer` and `fresh-eyes-reviewer`)
- **Reads:** Target paper, `references/domain-profile.md` (for venue calibration), `quality_reports/specs/` (for claimed contribution)
- **Returns:** Adversarial report with fatal flaws, over-claims, alt. explanations, and a two-paragraph rejection letter. Does not write files directly.
- **Depends on:** `references/domain-profile.md` for venue bar calibration; falls back to top-field-journal bar if absent.

---

### `fresh-eyes-reviewer`
First-time reader perspective. Reads the paper cold — no spec, no lit review, no analysis scripts — and reports what lands and what confuses on a first read. Five passes: abstract-only, intro-only, main display standalone, full read, what stays with the reader.

- **Launched by:** `/review-paper` (in parallel with `domain-reviewer` and `adversarial-reviewer`)
- **Reads:** Target paper only — explicitly does NOT read spec, lit review, ideation, or scripts.
- **Returns:** Structured five-pass report covering first-read clarity, undefined terms, re-read zones, and memorability. Does not write files directly.
- **Depends on:** Nothing beyond the manuscript itself — the lack of context is the feature.

---

### `r-reviewer`
Reviews R scripts for reproducibility, style, domain correctness, and visual identity compliance.

- **Launched by:** `/review-r`
- **Reads:** Target `.R` file(s), `rules/r-code-conventions.md`
- **Returns:** Structured quality report. Does not write files directly.
- **Depends on:** `rules/r-code-conventions.md` is required — it is the authoritative standard the agent checks against.

---

### `verifier`
Traces every quantitative claim in a paper draft back to output files. Flags missing outputs, stale numbers, and uncited results.

- **Launched by:** `/quality-gate`
- **Reads:** Paper draft, `output/tables/**`, `output/figures/**`, `output/**/*.rds`, `Bibliography_base.bib`
- **Returns:** Verification report with pass/fail per claim.
- **Depends on:** Analysis outputs in `output/` and a compiled or readable paper draft.

---

## Rules

Rules are markdown files loaded automatically by Claude Code based on `paths:` matchers in their frontmatter. No user action needed — they activate when matching files are in context.

---

### `r-code-conventions.md`
**Paths:** `**/*.R`, `Figures/**/*.R`, `scripts/**/*.R`
Defines R coding standards: reproducibility, function design, visual identity colors, figure dimensions, RDS pattern, common pitfalls, and line-length policy.

- **Configurable:** Section 4 (Visual Identity) — institutional hex colors. Set by `/research-setup` or manually.
- **Read by:** `r-reviewer` agent, `data-analysis` skill
- **Modifies nothing.** Loaded as context only.

---

### `quality-gates.md`
**Paths:** `**/*.tex`, `**/*.qmd`, `**/*.R`, `**/*.py`, `**/*.ipynb`, `manuscripts/**`
Defines the 0–100 scoring rubric: deduction tables for critical/major/minor issues, thresholds (80 = commit, 90 = PR, 95 = excellence), and numerical tolerance bands.

- **Configurable:** Score thresholds and deduction values can be adjusted for different standards.
- **Read by:** `quality-gate` skill, `domain-reviewer` and `r-reviewer` agents implicitly via path match
- **Modifies nothing.**

---

### `proofreading-protocol.md`
**Paths:** `manuscripts/**/*.tex`, `manuscripts/**/*.qmd`, `Quarto/**/*.qmd`
Defines the proofreading checklist: grammar, typos, layout, consistency, academic quality. Specifies report output naming conventions.

- **Read by:** `proofreader` agent (loaded automatically when target files are in context)
- **Modifies nothing.** Output naming: `quality_reports/[filename]_report.md` etc.

---

### `workflow-overview.md`
**Paths:** `**/*` (loads every session)
The master orientation document. Describes the 5-step research workflow, lists all available skills and agents, explains quality thresholds, and maps the recommended project directory structure.

- **Read by:** Every session — this is the first thing Claude sees.
- **Modifies nothing.** Pure reference.

---

### `plan-first-workflow.md`
**Paths:** All (general guideline, loads every session)
Instructs Claude to enter plan mode before any non-trivial task, get approval, then execute. Defines plan file naming and storage conventions.

- **Writes (indirectly):** `quality_reports/plans/YYYY-MM-DD_[description].md` — Claude creates plan files per this rule
- **Spec storage:** `quality_reports/specs/YYYY-MM-DD_[description].md`
- **Template reference:** `${CLAUDE_PLUGIN_ROOT}/templates/requirements-spec.md`
- **Session log storage:** `quality_reports/session_logs/YYYY-MM-DD_[description].md`
- **Session log template:** `${CLAUDE_PLUGIN_ROOT}/templates/session-log.md`

---

### `analysis-verification.md`
**Paths:** `scripts/**/*.R`, `scripts/**/*.py`, `notebooks/**/*.ipynb`, `output/**`
Requires Claude to actually run scripts and verify output after writing any analysis code.

- **Depends on:** Bash tool access to run `Rscript` or `python`. Bibliography file at `Bibliography_base.bib`.
- **Modifies nothing.** Behavioral constraint only.

---

### `replication-protocol.md`
**Paths:** `scripts/**/*.R`, `scripts/**/*.py`, `notebooks/**/*.ipynb`, `explorations/**`
Defines tolerance thresholds for numerical replication (point estimates, SEs, p-values). Includes language-translation pitfall tables (Stata ↔ R ↔ Python).

- **Writes (indirectly):** `quality_reports/[analysis-name]_replication_targets.md` and `quality_reports/[analysis-name]_replication_report.md`
- **Configurable:** Tolerance values and pitfall tables.

---

### `orchestrator-protocol.md`
**Paths:** All (loads every session)
Defines the orchestrator loop: after plan approval, Claude runs autonomously — detect track (Code vs. Prose), execute, verify quality scores, fix, loop until thresholds met (max 5 rounds for prose).

- **Depends on:** `quality-gates.md` thresholds (80/90/95).
- **Modifies nothing.** Behavioral protocol only.

---

## Hooks

Hooks run shell/Python scripts automatically on Claude Code events.

---

### `protect-files.sh`
**Trigger:** `PostToolUse` on `Edit` or `Write` tool calls
Blocks accidental edits to protected files by exiting with code 2 (blocking exit).

- **Protects:** `Bibliography_base.bib`, `settings.json` (configurable list in the script)
- **Reads:** Tool input JSON from stdin to extract `file_path`
- **Writes nothing.** Blocking hook — exit 2 stops the tool call.
- **Customize:** Edit `PROTECTED_PATTERNS` array in the script to add/remove protected files.

---

### `pre-compact.py`
**Trigger:** `PreCompact` (before every context compaction)
Captures current work state before context window is compressed.

- **Reads:** `quality_reports/plans/*.md` (finds most recent non-completed plan and current task), `quality_reports/session_logs/*.md` (extracts recent decisions)
- **Writes:** `~/.claude/sessions/[project-hash]/pre-compact-state.json` (state snapshot)
- **Appends:** Compaction timestamp note to most recent session log in `quality_reports/session_logs/`
- **Depends on:** `CLAUDE_PROJECT_DIR` env var. Fails open (exit 0) on any error to never block Claude.

---

### `post-compact-restore.py`
**Trigger:** `SessionStart` with matcher `compact|resume`
Restores context after compaction by printing a summary of where Claude left off.

- **Reads:** `~/.claude/sessions/[project-hash]/pre-compact-state.json` (written by pre-compact hook), `quality_reports/plans/*.md`, `quality_reports/session_logs/*.md`
- **Deletes:** `pre-compact-state.json` after reading (clean up)
- **Writes nothing** to the project directory.
- **Prints to stdout:** Formatted restoration message with active plan, current task, and recovery instructions.
- **Depends on:** `pre-compact.py` having run before compaction. Fails open if state file is missing.

---

## Inter-Component Dependency Map

```
/research-setup ──writes──► references/domain-profile.md
                             references/domain-profile.md (colors)
                             CLAUDE.md

references/domain-profile.md ──read by──► /lit-review → librarian agents
                                          /data-finder → explorer agents

rules/r-code-conventions.md ──read by──► /review-r → r-reviewer agent
                                         /data-analysis

/new-project ──writes──► quality_reports/project_spec_*.md
                              └──read by──► /lit-review
                                            /data-finder
                                            /write-paper

/lit-review ──writes──► quality_reports/lit_review_*.md
                              └──read by──► /write-paper

/data-analysis ──writes──► output/tables/, output/figures/, output/**/*.rds
                              └──read by──► /write-paper
                                            /quality-gate → verifier agent

/write-paper ──writes──► manuscripts/[name]-draft.tex
                              └──read by──► /quality-gate
                                            /proofread
                                            /review-paper

/research-setup ──seeds (when missing)──► references/domain-profile.md
                                          CLAUDE.md
                                          (read from ${CLAUDE_PLUGIN_ROOT}/references/)

${CLAUDE_PLUGIN_ROOT}/templates/ ──read by──► /session-log
                                              plan-first-workflow.md
                                              quality-gates.md
                                              (templates ship with plugin; never copied into project)

pre-compact.py ──writes──► ~/.claude/sessions/[hash]/pre-compact-state.json
post-compact-restore.py ──reads──► ~/.claude/sessions/[hash]/pre-compact-state.json
```
