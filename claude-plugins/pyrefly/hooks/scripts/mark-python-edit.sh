#!/usr/bin/env bash
# PostToolUse hook: remember that this session changed a Python file, so the
# Stop hook knows it has something to type check.
set -uo pipefail

[ "${PYREFLY_AGENT_HOOKS:-1}" = "0" ] && exit 0

input="$(cat 2>/dev/null || true)"
[ -n "$input" ] || exit 0

parsed="$(printf '%s' "$input" | python3 -I -c '
import json, sys

data = json.load(sys.stdin)
tool_input = data.get("tool_input") or {}
path = tool_input.get("file_path") or ""
if not path:
    edits = tool_input.get("edits") or []
    if edits:
        path = edits[0].get("file_path") or ""
print(data.get("session_id") or "default")
print(path)
' 2>/dev/null)" || exit 0

session_id="$(printf '%s\n' "$parsed" | sed -n '1p')"
file_path="$(printf '%s\n' "$parsed" | sed -n '2p')"

case "$file_path" in
  *.py|*.pyi) ;;
  *) exit 0 ;;
esac

session_id="$(printf '%s' "$session_id" | tr -c 'A-Za-z0-9_-' '_')"
marker="${TMPDIR:-/tmp}/pyrefly-agent-${session_id}.dirty"
: > "$marker" 2>/dev/null || true

exit 0
