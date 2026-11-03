#!/usr/bin/env bash
# ntfy-approvals — control CLI / relay daemon.
#
#   control.sh topic    show topics + phone subscription link (+ QR)
#   control.sh listen   relay: control topic -> decisions / tmux input
#   control.sh send TXT publish a message to the control topic (testing)
#   control.sh status   show state, topics and relay status
#   control.sh init     create the random topic pair now

set -u
. "$(cd "$(dirname "$0")" && pwd)/lib.sh"

usage() {
  cat <<EOF
$NA_NAME $NA_VERSION

usage: $(basename "$0") <command>

  topic     print topics and the phone subscription link (QR if qrencode)
  listen    run the relay daemon (subscribes to the control topic)
  send TXT  publish TXT to the control topic
  status    print state, topics and relay status
  init      generate the random topic pair if missing
EOF
}

cmd_topic() {
  local host
  na_load_config
  host=${NTFY_BASE#*://}
  printf 'notify  : %s/%s\n' "$NTFY_BASE" "$NOTIFY_TOPIC"
  printf 'control : %s/%s\n' "$NTFY_BASE" "$CONTROL_TOPIC"
  printf 'phone   : ntfy://%s/%s\n' "$host" "$NOTIFY_TOPIC"
  if command -v qrencode >/dev/null 2>&1; then
    printf '\n'
    qrencode -t ANSIUTF8 "ntfy://$host/$NOTIFY_TOPIC" 2>/dev/null || true
  fi
}

cmd_status() {
  local relay="stopped"
  na_load_config
  if command -v pgrep >/dev/null 2>&1 && pgrep -f "control.sh listen" >/dev/null 2>&1; then
    relay="running"
  fi
  printf 'state   : %s\n' "$(na_state_dir)"
  printf 'notify  : %s\n' "$NOTIFY_TOPIC"
  printf 'control : %s\n' "$CONTROL_TOPIC"
  printf 'base    : %s\n' "$NTFY_BASE"
  printf 'relay   : %s\n' "$relay"
  printf 'pending : %s decision file(s)\n' \
    "$(find "$(na_control_dir)" -name '*.json' 2>/dev/null | wc -l | tr -d ' ')"
}

cmd_send() {
  [ "$#" -gt 0 ] || { echo "usage: $(basename "$0") send <text>" >&2; exit 2; }
  na_load_config
  na_publish "$CONTROL_TOPIC" "$*" || { echo "publish failed" >&2; exit 1; }
  printf 'sent to %s/%s\n' "$NTFY_BASE" "$CONTROL_TOPIC"
}

cmd_init() {
  na_load_config
  cmd_topic
}

# --- relay internals ------------------------------------------------------
last_id=""

inject_text() {
  local text=$1 target=${NTFY_APPROVALS_TMUX_TARGET:-}
  command -v tmux >/dev/null 2>&1 || return 0
  if [ -z "$target" ] && [ -n "${TMUX:-}" ]; then
    target=$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null || true)
  fi
  [ -n "$target" ] || { na_log "tmux: no target, dropping: $text"; return 0; }
  tmux send-keys -t "$target" -l -- "$text" >/dev/null 2>&1 || return 0
  tmux send-keys -t "$target" Enter >/dev/null 2>&1 || true
  na_log "tmux: injected into $target"
}

handle_payload() {
  local json ev id msg action req dir
  json=${1# }
  ev=$(jget "$json" event)
  [ "$ev" = "message" ] || return 0
  id=$(jget "$json" id)
  [ -n "$id" ] && last_id=$id

  msg=$(jget "$json" message)
  [ -n "$msg" ] || return 0

  case "$msg" in
    allow\ *|deny\ *)
      action=${msg%% *}
      req=${msg#* }
      case "$req" in
        ''|*[!A-Za-z0-9._-]*) na_log "relay: bad req '$req'"; return 0 ;;
      esac
      dir=$(na_control_dir)
      mkdir -p "$dir" 2>/dev/null || true
      ( umask 077; printf '{"action":"%s"}\n' "$action" >"$dir/$req.json" ) 2>/dev/null || true
      na_log "relay: $action -> $dir/$req.json"
      ;;
    *)
      if [ "${NTFY_APPROVALS_TMUX:-0}" = "1" ]; then
        inject_text "$msg"
      else
        na_log "relay: ignored text (NTFY_APPROVALS_TMUX=0): $msg"
      fi
      ;;
  esac
}

cmd_listen() {
  local since url
  local -a auth=()
  na_load_config
  [ -n "${NTFY_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $NTFY_TOKEN")
  since=$(date +%s)
  printf 'relay: %s/%s (ctrl-c to stop)\n' "$NTFY_BASE" "$CONTROL_TOPIC"
  trap 'printf "\n"; exit 0' INT TERM
  while :; do
    url="$NTFY_BASE/$CONTROL_TOPIC/sse?since=${last_id:-$since}"
    while IFS= read -r line; do
      case "$line" in
        data:*) handle_payload "${line#data:}" ;;
      esac
    done < <(curl -sN -m 3600 ${auth[@]+"${auth[@]}"} "$url" 2>/dev/null)
    sleep 3
  done
}

case "${1:-}" in
  topic)  cmd_topic ;;
  listen) cmd_listen ;;
  send)   shift; cmd_send "$@" ;;
  status) cmd_status ;;
  init)   cmd_init ;;
  *)      usage ;;
esac
