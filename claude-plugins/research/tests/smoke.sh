#!/usr/bin/env bash
# Offline structural smoke test for the research plugin.
# Network-dependent paper fetching is intentionally not tested here.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

PY=python3
command -v python3 >/dev/null 2>&1 || PY=python

"$PY" - <<'PY'
import json
for path in (".claude-plugin/plugin.json", "hooks/hooks.json"):
    with open(path, encoding="utf-8") as fh:
        json.load(fh)
print("manifest JSON: OK")
PY

for f in agents/*.md skills/*/SKILL.md; do
  grep -q '^name:' "$f" || { echo "missing name: $f" >&2; exit 1; }
  grep -q '^description:' "$f" || { echo "missing description: $f" >&2; exit 1; }
done
echo "frontmatter: OK"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

TARGET_DIR="$tmp/research" CLAUDE_PLUGIN_ROOT="$root" bash -c '
target="${TARGET_DIR:-research}"
src="${CLAUDE_PLUGIN_ROOT}/templates/research"
mkdir -p "$target"
target="$(cd "$target" && pwd)"
cd "$src" || exit 1
find . -type f | while IFS= read -r f; do
  rel="${f#./}"
  dest="$target/$rel"
  if [ -e "$dest" ]; then
    :
  else
    mkdir -p "$(dirname "$dest")"
    cp "$f" "$dest"
  fi
done
'

test -f "$tmp/research/00_overview.md"
test -f "$tmp/research/06_open_problems/research_gaps.md"
test -f "$tmp/research/02_literature/paper_database.csv"
test -f "$tmp/research/02_literature/search_strategy.md"
echo "template copy: OK"

start_output="$(CLAUDE_PROJECT_DIR="$tmp" bash hooks/scripts/session-start.sh)"
case "$start_output" in *"<research-memory>"*) ;; *) echo "session-start output missing snapshot" >&2; exit 1;; esac

marker="${TMPDIR:-/tmp}/claude-research-reminded-smoke"
rm -f "$marker"
stop_output="$(printf '{"session_id":"smoke"}' | CLAUDE_PROJECT_DIR="$tmp" bash hooks/scripts/stop-check.sh)"
case "$stop_output" in *'"systemMessage"'*) ;; *) echo "stop-check output missing systemMessage" >&2; exit 1;; esac
stop_again="$(printf '{"session_id":"smoke"}' | CLAUDE_PROJECT_DIR="$tmp" bash hooks/scripts/stop-check.sh)"
[ -z "$stop_again" ] || { echo "stop-check did not throttle" >&2; exit 1; }
rm -f "$marker"
echo "hooks: OK"

bash -n hooks/scripts/session-start.sh
bash -n hooks/scripts/stop-check.sh
echo "bash syntax: OK"

echo "all smoke tests passed"
