---
name: uv
description: >-
  This skill should be used when the user asks to "install a dependency",
  "add a package", "create a virtual environment", "set up a Python project",
  "run a Python script", "pin a Python version", "migrate from pip / poetry /
  pip-tools", "管理虚拟环境", "安装依赖", "新建 Python 项目", or when a task
  involves uv, `uv.lock`, `pyproject.toml`, `requirements.txt`, `uvx`, or
  running Python code. Covers scripts, projects, tools, the pip interface, and
  migrations from other toolchains.
---

# uv

uv is an extremely fast Python package and project manager. It replaces pip,
pip-tools, pipx, pyenv, virtualenv, poetry, etc.

## Choosing the right workflow

### Scripts

**Use when:** running single Python files and standalone scripts.

```bash
uv run script.py                      # Run a script
uv run --with requests script.py      # Run with additional packages
uv add --script script.py requests    # Add dependencies inline to the script
```

### Projects

**Use when:** there is a `pyproject.toml` or `uv.lock`, and the project is not
managed by another tool. Keep the existing workflow in Poetry (`poetry.lock`)
and PDM (`pdm.lock`) projects; migrate only when asked.

```bash
uv init                   # Create a new project
uv add requests           # Add dependency
uv remove requests        # Remove dependency
uv sync                   # Sync the environment and update the lockfile if needed
uv sync --locked          # Require an up-to-date lockfile
uv run <command>          # Run commands in the project environment
uv run python -c ""       # Run Python in the project environment
uv run -p 3.12 <command>  # Run with a specific Python version
```

### Tools

Use `uv run` for tools declared in the project, such as `uv run pytest` or
`uv run ruff check .`. This uses the project's locked tool versions and makes
its dependencies available to the command. Use `uvx` for standalone tools that
run in an isolated environment.

```bash
uvx <tool> <args>            # Run a tool in an isolated environment
uvx <tool>@<version> <args>  # Run a specific version of a tool
```

`uvx` runs tools from PyPI by package name. Only run well-known tools this way.
Install tools globally with `uv tool install` only when the user asks for a
persistent command.

### Python versions

```bash
uv python install 3.12       # Install an interpreter
uv python list --only-installed
uv python pin 3.12           # Write .python-version for the project
uv python install 3.12 --default
```

### Pip interface

**Use when:** a legacy workflow with `requirements.txt`, no `uv.lock`, and no
`pyproject.toml`.

```bash
uv venv
uv pip install -r requirements.txt
uv pip compile requirements.in -o requirements.txt
uv pip sync requirements.txt

# Platform-independent resolution
uv pip compile --universal requirements.in -o requirements.txt
```

Prefer `uv init` for new projects. Do not introduce new `requirements.txt`
files.

## Type checking

Type checking uses Pyrefly, not `uv check` / `ty`. Run `pyrefly check` from the
project root, and see the `pyrefly:pyrefly-cli` skill for configuration,
suppressions, and the fix loop.

## Migrating from other tools

### pyenv → uv python

```bash
pyenv install 3.12       → uv python install 3.12
pyenv versions           → uv python list --only-installed
pyenv local 3.12         → uv python pin 3.12
pyenv global 3.12        → uv python install 3.12 --default
```

### pipx → uvx

```bash
pipx run ruff            → uvx ruff
pipx install ruff        → uv tool install ruff
pipx upgrade ruff        → uv tool upgrade ruff
pipx list                → uv tool list
```

### pip and pip-tools → uv pip

```bash
pip install package      → uv pip install package
pip install -r req.txt   → uv pip install -r req.txt
pip freeze               → uv pip freeze
pip-compile req.in       → uv pip compile req.in
pip-sync req.txt         → uv pip sync req.txt
virtualenv .venv         → uv venv
```

### Poetry → uv

For a `poetry.lock` project, keep the existing layout until the user asks to
migrate. When they do ask:

1. Read `pyproject.toml` and translate `[tool.poetry]` metadata into
   `[project]` (name, version, description, requires-python, dependencies).
2. Move dev dependencies into a `dev` dependency group.
3. Run `uv lock`, then `uv sync`, and compare the resolved tree with the old
   lockfile before deleting `poetry.lock`.

## Common patterns

### Don't use pip in uv projects

```bash
# Bad
pip install requests

# Good
uv add requests
```

### Don't run python directly

```bash
# Bad
python script.py

# Good
uv run script.py
```

```bash
# Bad
python -c "..."

# Good
uv run python -c "..."
```

```bash
# Bad
python3.12 -c "..."

# Good
uv run --python 3.12 python -c "..."
```

For a guaranteed standalone interpreter, install it first and run without a
project: `uv python install 3.12`, then
`uv run --no-project --python 3.12 python`. `uvx python@3.12` can resolve to
any matching interpreter already on the search path, including a system one.

### Don't manually manage environments in uv projects

```bash
# Bad
python -m venv .venv
source .venv/bin/activate

# Good
uv run <command>
```

### Adding dependencies

Add the dependency to the project rather than installing it into the
environment directly, so `pyproject.toml` and `uv.lock` stay authoritative.
For test/lint tooling, use a dependency group:

```bash
uv add --dev pytest ruff pyrefly
uv sync
```

## Documentation

For detailed information, read the official documentation:

- https://docs.astral.sh/uv/llms.txt

---

Adapted from the `uv` skill in [astral-sh/agent-plugins](https://github.com/astral-sh/agent-plugins) (MIT). Local edits: type checking switched to Pyrefly, Poetry migration and dependency-group guidance added.
