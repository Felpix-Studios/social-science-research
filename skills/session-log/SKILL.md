---
name: session-log
description: Create or update a session log to capture decisions, changes, and progress. Use at any point during a work session to document what was accomplished. Triggers include: "log this session", "create a session log", "update the session log", "save my progress", "record what we did", "what did we do today", or any request to document session work.
argument-hint: "[create | update | 'description of what to log']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash"]
---

# Session Log

Create or update a session log to capture decisions, changes, and progress.

**Input:** `$ARGUMENTS` — `create` for a new log, `update` to append to the most recent log, or a description of what to log.

---

## Step 1: Determine Mode

- If `$ARGUMENTS` is `create` or no session log exists in `quality_reports/session_logs/` → **Create mode**
- Otherwise → **Update mode**

---

## Step 2: Create Mode

1. Read the most recent plan from `quality_reports/plans/` (if any) to auto-populate Objective
2. Run `git log --oneline -10` to see recent commits
3. Read the format template via Bash: `cat "${CLAUDE_PLUGIN_ROOT}/templates/session-log.md"` (templates ship inside the plugin and are not copied into the project)
4. Save to `quality_reports/session_logs/YYYY-MM-DD_short-description.md`
5. Populate:
   - **Objective:** from plan or `$ARGUMENTS`
   - **Status:** IN PROGRESS
   - **Design Decisions:** from plan or argument (prefix each with `Decision:`)
   - **Changes Made:** from recent git log if relevant

Tell the user the log was created and where.

---

## Step 3: Update Mode

1. Read the most recent session log in `quality_reports/session_logs/`
2. Run `git diff --stat` and `git log --oneline -5` to see what changed since last update
3. Append new entries to the appropriate sections:
   - **Changes Made:** new files modified (from git diff)
   - **Design Decisions:** if `$ARGUMENTS` contains decision text, add as `Decision: [text]`
   - **Incremental Work Log:** add timestamped entry for current work
4. If all planned work is complete, update **Status** to COMPLETED

Tell the user what was added to the log.
