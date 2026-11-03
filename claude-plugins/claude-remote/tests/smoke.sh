#!/usr/bin/env bash
# claude-remote smoke tests — no network required.
# usage: bash tests/smoke.sh

set -u
HERE=$(cd "$(dirname "$0")/.." && pwd)
S="$HERE/scripts"
tmp=$(mktemp -d)

export CLAUDE_REMOTE_STATE_DIR="$tmp/state"
export CLAUDE_NOTIFY_PUSH=0
export CLAUDE_REMOTE_DEBUG=1
mkdir -p "$tmp/state" "$tmp/bin"

# stub curl so approvals "publish" without touching the network
printf '#!/bin/sh\nexit 0\n' >"$tmp/bin/curl"
chmod +x "$tmp/bin/curl"

fail=0
ok()  { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fail=1; }
one_line() { printf '%s' "$1" | grep -c '' | tr -d ' '; }
valid_json() {
  printf '%s' "$1" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{JSON.parse(s)}catch(e){process.exit(1)}})' 2>/dev/null
}

# 1 — notify: exactly one valid JSON object carrying terminalSequence
out=$(printf '%s' '{"hook_event_name":"Notification","notification_type":"idle_prompt","cwd":"/srv/app"}' | bash "$S/claude-notify.sh")
[ "$(one_line "$out")" = "1" ] && ok "notify: single line" || bad "notify: multiline output"
printf '%s' "$out" | grep -q '"terminalSequence"' && ok "notify: terminalSequence present" || bad "notify: missing terminalSequence"
valid_json "$out" && ok "notify: valid JSON" || bad "notify: invalid JSON"

# 2 — Stop is silent unless CLAUDE_NOTIFY_ON_DONE=1
out=$(printf '%s' '{"hook_event_name":"Stop","cwd":"/srv/app"}' | bash "$S/claude-notify.sh")
[ -z "$out" ] && ok "stop: silent by default" || bad "stop: emitted output"

out=$(printf '%s' '{"hook_event_name":"Stop","cwd":"/srv/app"}' | CLAUDE_NOTIFY_ON_DONE=1 bash "$S/claude-notify.sh")
printf '%s' "$out" | grep -q '"terminalSequence"' && ok "stop: opt-in works" || bad "stop: opt-in broken"

# 3 — topic pair is generated once and stays stable
a=$(bash "$S/claude-control.sh" topic | sed -n 's/^notify  : //p')
b=$(bash "$S/claude-control.sh" topic | sed -n 's/^notify  : //p')
if [ -n "$a" ] && [ "$a" = "$b" ]; then ok "topics stable: ${a##*/}"; else bad "topics unstable ($a / $b)"; fi
mode=$(stat -c %a "$tmp/state/claude-remote.env" 2>/dev/null || stat -f %Lp "$tmp/state/claude-remote.env" 2>/dev/null)
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    # Windows ACLs win over POSIX mode bits; nothing to assert here
    ok "config file mode: skipped on Windows (ACLs, got ${mode:-n/a})"
    ;;
  *)
    [ "$mode" = "600" ] && ok "config file mode 600" || bad "config file mode ${mode:-unknown}"
    ;;
esac

# 4 — approve: phone says allow
printf '%s' '{"hook_event_name":"PermissionRequest","tool_name":"Bash","command":"rm -rf node_modules","cwd":"/srv/app"}' >"$tmp/payload.json"
(
  for _ in $(seq 1 100); do
    req=$(sed -n 's/.*approve req=\([A-Za-z0-9._-]*\).*/\1/p' "$tmp/state/claude-remote.log" 2>/dev/null | head -n 1)
    if [ -n "$req" ]; then
      mkdir -p "$tmp/state/control"
      printf '{"action":"allow"}\n' >"$tmp/state/control/$req.json"
      break
    fi
    sleep 0.2
  done
) &
watcher=$!
out=$(PATH="$tmp/bin:$PATH" CLAUDE_APPROVE_TIMEOUT=15 bash "$S/claude-approve.sh" <"$tmp/payload.json")
wait $watcher 2>/dev/null
printf '%s' "$out" | grep -q '"behavior":"allow"' && ok "approve: allow decision" || bad "approve: allow missing ($out)"
[ "$(one_line "$out")" = "1" ] && ok "approve: single line" || bad "approve: multiline output"
valid_json "$out" && ok "approve: valid JSON" || bad "approve: invalid JSON"
leftover=$(find "$tmp/state/control" -name '*.json' 2>/dev/null | wc -l | tr -d ' ')
[ "$leftover" = "0" ] && ok "approve: decision file consumed" || bad "approve: $leftover decision file(s) left behind"

# 5 — approve: nobody answers -> no decision, still one JSON object
out=$(PATH="$tmp/bin:$PATH" CLAUDE_APPROVE_TIMEOUT=2 bash "$S/claude-approve.sh" <"$tmp/payload.json")
printf '%s' "$out" | grep -q 'behavior' && bad "approve: unexpected decision on timeout" || ok "approve: timeout falls through"
valid_json "$out" && ok "approve: timeout JSON valid" || bad "approve: timeout JSON invalid"

# 6 — approve: blocking disabled
out=$(PATH="$tmp/bin:$PATH" CLAUDE_APPROVE_TIMEOUT=0 bash "$S/claude-approve.sh" <"$tmp/payload.json")
printf '%s' "$out" | grep -q '"terminalSequence"' && ok "approve: timeout=0 non-blocking" || bad "approve: timeout=0 broken"

rm -rf "$tmp"
printf '\n'
if [ "$fail" = "0" ]; then echo "all checks passed"; else echo "some checks failed"; fi
exit "$fail"
