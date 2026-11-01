---
description: Show the ntfy-approvals topics and the phone subscription link
---

Topics generated for this machine:

!`python3 "${CLAUDE_PLUGIN_ROOT}/scripts/ntfy_approvals.py" control topic`

Tell the user to subscribe to the `phone:` link in the ntfy app, and warn that
both topic names are secrets — anyone who knows them can read the alerts or
send approvals.

If the relay is not running yet, they can start the daemon with
`python3 ntfy_approvals.py control listen` (see the plugin README for the
systemd unit).
