---
description: Enter plan mode before non-trivial tasks. Get user approval, then execute. Save plans to quality_reports/plans/.
paths: ["**/*"]
---

# Plan-First Workflow

**For any non-trivial task, enter plan mode before writing code.**

## The Protocol

1. **Enter Plan Mode** — use `EnterPlanMode`
2. **Read the most recent session log** in `quality_reports/session_logs/` for relevant context
3. **Requirements Specification (for complex/ambiguous tasks)** — see below
4. **Draft the plan** — what changes, which files, in what order
5. **Save to disk** — write to `quality_reports/plans/YYYY-MM-DD_short-description.md`
6. **Present to user** — wait for approval
7. **Exit plan mode** — only after approval
8. **Implement via orchestrator** — see `orchestrator-protocol.md`

**Tip:** Use `/session-log create` to capture session state at any time.

## Step 3: Requirements Specification (For Complex/Ambiguous Tasks)

**When to use:**
- Task is high-level or vague ("improve the paper", "analyze the data")
- Multiple valid interpretations exist
- Significant effort required (>1 hour or >3 files)

**When to skip:**
- Task is clear and specific ("fix typo in line 42")
- Simple single-file edit
- User has already provided detailed requirements

**Protocol:**
1. Use AskUserQuestion to clarify ambiguities (max 3-5 questions)
2. Create `quality_reports/specs/YYYY-MM-DD_description.md` using `${CLAUDE_PLUGIN_ROOT}/templates/requirements-spec.md` (read via `cat "${CLAUDE_PLUGIN_ROOT}/templates/requirements-spec.md"`; the template ships with the plugin and is not copied into the project)
3. Mark each requirement:
   - **MUST** (non-negotiable)
   - **SHOULD** (preferred)
   - **MAY** (optional)
4. Get user approval on spec
5. THEN proceed to Step 4 (draft the plan) with spec as input

**Template:** `${CLAUDE_PLUGIN_ROOT}/templates/requirements-spec.md`

**Why this helps:** Catches ambiguity BEFORE planning. Reduces mid-plan pivots by 30-50%.

