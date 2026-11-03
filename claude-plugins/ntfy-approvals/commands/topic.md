---
description: Show the ntfy-approvals topics and the phone subscription link
---

Topics generated for this machine:

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/control.sh" topic`

Tell the user to subscribe to the `phone:` link in the ntfy app, and warn that
both topic names are secrets — anyone who knows them can read the alerts or
send approvals.

If the relay is not running yet, they can start the daemon with
`control.sh listen` (see the plugin README for the systemd unit).
