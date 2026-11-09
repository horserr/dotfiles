#!/usr/bin/env bash
# Stop hook: one deterministic reminder per session to reconcile research memory.
# Stop fires after every assistant response, so throttle to avoid noise.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$PWD}"
mem="$root/research"

[ -d "$mem" ] || exit 0

input="$(cat 2>/dev/null || true)"
session_id="$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
[ -n "$session_id" ] || session_id="default"

marker="${TMPDIR:-/tmp}/claude-research-reminded-${session_id}"
[ -e "$marker" ] && exit 0
: > "$marker" 2>/dev/null || true

msg="Research session check: did this session add papers, change a hypothesis, make a decision, or discover a limitation? If so, update research/ (02_literature, 01_research_questions, 05_project/decisions.md, 06_open_problems). Run /research:weekly-research-review for a full reconciliation. This is a reminder only; do not change research conclusions automatically."

printf '{"systemMessage": "%s"}\n' "$msg"
