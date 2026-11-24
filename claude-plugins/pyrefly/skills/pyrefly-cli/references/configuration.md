# Pyrefly Configuration Reference

## Where configuration lives

- `pyrefly.toml`, or a `[tool.pyrefly]` table in `pyproject.toml`. `pyrefly.toml`
  wins when both exist.
- Pyrefly selects the nearest configuration for each file. An explicit
  `-c`/`--config <file>` disables discovery for the files passed to that
  invocation.
- `pyrefly init [PATH]` creates or updates the config and migrates mypy,
  pyright, and basedpyright settings. Useful flags:
  `--migrate-from auto|mypy|pyright`, `--non-interactive`, `--dry-run`,
  `--print-config`.
- `pyrefly dump-config <file>` prints the chosen config, Python version,
  interpreter, covered files, and import roots.

## Checking modes

- No file arguments: project mode. Uses one selected configuration and applies
  its `project-includes`/`project-excludes`.
- File arguments: single-file mode. Each file uses its nearest configuration,
  but the configuration's `project-includes`/`project-excludes` are ignored.
- Directory arguments: per-file configuration selection. In Pyrefly 1.4.x,
  `pyrefly check <dir>` also ignores `project-excludes`; 1.5+ honors them. Run
  `pyrefly check` with no arguments for the authoritative project-wide result.

## Presets

`preset = "off" | "basic" | "legacy" | "default" | "strict" | "all"`

- `basic`: unconfigured default; parse errors and a few high-confidence checks
  only.
- `legacy`: mypy migration preset.
- `default`: standard Pyrefly defaults.
- `strict`: recommended strict base; adds `implicit-any`, override, property,
  and `unused-ignore` checks.
- `all`: every kind at error severity; noisy.

Explicit settings override the preset.

## Per-error severity

```toml
[errors]
bad-return = "error"
implicit-any = false      # disable
assert-type = true        # enable at default severity
```

Values: `"error"`, `"warn"`, `"info"`, `"hint"`, `"ignore"`, or a boolean. CLI
equivalents: `--error`, `--warn`, `--info`, `--ignore`.

Other display controls:

- `min-severity`: lowest severity shown by `pyrefly check`; diagnostics at or
  above it also cause exit 1.
- `only = ["bad-return", ...]`: restrict processing to the listed kinds.
- `output-format = "full-text" | "min-text" | "json" | "github" | "junit-xml" |
  "code-climate" | "sarif" | "omit-errors"`.

## File selection

- `project-includes` (default `["**/*.py*"]`) and `project-excludes`.
- `use-ignore-files` (default true) honors `.gitignore`, `.ignore`, and
  `.git/info/excludes`.
- `extra-file-extensions` for non-standard Python extensions.

## Environment and imports

- `python-interpreter-path = ".venv/bin/python3"` (`.venv/Scripts/python.exe`
  on Windows) when Pyrefly picks the wrong environment.
- `search-path = ["src", ...]` for first-party imports.
- `site-packages-path` to point at third-party packages directly.
- `python-version`, `python-platform`, `typeshed-path`, `conda-environment`,
  `skip-interpreter-query`.
- `ignore-missing-imports = ["pkg.*"]` or `replace-imports-with-any =
  ["pkg.*"]` to unblock checks while dependencies are missing. Prefer fixing the
  environment.

## Baselines

```toml
baseline = "pyrefly_baseline.json"
```

- Generate or regenerate: `pyrefly check --baseline=pyrefly_baseline.json
  --update-baseline`.
- Report only new errors: `pyrefly check --baseline=pyrefly_baseline.json`.
- Remove stale entries: `pyrefly check --prune-baseline`.
- `baseline-error-level` reports matched diagnostics at a lower severity instead
  of hiding them.
- `baseline-matching-mode = "column" | "concise-description" |
  "column-ordered"`.
- Baselines suppress CLI output, but the IDE/LSP still displays matched
  diagnostics as hints unless `baseline-error-level` is set.
- A baseline is the least invasive way to adopt Pyrefly in a legacy codebase.

## Sub-configs

Override selected options for matching paths:

```toml
[[sub-config]]
matches = ["tests/**"]

[sub-config.errors]
assert-type = false
```

Allowed overrides: `preset`, `errors`, `replace-imports-with-any`,
`replace-untyped-imports-with-any`, `check-unannotated-defs`,
`infer-return-types`, `class-decorator-behavior`,
`ignore-errors-in-generated-code`, `permissive-ignores`, `enabled-ignores`.

The first matching sub-config that sets an option wins. `errors` tables merge
over the top-level table. Options that change checked files, the Python
environment, or import roots are not allowed.

## Shared configuration

```toml
extends = "pyproject.toml"
```

Child scalar and list values replace inherited values; tables merge by key.
Relative paths resolve against the declaring config. An inheritance cycle or an
invalid base configuration is an error.

## Unannotated code

- `check-unannotated-defs` (default true): check bodies of fully unannotated
  functions.
- `infer-return-types = "never" | "annotated" | "checked"` (default
  `"checked"`).
- `infer-with-first-use` (default true): infer empty containers from first use,
  like mypy; false gives `Any`, like pyright.
- `infer-param-types-from-docstring` to read parameter types from docstrings.

## Ignore configuration

- `enabled-ignores` (default `["type", "pyrefly"]`) and `permissive-ignores`
  control whether `# pyright: ignore` and `# ty: ignore` are honored.
- `type-ignore-unknown-tag-behavior = "no-effect" | "downgrade-to-warning" |
  "suppress"`.
- A file-level `# pyrefly: ignore-errors[kind]` must precede any code.

## LSP-related options

- `skip-lsp-config-indexing = true` speeds startup at the cost of
  index-dependent features.
- `disable-type-errors-in-ide = true` silences all IDE diagnostics. Do not set
  it while relying on the Claude Code plugin's automatic diagnostics.
- The LSP selects a configuration per file. CLI project mode selects one
  configuration for the whole project, so the two can disagree.
