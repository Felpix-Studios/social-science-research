# Social Science Research

> **Work in Progress.** This plugin is still under active development by a university student. For now, it is an experiment on the utility of Claude Code for social science research. If you have any feedback or suggestions, reach me on X at [@felpix_](https://x.com/felpix_).

A Claude Code plugin based on [Pedro Sant'Anna's Claude Code workflow](https://github.com/pedrohcgs/claude-code-my-workflow) designed for producing social science research.

## Quick Start

### 1. Install

Install the plugin via Claude Code. Project scope or user (global) scope both work — the plugin is inert until you invoke a skill, so installing globally will not scaffold anything in unrelated repos.

```bash
/plugin marketplace add Felpix-Studios/social-science-research
```

```
/plugin install social-science-research@felpix-research
```

### 2. Run `/research-setup`

`/research-setup` is the bootstrap entry point. It seeds `references/domain-profile.md` (your field's journals, datasets, and key researchers) and `CLAUDE.md` (project name, author, institution) into the project directory, then walks you through configuring your field, institution, journals, datasets, key researchers, and institutional colors. Other skills create `quality_reports/`, `output/`, `scripts/`, and `manuscripts/` lazily — only the directory a skill needs to write to gets created, at the moment of write.

Enjoy using the plugin!

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| Claude Code (with plugin support) | Everything | [claude.ai/download](https://claude.ai/download) |
| R (>= 4.0) | `/data-analysis` (R track), `/review-r` | [r-project.org](https://www.r-project.org/) |
| Python (>= 3.9) | `/data-analysis` (Python track), compact hooks | [python.org](https://www.python.org/) |
| LaTeX distribution | `/write-paper` with `.tex` output | [tug.org/texlive](https://tug.org/texlive/) |

## How It Works

| Step | What You Do | Skill(s) | Output |
|------|-------------|----------|--------|
| 0. Setup | Configure field, journals, datasets, R colors | `/research-setup` | `references/domain-profile.md`, `CLAUDE.md` |
| 1. Idea | Interview → ideation → unified project spec | `/new-project` | `quality_reports/project_spec_*.md` |
| 2a. Literature | Parallel journal + working paper + citation search | `/lit-review` then `/validate-bib` | `quality_reports/lit_review_*.md` |
| 2b. Data | Find and assess datasets for the research question | `/data-finder` | `quality_reports/data_exploration_*.md` |
| 3. Analysis | Run R or Python analysis, review code quality | `/data-analysis` then `/review-r` | `output/tables/`, `output/figures/`, `scripts/` |
| 4. Write | Draft the manuscript, then proofread → review → revise (loop until clean) | `/write-paper` → `/proofread` → `/review-paper` ⇄ `/revise-paper` | `manuscripts/[name]-draft.tex`, `quality_reports/paper_review_*.md` |
| 5. Verify | Gate analysis-paper consistency and bibliography before submission | `/quality-gate`, `/validate-bib` | `quality_reports/quality_gate_*.md` |

## What's Included

<details>
<summary><strong>9 agents, 13 skills, 8 rules, 3 hooks</strong> (click to expand)</summary>

### Agents

| Agent | What It Does |
|-------|-------------|
| `librarian` | Search one literature angle and return BibTeX |
| `explorer` | Find datasets across one source category |
| `explorer-critic` | Stress-test dataset candidates on 5 dimensions |
| `proofreader` | Grammar, typos, layout, and consistency check |
| `domain-reviewer` | Top-journal referee review through 5 lenses |
| `adversarial-reviewer` | Hostile-referee attack: fatal flaws, over-claims, alt. explanations, rejection letter |
| `fresh-eyes-reviewer` | First-time reader perspective — what lands, what confuses on a cold read |
| `r-reviewer` | R code quality and reproducibility review |
| `verifier` | Trace paper claims to output files |

### Skills

| Skill | What It Does |
|-------|-------------|
| `/research-setup` | Configure field, institution, journals, datasets, and colors |
| `/new-project` | Interactive interview to formalize a research idea |
| `/lit-review` | Literature search, synthesis, and gap identification |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/data-finder` | Find and rank datasets for a research question |
| `/data-analysis` | End-to-end R or Python analysis with publication-ready output |
| `/review-r` | Launch R code reviewer on scripts |
| `/write-paper` | Draft manuscript from analysis outputs, then run a structural smoke test (broken refs, placeholders, missing sections) |
| `/review-paper` | Manuscript review via three agents in parallel: substance (domain), adversarial attack, and first-read clarity |
| `/revise-paper` | Apply revisions from a review report to a manuscript |
| `/quality-gate` | Verify every paper claim traces to an output file |
| `/proofread` | Launch proofreader on a file |
| `/session-log` | Create or update a session log to capture decisions and progress |

### Rules

| Rule | What It Does |
|------|-------------|
| `workflow-overview.md` | Master orientation: workflow, skills, agents, thresholds |
| `plan-first-workflow.md` | Plan mode before non-trivial tasks; session logs |
| `orchestrator-protocol.md` | Autonomous execution loop (Code vs Prose track) |
| `r-code-conventions.md` | R coding standards and visual identity |
| `quality-gates.md` | 0-100 scoring rubric with deduction tables |
| `proofreading-protocol.md` | Three-phase review: propose, approve, apply |
| `analysis-verification.md` | Run scripts and verify outputs after writing code |
| `replication-protocol.md` | Replicate original results before extending |

### Hooks

| Hook | What It Does |
|------|-------------|
| `protect-files.sh` | Block edits to protected files |
| `pre-compact.py` | Save plan state and decisions before compaction |
| `post-compact-restore.py` | Restore context after compaction |

</details>

## License

MIT License. See [LICENSE](LICENSE).
