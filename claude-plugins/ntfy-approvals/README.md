# ntfy-approvals

Phone notifications **and phone approvals** for Claude Code, over [ntfy](https://ntfy.sh).
No Anthropic account, no extra server: the ntfy topic is the channel.

- Every attention event pings your terminal (BEL + OSC 9/99/777, so it works
  through SSH and tmux) and your phone.
- Permission prompts arrive on the phone with **Allow / Deny** buttons.
- Topics are generated randomly on first use; nothing to configure.
- The phone link is drawn as a **scannable QR code** in the terminal — pure
  Python, no `qrencode`/`Pillow`, and the topic never leaves the machine.
- Pure Python 3 standard library — no `jq`, no `curl`, nothing to install.

## Install

Local checkout / marketplace:

```
/plugin marketplace add ~/.config/.dotfiles/claude-plugins
/plugin install ntfy-approvals@dotfiles
```

Remote box without the dotfiles:

```
/plugin marketplace add <owner>/<repo>
/plugin install ntfy-approvals@<marketplace>
```

## Pair your phone

```
/ntfy-approvals:topic
```

Or from a shell:

```bash
python3 ~/.claude/plugins/*/ntfy-approvals/scripts/ntfy_approvals.py control topic
```

That prints the topics plus a QR code for the `phone:` link — scan it with the
ntfy app and you are subscribed. Set `NTFY_APPROVALS_QR=0` to print only text
(useful when the output goes into a log or a chat transcript).

## Run the relay

The relay turns a phone tap into a decision file. It must be running for
approvals to work — otherwise the hook waits out the timeout and falls back to
the local dialog.

```bash
python3 .../scripts/ntfy_approvals.py control listen
```

Linux systemd user unit:

```ini
[Unit]
Description=ntfy-approvals relay

[Service]
ExecStart=/usr/bin/python3 %h/.claude/plugins/repos/dotfiles/ntfy-approvals/scripts/ntfy_approvals.py control listen
Restart=always

[Install]
WantedBy=default.target
```

Adjust the path to wherever the plugin was installed.

## Configuration

All optional, read from the environment (put them in `~/.claude/settings.json`
`env` or your shell profile):

| Variable                         | Default           | Meaning                                          |
| -------------------------------- | ----------------- | ------------------------------------------------ |
| `NTFY_APPROVALS_BASE`            | `https://ntfy.sh` | Self-hosted ntfy base URL                        |
| `NTFY_APPROVALS_TOKEN`           | –                 | Bearer token for protected topics                |
| `NTFY_APPROVALS_PUSH`            | `1`               | `0` disables outbound ntfy, terminal alerts stay |
| `NTFY_APPROVALS_APPROVE`         | `1`               | `0` disables the Allow/Deny flow                 |
| `NTFY_APPROVALS_APPROVE_TIMEOUT` | `120`             | Seconds the hook waits; `0` = never block        |
| `NTFY_APPROVALS_ON_DONE`         | `0`               | `1` also notifies when a turn ends               |
| `NTFY_APPROVALS_TMUX`            | `0`               | `1` injects free-text replies into tmux          |
| `NTFY_APPROVALS_TMUX_TARGET`     | current pane      | tmux target for free-text replies                |
| `NTFY_APPROVALS_DEBUG`           | `0`               | `1` logs to `~/.claude/ntfy-approvals.log`       |
| `NTFY_APPROVALS_QR`              | `1`               | `0` prints the link without the QR code          |
| `NTFY_APPROVALS_QR_COLOR`        | `auto`            | Force ANSI colors on/off; `auto` = only on a TTY |
| `NTFY_APPROVALS_STATE_DIR`       | `~/.claude`       | Where topics/decisions are stored                |

### Trade-off on blocking

`PermissionRequest` runs **before** Claude Code draws its local dialog. Waiting
for the phone therefore delays the local prompt by up to
`NTFY_APPROVALS_APPROVE_TIMEOUT` seconds. Set it to `0` when you are at the
keyboard and only want notifications.

### Free-text replies (opt-in)

With `NTFY_APPROVALS_TMUX=1`, any message published to the **control** topic
that is not `allow <id>` / `deny <id>` is typed into your tmux pane. That is
equivalent to running commands as you — only enable it on a control topic you
treat as a password.

## Tests

```bash
python3 tests/smoke.py -v
```

The suite starts a local HTTP server in place of ntfy, so it needs no network.

Two dev-only checks exercise the QR encoder (`scripts/qrgen.py`); they need
throwaway dependencies via `uv` and are not part of the plugin runtime:

```bash
# byte-identical matrices vs. an independent encoder (160 version/level/mask combos)
uv run --with segno python3 tests/crosscheck_segno.py

# real decoding via OpenCV, i.e. proof the symbols scan
uv run --with opencv-python-headless --with pillow python3 tests/decode_check.py
```

## Requirements

- `python3` (3.9+) on `PATH`. The hook wrapper picks `python3` and falls back
  to `python`. Nothing outside the standard library is used.
- A POSIX shell for the hook command itself (Git Bash on Windows).

Networking uses `http.client` rather than `urllib.request`: urllib's header
fingerprint gets reset by some TLS middleboxes even when `curl` works fine.

## Security

`~/.claude/ntfy-approvals.env` holds the two topic names, which act as
passwords. The file is created with mode 600 on POSIX systems (Windows relies
on profile ACLs). Anyone who learns the control topic can approve tool calls.
