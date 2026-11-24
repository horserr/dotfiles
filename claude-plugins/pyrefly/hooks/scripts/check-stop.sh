#!/usr/bin/env bash
# Stop hook: block completion while the session's Python edits do not type
# check. Only runs after a Python edit, so unrelated turns stay cheap.
set -uo pipefail

[ "${PYREFLY_AGENT_HOOKS:-1}" = "0" ] && exit 0

input="$(cat 2>/dev/null || true)"
session_id="$(printf '%s' "$input" | python3 -I -c 'import json, sys; print(json.load(sys.stdin).get("session_id") or "default")' 2>/dev/null || true)"
[ -n "$session_id" ] || session_id="default"
session_id="$(printf '%s' "$session_id" | tr -c 'A-Za-z0-9_-' '_')"

marker="${TMPDIR:-/tmp}/pyrefly-agent-${session_id}.dirty"
counter="${TMPDIR:-/tmp}/pyrefly-agent-${session_id}.blocks"

[ -e "$marker" ] || exit 0
command -v pyrefly >/dev/null 2>&1 || exit 0

root="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$root" 2>/dev/null || exit 0

output="$(pyrefly check --color=never --output-format=min-text 2>&1)"
status=$?

if [ "$status" -eq 0 ]; then
  rm -f "$marker" "$counter"
  exit 0
fi

if [ "$status" -ne 1 ]; then
  # Pyrefly could not produce a type-check result (3 = environment or config
  # failure, 101 = crash). Do not block completion on a broken toolchain.
  rm -f "$marker" "$counter"
  printf '{"systemMessage": "pyrefly check could not run (exit %s); skipping the type-check gate."}\n' "$status"
  exit 0
fi

blocks=0
if [ -f "$counter" ]; then
  blocks="$(cat "$counter" 2>/dev/null || echo 0)"
  case "$blocks" in ''|*[!0-9]*) blocks=0 ;; esac
fi
blocks=$((blocks + 1))
printf '%s\n' "$blocks" > "$counter" 2>/dev/null || true

if [ "$blocks" -gt 3 ]; then
  # Avoid an endless loop on errors the agent cannot fix in this environment.
  rm -f "$marker" "$counter"
  printf '{"systemMessage": "pyrefly: type errors remain after three attempts; the Stop gate is disabled for this task."}\n'
  exit 0
fi

printf 'pyrefly found type errors. Fix the underlying issues, then run `pyrefly check` again.\n\n%s\n' "$output" >&2
exit 2
