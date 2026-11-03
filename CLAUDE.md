# CLAUDE.md

Chezmoi-managed cross-platform dotfiles. Chezmoi source dir: `~/.config/.dotfiles`; source state lives in `home/` (e.g. `home/dot_config/...` → `~/.config/...`, `home/dot_foo.tmpl` → `~/.foo`). Setup steps: [README.md](README.md).

## Commands

| Task | Command |
| --- | --- |
| Apply changes | `chezmoi apply` (non-interactive: `chezmoi apply --force`) |
| Apply without externals | `chezmoi apply --exclude=externals` |
| Render a template | `chezmoi execute-template -f <file.tmpl>` |
| Inspect | `chezmoi status`, `chezmoi diff`, `chezmoi doctor` |
| Edit config | `chezmoi edit-config` |

Prefer the matching VS Code tasks (`chezmoi: ...`) — see `.vscode/tasks.json` and `home/dot_config/vscode/tasks.json`. Task labels follow `tool: Action`; renaming one also requires updating `home/dot_config/vscode/settings/vspace/k.jsonc`.

## Conventions

- Template files end in `.tmpl`; naming prefixes follow chezmoi source state attributes (`dot_`, `private_`, `executable_`, `run_onchange_`, `symlink_`).
- Platform/data conditionals use `.chezmoi.os`, `.chezmoi.arch`, and data from `home/.chezmoi.toml.tmpl` (e.g. `isPersonal`).
- Cross-file helpers live in `home/.chezmoitemplates/`; externals in `home/.chezmoiexternals/`.
- Area-specific rules are in `.github/instructions/` — respect their `applyTo` patterns before editing matching files.

## Pitfalls

- **`chezmoi apply` usually waits for terminal input** (scripts, external refreshes, overwrite/confirm prompts). Non-interactive or automated runs will hang — pass `--force` when it must run unattended, e.g. `chezmoi apply --force`. Combine with `--exclude=externals` to skip network downloads.
