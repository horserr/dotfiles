---
name: ruff
description: >-
  This skill should be used when the user asks to "lint", "format", "fix lint
  errors", "sort imports", "configure ruff", "select rules", "格式化",
  "检查代码规范", "修复 lint 报错", or when a task edits Python code in a
  project containing a `[tool.ruff]` section, `ruff.toml`, `.ruff.toml`, or a
  `pyproject.toml` that declares ruff. Covers `ruff check`, `ruff format`,
  configuration, and migrations from Black / Flake8 / isort.
---

# ruff

Ruff is an extremely fast Python linter and code formatter. It replaces Flake8,
isort, Black, pyupgrade, autoflake, and dozens of other tools.

## When to use ruff

Use ruff for Python linting and formatting, especially when the project shows:

- A `[tool.ruff]` section in `pyproject.toml`
- A `ruff.toml` or `.ruff.toml` configuration file

Ruff does not type check; Pyrefly owns that (see the `pyrefly:pyrefly-cli`
skill). Do not run mypy, pylint, or flake8 as a substitute.

Avoid unnecessary changes:

- **Don't reformat unformatted code.** If `ruff format --diff` shows changes
  throughout an entire file, the project likely isn't using ruff for
  formatting. Skip formatting so the actual change stays legible.
- **Scope fixes to code being edited.** Use `ruff check --diff <edited files>`
  to preview fixes for the current change. A bare `ruff check --diff` scans the
  whole tree, implies `--fix-only`, and hides diagnostics that have no fix.
  Apply fixes only to files being modified unless the user asks for a broader
  sweep.

## How to invoke ruff

- `uv run ruff ...` — when ruff is a project dependency, to use the pinned version
- `uvx ruff ...` — when ruff is not a project dependency, or for a one-off check
- `ruff ...` — only when ruff is installed globally

## Commands

### Linting

```bash
ruff check .                       # Check all files in the current directory
ruff check path/to/file.py         # Check a specific file
ruff check --fix .                 # Apply fixable violations
ruff check --fix --unsafe-fixes .  # Include unsafe fixes (review changes!)
ruff check --watch .               # Re-lint on change
ruff check --select E,F .          # Only check specific rules
ruff check --ignore E501 .         # Ignore specific rules
ruff check --diff path/to/file.py  # Preview fixes without applying
ruff rule E501                     # Explain a rule
ruff linter                        # List available linters
```

### Formatting

```bash
ruff format .                 # Format all files
ruff format path/to/file.py   # Format a specific file
ruff format --check .         # Report unformatted files (no changes)
ruff format --diff .          # Show the formatting diff
```

`uv format` runs the Ruff formatter; `uv format --check -- <path>` works for a
single file. By default `uv format` picks a Ruff version independently of the
project lockfile. When the project pins ruff, use `uv run ruff format` so the
formatter version matches.

## Configuration

Ruff is configured in `pyproject.toml` or `ruff.toml`:

```toml
# pyproject.toml
[tool.ruff.lint]
extend-select = ["I", "UP"]  # Add import sorting and pyupgrade to the defaults

[tool.ruff.lint.isort]
known-first-party = ["myproject"]

[tool.ruff.format]
quote-style = "double"
```

Keep project-specific ignores narrow, and prefer `per-file-ignores` over
disabling a rule project-wide:

```toml
[tool.ruff.lint.per-file-ignores]
"tests/**" = ["S101"]         # assert is expected in tests
```

## Migrating from other tools

### Black → ruff format

```bash
black .                       → ruff format .
black --check .               → ruff format --check .
black --diff .                → ruff format --diff .
```

### Flake8 → ruff check

```bash
flake8 .                      → ruff check .
flake8 --select E,F .         → ruff check --select E,F .
flake8 --ignore E501 .        → ruff check --ignore E501 .
```

### isort → ruff check

```bash
isort .                       → ruff check --select I --fix .
isort --check .               → ruff check --select I .
isort --diff .                → ruff check --select I --diff .
```

When migrating configuration, translate `[tool.black]` into
`[tool.ruff.format]`, and Flake8 `select`/`ignore`/`per-file-ignores` into the
matching `[tool.ruff.lint]` keys. Remove the old tool's config and
dependencies afterward.

## Common patterns

### Apply lint fixes before formatting

Run `ruff check --fix` before `ruff format`. Lint fixes can change code
structure (e.g. reordering imports), which formatting then cleans up.

```bash
ruff check --fix .
ruff format .
```

### Applying and reviewing unsafe fixes

Ruff's full diagnostic output can show a suggested change even when `--fix`
would leave the code alone. Safe fixes apply with `--fix`; unsafe fixes may
change behavior and require `--unsafe-fixes`. A suggestion marked for manual
review, such as `ERA001` (commented-out code), requires a manual edit.

```bash
ruff check --fix --unsafe-fixes --diff .  # Preview first
ruff check --fix --unsafe-fixes .         # Apply
```

Review changes before applying `--unsafe-fixes`:

- Use `ruff rule <CODE>` to understand why a fix is unsafe
- Verify the fix doesn't violate those assumptions in the local code

## Documentation

For detailed information, read the official documentation:

- https://docs.astral.sh/ruff/

---

Adapted from the `ruff` skill in [astral-sh/agent-plugins](https://github.com/astral-sh/agent-plugins) (MIT). Local edits: pyrefly boundary, configuration and migration guidance added.
