#!/usr/bin/env bash
# claude-remote — turn / idle notifier.
#
# Fired by Notification, Stop and StopFailure hooks.
# Emits terminal escape sequences through Claude Code's `terminalSequence`
# field (works locally, over SSH, inside tmux) and optionally mirrors the
# alert to ntfy so it reaches the phone.

set -u
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

input=$(cat)
event=$(jget "$input" hook_event_name)
ntype=$(jget "$input" notification_type)
message=$(jget "$input" message)
proj=$(cr_project "$(jget "$input" cwd)")

case "$event" in
  Notification)
    case "$ntype" in
      permission_prompt)
        body="still waiting for approval: $(jget "$input" tool_name)"
        [ -n "$message" ] && body=$message
        ;;
      idle_prompt)
        body="finished, waiting for you"
        ;;
      elicitation_dialog|elicitation_url_dialog)
        body="MCP server needs your input"
        ;;
      agent_needs_input)
        body="background agent needs your input"
        ;;
      agent_completed)
        body="background agent finished"
        ;;
      *)
        exit 0
        ;;
    esac
    ;;
  Stop)
    [ "${CLAUDE_NOTIFY_ON_DONE:-0}" = "1" ] || exit 0
    body="turn finished"
    ;;
  StopFailure)
    body="API error: $(jget "$input" error)"
    ;;
  *)
    exit 0
    ;;
esac

title="Claude Code"
body=$(cr_sanitize "$proj: $body")
cr_log "notify event=$event type=$ntype body=$body"

if [ "${CLAUDE_NOTIFY_PUSH:-1}" = "1" ]; then
  cr_load_config
  # never block the turn on the network; the hook's own stdout is already
  # consumed below, so this child must not inherit it.
  ( cr_publish "$NOTIFY_TOPIC" "$body" && cr_log "pushed -> $NOTIFY_TOPIC" ) \
    >/dev/null 2>&1 &
fi

cr_tmux_hint "Claude Code: $body"
cr_frame "$title" "$body"
exit 0
