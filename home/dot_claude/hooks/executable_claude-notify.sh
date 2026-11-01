#!/usr/bin/env bash
# ~/.claude/hooks/claude-notify.sh
#
# Claude Code attention notifier.
#
# Fired by the PermissionRequest / Notification / Stop / StopFailure hooks.
# Instead of writing to /dev/tty (unavailable to hooks, and impossible over
# SSH), it returns Claude Code's `terminalSequence` JSON field, which Claude
# Code itself writes to its terminal. That works locally, over SSH, and inside
# tmux / screen.
#
# Emitted sequences:
#   BEL      -> terminal bell (Windows Terminal taskbar flash + bellSound)
#   OSC 0    -> window title (fallback for terminals without OSC notify)
#   OSC 9    -> iTerm2 / WezTerm / Windows Terminal / ConEmu notifications
#   OSC 777  -> Ghostty / Warp / urxvt notifications
#   OSC 99   -> Kitty notifications
#
# Optional extras (set in your shell env or in settings.json "env"):
#   CLAUDE_NOTIFY_NTFY_URL=https://ntfy.sh/<your-topic>   push to phone, works
#                                                         even when tmux is detached
#   CLAUDE_NOTIFY_ON_DONE=1        also notify when a turn finishes (Stop)
#   CLAUDE_NOTIFY_PERMISSION=0     mute approval-prompt alerts
#   CLAUDE_NOTIFY_DEBUG=1          log the parsed event to ~/.claude/notify.log

set -u

input=$(cat)

jval() {
  printf '%s' "$input" \
    | tr -d '\r\n' \
    | sed -n 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"\([^"\\]*\)".*/\1/p' \
    | head -n 1
}

event=$(jval hook_event_name)
tool=$(jval tool_name)
ntype=$(jval notification_type)
message=$(jval message)
cwd=$(jval cwd)

# project name: last path segment, works with both / and \
proj=$(printf '%s' "${cwd:-$PWD}" | sed 's#/*$##; s#.*[\\/]##')
[ -n "$proj" ] || proj="claude"

case "$event" in
  PermissionRequest)
    [ "${CLAUDE_NOTIFY_PERMISSION:-1}" = "1" ] || exit 0
    title="Claude Code"
    body="needs approval: ${tool:-tool}"
    ;;
  Notification)
    case "$ntype" in
      permission_prompt)
        title="Claude Code"
        body="still waiting for approval: ${tool:-tool}"
        ;;
      idle_prompt)
        title="Claude Code"
        body="finished, waiting for you"
        ;;
      elicitation_dialog|elicitation_url_dialog)
        title="Claude Code"
        body="MCP server needs your input"
        ;;
      agent_needs_input)
        title="Claude Code"
        body="background agent needs your input"
        ;;
      agent_completed)
        title="Claude Code"
        body="background agent finished"
        ;;
      *)
        exit 0
        ;;
    esac
    # prefer the human-readable text Claude Code already composed
    [ -n "$message" ] && body=$message
    ;;
  Stop)
    [ "${CLAUDE_NOTIFY_ON_DONE:-0}" = "1" ] || exit 0
    title="Claude Code"
    body="turn finished"
    ;;
  StopFailure)
    title="Claude Code"
    body="API error: $(jval error)"
    ;;
  *)
    exit 0
    ;;
esac

body="${proj}: ${body}"
# strip characters that would break the JSON payload / the escape sequence
body=$(printf '%s' "$body" | LC_ALL=C tr -d '[:cntrl:]"\\')
body=${body:0:160}
title=${title:0:60}

if [ "${CLAUDE_NOTIFY_DEBUG:-0}" = "1" ]; then
  printf '%s\t%s\t%s\t%s\n' "$(date '+%F %T')" "$event" "$ntype" "$body" \
    >>"$HOME/.claude/notify.log" 2>/dev/null || true
fi

# --- optional push notification (survives a detached tmux session) --------
if [ -n "${CLAUDE_NOTIFY_NTFY_URL:-}" ] && command -v curl >/dev/null 2>&1; then
  ( curl -fsS -m 5 -H "Title: $title" -H "Tags: bell" \
      -d "$body" "$CLAUDE_NOTIFY_NTFY_URL" >/dev/null 2>&1 & ) || true
fi

# --- tmux status-line hint (works even if the outer terminal drops OSC) ---
if [ -n "${TMUX:-}" ] && command -v tmux >/dev/null 2>&1; then
  tmux display-message -d 8000 "$title: $body" >/dev/null 2>&1 || true
fi

# --- desktop notification, emitted by Claude Code itself -----------------
printf '{"terminalSequence":"\\u0007\\u001b]0;%s\\u0007\\u001b]9;%s\\u0007\\u001b]777;notify;%s;%s\\u0007\\u001b]99;i=claude:d=1;%s\\u0007"}\n' \
  "$title: $body" "$body" "$title" "$body" "$title: $body"

exit 0
