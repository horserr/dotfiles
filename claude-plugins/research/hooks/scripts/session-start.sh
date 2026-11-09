#!/usr/bin/env bash
# SessionStart hook: inject a compact snapshot of the project's research memory.
# Silent when the project has no research/ directory.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-$PWD}"
mem="$root/research"

[ -d "$mem" ] || exit 0
[ -f "$mem/00_overview.md" ] || exit 0

section() {
  local label="$1" file="$2" limit="${3:-40}"
  [ -f "$file" ] || return 0
  echo "### $label"
  sed -n "1,${limit}p" "$file"
  echo
}

echo "<research-memory>"
echo "## Research memory snapshot"
echo
echo "Project memory: \`research/\`"
echo

section "Overview" "$mem/00_overview.md" 80
section "Open questions" "$mem/01_research_questions/unresolved.md" 40
section "Hypotheses" "$mem/01_research_questions/hypotheses.md" 40
section "Research gaps" "$mem/06_open_problems/research_gaps.md" 40

csv="$mem/02_literature/paper_database.csv"
if [ -f "$csv" ]; then
  rows=$(wc -l < "$csv" 2>/dev/null || echo 0)
  rows=$((rows > 0 ? rows - 1 : 0))
  echo "### Literature database"
  echo "- Papers recorded: $rows"
  echo
fi

echo "Use these records before re-deriving context. Append, do not overwrite."
echo "</research-memory>"
