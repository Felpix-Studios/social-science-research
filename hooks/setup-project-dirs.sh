#!/bin/bash
# Create project directory structure for social-science-research plugin.
# Runs on every SessionStart — safe to re-run (mkdir -p and cp -n are idempotent).
INPUT=$(cat)  # consume stdin (hook contract)

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
PROJECT_ROOT="$(pwd)"

# Create quality_reports subdirectory structure
for dir in quality_reports/plans quality_reports/session_logs quality_reports/specs quality_reports/merges; do
  mkdir -p "$PROJECT_ROOT/$dir"
done

# Copy templates into project if they don't exist yet (-n = no-clobber, preserves user edits)
if [ -d "$PLUGIN_ROOT/templates" ]; then
  mkdir -p "$PROJECT_ROOT/templates"
  for template in "$PLUGIN_ROOT/templates/"*.md; do
    [ -f "$template" ] && cp -n "$template" "$PROJECT_ROOT/templates/"
  done
fi

# Copy references/ (domain-profile template) into project if not present yet
if [ -d "$PLUGIN_ROOT/references" ]; then
  mkdir -p "$PROJECT_ROOT/references"
  for ref in "$PLUGIN_ROOT/references/"*.md; do
    [ -f "$ref" ] && cp -n "$ref" "$PROJECT_ROOT/references/"
  done
fi

exit 0
