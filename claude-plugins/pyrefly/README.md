# pyrefly

Pyrefly type checking for Claude Code.

## Components

- **LSP server** — runs `pyrefly lsp` for `.py` and `.pyi` files. Claude Code
  pushes new diagnostics after each edit, and the `LSP` tool can navigate
  Python code.
- **Stop hook** — after the session edits a Python file, runs `pyrefly check`
  at the project root and blocks completion while type errors remain. The gate
  disarms after three consecutive attempts so an unfixable environment cannot
  trap the session.
- **`pyrefly-cli` skill** — core check/fix workflow plus reference files for
  configuration, `pyrefly infer`, type coverage, and CLI queries.
- **`tensor-shapes` skill** — tensor and array shape annotations
  (`Tensor[[...]]`, `Int[X]`), stub-package setup, jaxtyping interop, and the
  workflow for porting a PyTorch model.

## Requirements

`pyrefly` must be on the `PATH` that starts Claude Code:

```bash
uv tool install pyrefly
# or: pip install pyrefly
pyrefly --version
```

## Install

The plugin is published from the `dotfiles` marketplace:

```
/plugin install pyrefly@dotfiles
```

Enable it in `~/.claude/settings.json`, then restart Claude Code.

Disable any other plugin that registers a Python language server (for example
`astral@astral-sh`, which ships a `ty` server). Claude Code uses only the first
server registered for an extension, so a competing server silently wins and
Pyrefly diagnostics never appear.

## Behavior and opt-out

The Stop hook only runs after a `.py` or `.pyi` file was edited in the session.
Set `PYREFLY_AGENT_HOOKS=0` to disable both hooks.

`pyrefly check` uses the `basic` preset when the project has no `pyrefly.toml`
or `[tool.pyrefly]` section. Run `pyrefly init` in a project to enable full
checking.

## Tensor shapes

Tensor shape checking requires Pyrefly 1.5.0 or newer and the matching 1.5.0
stub package (`pyrefly-torch-stubs`, `pyrefly-numpy-stubs`,
`jax-pyrefly-stubs`, or `pyrefly-einops-stubs`) installed in the project
environment that Pyrefly uses. The plugin's LSP and Stop hook run the `pyrefly`
binary on `PATH`, so upgrade that binary to 1.5.0+ for shape diagnostics. No
plugin configuration change is needed.
