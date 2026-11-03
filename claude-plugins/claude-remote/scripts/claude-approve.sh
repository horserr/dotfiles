#!/usr/bin/env bash
# claude-remote — PermissionRequest: alert the phone and wait for a decision.
#
# 1. always ring the local terminal
# 2. publish an ntfy notification carrying Allow / Deny action buttons
# 3. wait up to CLAUDE_APPROVE_TIMEOUT seconds for the relay to drop
#    ~/.claude/control/<req>.json
# 4. answer the hook, or fall through to the normal permission dialog
#
# NOTE: while this hook waits, Claude Code has not drawn its local permission
# dialog yet. Set CLAUDE_APPROVE_TIMEOUT=0 to keep the hook non-blocking when
# you are sitting at the keyboard.

set -u
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

input=$(cat)
tool=$(jget "$input" tool_name)
command_text=$(jget "$input" command)
[ -n "$command_text" ] || command_text=$(jget "$input" file_path)
proj=$(cr_project "$(jget "$input" cwd)")

title="Claude Code"
body=$(cr_sanitize "$proj: needs approval: ${tool:-tool}")
cr_tmux_hint "Claude Code: $body"

[ "${CLAUDE_NOTIFY_PERMISSION:-1}" = "1" ] || { cr_frame "$title" "$body"; exit 0; }

timeout_s=${CLAUDE_APPROVE_TIMEOUT:-120}
case "$timeout_s" in ''|*[!0-9]*) timeout_s=120 ;; esac
[ "$timeout_s" -gt 0 ] || { cr_frame "$title" "$body"; exit 0; }

cr_load_config

req="$(date +%s)-$(cr_rand_hex 4)"
case "$req" in ''|*[!A-Za-z0-9._-]*) req="r$(date +%s)" ;; esac

ctl_url="$NTFY_BASE/$CONTROL_TOPIC"
auth_json=""
if [ -n "${NTFY_TOKEN:-}" ]; then
  auth_json=$(printf ',"headers":{"Authorization":"Bearer %s"}' "$NTFY_TOKEN")
fi

actions=$(printf '[{"action":"http","label":"\xe2\x9c\x85 Allow","url":"%s","method":"POST","body":"allow %s","clear":true%s},{"action":"http","label":"\xe2\x9b\x94 Deny","url":"%s","method":"POST","body":"deny %s","clear":true%s}]' \
  "$ctl_url" "$req" "$auth_json" "$ctl_url" "$req" "$auth_json")

detail=$(cr_sanitize "${command_text:-$tool}")
msg="$proj: needs approval · ${tool:-tool}"
[ -n "$detail" ] && msg="$msg · $detail"
msg=$(cr_sanitize "$msg")

cr_log "approve req=$req tool=$tool"

if ! cr_publish "$NOTIFY_TOPIC" "$msg" "$actions" 5; then
  cr_log "approve: publish failed, not waiting (req=$req)"
  cr_frame "$title" "$body"
  exit 0
fi

dir=$(cr_control_dir)
mkdir -p "$dir" 2>/dev/null || true
file="$dir/$req.json"
deadline=$(( $(date +%s) + timeout_s ))
decision=""

while [ "$(date +%s)" -lt "$deadline" ]; do
  if [ -f "$file" ]; then
    content=$(cat "$file" 2>/dev/null || true)
    case "$content" in
      *'"allow"'*) decision=allow ;;
      *'"deny"'*)  decision=deny ;;
    esac
    [ -n "$decision" ] && break
  fi
  sleep 1
done

rm -f "$file" 2>/dev/null || true
cr_log "approve req=$req decision=${decision:-timeout}"

case "$decision" in
  allow)
    cr_frame "$title" "$body" ',"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}'
    ;;
  deny)
    cr_frame "$title" "$body" ',"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"Denied from phone"}}'
    ;;
  *)
    # no decision: normal permission flow (local dialog) applies
    cr_frame "$title" "$body"
    ;;
esac

exit 0
