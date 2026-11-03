#!/usr/bin/env bash
# ntfy-approvals — PermissionRequest: alert the phone and wait for a decision.
#
# 1. publish an ntfy notification carrying Allow / Deny action buttons
# 2. wait up to NTFY_APPROVALS_APPROVE_TIMEOUT seconds for the relay to drop
#    ~/.claude/control/<req>.json
# 3. answer the hook, or fall through to the normal permission dialog
#
# NOTE: while this hook waits, Claude Code has not drawn its local permission
# dialog yet. Set NTFY_APPROVALS_APPROVE_TIMEOUT=0 to keep it non-blocking
# when you are sitting at the keyboard.

set -u
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

input=$(cat)
tool=$(jget "$input" tool_name)
command_text=$(jget "$input" command)
[ -n "$command_text" ] || command_text=$(jget "$input" file_path)
proj=$(na_project "$(jget "$input" cwd)")

title="Claude Code"
body=$(na_sanitize "$proj: needs approval: ${tool:-tool}")
na_tmux_hint "Claude Code: $body"

# phone approval disabled -> plain local behaviour
[ "${NTFY_APPROVALS_APPROVE:-1}" = "1" ] || { na_frame "$title" "$body"; exit 0; }

timeout_s=${NTFY_APPROVALS_APPROVE_TIMEOUT:-120}
case "$timeout_s" in ''|*[!0-9]*) timeout_s=120 ;; esac
[ "$timeout_s" -gt 0 ] || { na_frame "$title" "$body"; exit 0; }

na_load_config

req="$(date +%s)-$(na_rand_hex 4)"
case "$req" in ''|*[!A-Za-z0-9._-]*) req="r$(date +%s)" ;; esac

ctl_url="$NTFY_BASE/$CONTROL_TOPIC"
auth_json=""
if [ -n "${NTFY_TOKEN:-}" ]; then
  auth_json=$(printf ',"headers":{"Authorization":"Bearer %s"}' "$NTFY_TOKEN")
fi

actions=$(printf '[{"action":"http","label":"\xe2\x9c\x85 Allow","url":"%s","method":"POST","body":"allow %s","clear":true%s},{"action":"http","label":"\xe2\x9b\x94 Deny","url":"%s","method":"POST","body":"deny %s","clear":true%s}]' \
  "$ctl_url" "$req" "$auth_json" "$ctl_url" "$req" "$auth_json")

detail=$(na_sanitize "${command_text:-$tool}")
msg="$proj: needs approval · ${tool:-tool}"
[ -n "$detail" ] && msg="$msg · $detail"
msg=$(na_sanitize "$msg")

na_log "approve req=$req tool=$tool"

if ! na_publish "$NOTIFY_TOPIC" "$msg" "$actions" 5; then
  na_log "approve: publish failed, not waiting (req=$req)"
  na_frame "$title" "$body"
  exit 0
fi

dir=$(na_control_dir)
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
na_log "approve req=$req decision=${decision:-timeout}"

case "$decision" in
  allow)
    na_frame "$title" "$body" ',"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"allow"}}'
    ;;
  deny)
    na_frame "$title" "$body" ',"hookSpecificOutput":{"hookEventName":"PermissionRequest","decision":{"behavior":"deny","message":"Denied from phone"}}'
    ;;
  *)
    # no decision: normal permission flow (local dialog) applies
    na_frame "$title" "$body"
    ;;
esac

exit 0
