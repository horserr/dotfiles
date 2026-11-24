---
name: pyrefly-cli
description: >-
  This skill should be used for Python type checking with Pyrefly, including
  after creating or modifying `.py`/`.pyi` files, when the user asks to "type
  check", "run pyrefly", "fix type errors", "add type annotations", "check type
  coverage", "suppress type errors", "configure pyrefly", "类型检查",
  "修复类型错误", "补充类型标注", or before finishing a task that changed Python.
  Use it when the project uses Pyrefly, the user mentions Pyrefly, or no other
  Python type checker is configured. Covers `pyrefly check`, configuration,
  `pyrefly infer`, coverage, baselines, and suppressions.
---

# Pyrefly CLI

Pyrefly is a fast Python type checker. Treat the CLI as the authoritative source
of type errors: LSP diagnostics pushed after an edit can lag and cover only open
files.

## Fix loop

1. Run `pyrefly check` from the project root.
2. Read each diagnostic: `path:line:column: message [error-kind]`.
3. Fix the root cause. Prefer correcting annotations and call sites over
   silencing the diagnostic.
4. Run `pyrefly check` again until it exits 0.

Fix errors caused by the current task. If the project has many pre-existing
errors, report them and ask before widening the scope.

## Essential commands

| Goal | Command |
| --- | --- |
| Check the project | `pyrefly check` |
| Check files or directories | `pyrefly check src/ tests/ path/to/file.py` |
| Concise output | `pyrefly check --output-format=min-text` |
| Machine-readable output | `pyrefly check --output-format=json` |
| Make warnings affect the exit code | `pyrefly check --min-severity=warn` |
| Summarize by error kind | `pyrefly check --summarize-errors` |
| Check one snippet | `pyrefly snippet 'x: int = "s"'` |
| Set up or migrate a project | `pyrefly init` |
| Inspect resolved config | `pyrefly dump-config <file>` |
| Preview automatic annotations | `pyrefly infer <files> --dry-run` |
| Bulk-suppress existing errors | `pyrefly suppress` |
| Measure type coverage | `pyrefly coverage check <path> --fail-under 60` |

Exit codes: `0` clean, `1` reported diagnostics, `3` environment or
configuration failure, `4` `required-version` mismatch, `101` crash. Treat only
exit `1` as a type-check result.

## Project setup

Run `pyrefly init` to write `pyrefly.toml` or `[tool.pyrefly]` and migrate
mypy, pyright, or basedpyright settings. Ask before running it if the user has
not requested project setup.

Without a configuration, Pyrefly migrates a nearby mypy/pyright config in memory
or falls back to the `basic` preset. The basic preset checks very little, so a
clean result there does not mean the code is well typed.

Use `pyrefly dump-config <file>` when imports, Python versions, or interpreters
resolve unexpectedly. See [configuration.md](references/configuration.md) for
presets, per-error severity, baselines, and sub-configs.

## Suppression

Do not add a suppression without the user's agreement. When one is justified,
suppress the narrowest scope:

```python
value: int = load()  # pyrefly: ignore[bad-assignment]
```

`# type: ignore` is also recognized. `# pyrefly: ignore-errors` suppresses a
whole file and must appear before any code.

For a legacy codebase, `pyrefly suppress` (equivalent to
`pyrefly check --suppress-errors`) inserts ignore comments for every current
error. It rewrites source files, so run it only with the user's explicit
agreement and review the diff. A baseline file is the non-invasive alternative;
see [configuration.md](references/configuration.md#baselines).

## Advanced topics

Consult these references when the task goes beyond a straightforward check/fix:

- **[configuration.md](references/configuration.md)** — config discovery,
  presets, per-error severity, file selection, interpreter and import
  resolution, baselines, sub-configs, `extends`, and LSP-related options.
- **[infer.md](references/infer.md)** — automatic annotations with
  `pyrefly infer`, its flags, and the review workflow.
- **[coverage.md](references/coverage.md)** — `pyrefly coverage check`/`report`
  and how to use coverage to decide whether stricter checking is realistic.
- **[query.md](references/query.md)** — `pyrefly query` for CLI
  hover/references/call hierarchy, availability by version, and its limits.

Use the sibling **`tensor-shapes`** skill (`pyrefly:tensor-shapes`) for tensor
and array shape annotations (`Tensor[[...]]`, `Int[X]`), stub-package setup, and
PyTorch model porting.

## Cautions

- Pyrefly reads files from disk, not unsaved editor buffers.
- `pyrefly check <file>` uses single-file mode and ignores the configuration's
  `project-includes` and `project-excludes`. In Pyrefly 1.4.x, directory
  arguments also ignore `project-excludes`; 1.5+ honors them. Run `pyrefly
  check` with no file arguments for the authoritative project-wide result.
- Baselines suppress errors on the CLI, but the IDE/LSP still shows matched
  diagnostics.
- Do not set `disable-type-errors-in-ide` while relying on the plugin's LSP
  diagnostics.
