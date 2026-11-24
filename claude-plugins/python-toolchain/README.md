# python-toolchain

Python toolchain guidance for Claude Code: uv for environments, dependencies,
scripts, and tools; ruff for linting and formatting.

Type checking is not part of this plugin. The `pyrefly` plugin owns `.py`/`.pyi`
diagnostics, the `pyrefly check` Stop gate, and the `pyrefly-cli` /
`tensor-shapes` skills.

## Components

- **`uv` skill** — choosing scripts vs projects vs tools, the pip interface,
  Python version pinning, dependency groups, and migrations from pip-tools,
  pipx, pyenv, and Poetry.
- **`ruff` skill** — `check` and `format`, fix ordering (lint before format),
  unsafe fixes, `pyproject.toml` / `ruff.toml` configuration, and migrations
  from Black, Flake8, and isort.

Both skills are vendored from
[astral-sh/agent-plugins](https://github.com/astral-sh/agent-plugins) (MIT) and
edited locally; see [NOTICE](NOTICE).

## Install

The plugin is published from the `dotfiles` marketplace:

```
/plugin install python-toolchain@dotfiles
```

Enable it in `~/.claude/settings.json`. In this dotfiles repo that file comes
from `home/dot_claude/claude-settings.jsonc.tmpl` and already sets
`"python-toolchain@dotfiles": true`, so run `chezmoi apply` after editing the
template, then restart Claude Code.

After editing the skills in this directory, refresh the installed copy with
`claude plugin update python-toolchain@dotfiles`.

## Relationship to the Astral plugin

`astral@astral-sh` ships the same `uv` and `ruff` skills, but it also registers
a `ty` language server for `.py`/`.pyi`. Claude Code uses only the first server
registered for an extension, so enabling it silences Pyrefly diagnostics. Since
Claude Code has no per-component toggle for a plugin's LSP, this plugin exists
to keep the skills while leaving Pyrefly in charge of type diagnostics.
