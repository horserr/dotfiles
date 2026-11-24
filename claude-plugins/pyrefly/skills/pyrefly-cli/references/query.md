# CLI Queries

Recent Pyrefly releases expose LSP-style queries without an editor:

```bash
pyrefly query hover src/module.py 42 8
pyrefly query find-references src/module.py 42 8 --include-declaration
pyrefly query call-hierarchy src/module.py 42 8
```

The command is experimental and absent from older releases, including 1.4.x.
Check `pyrefly --help` for `query`; when unavailable, use the `LSP` tool that the
plugin's language server provides.

## Conventions

- Input line and column are 1-based; columns count UTF-16 code units.
- Output is one JSON value on stdout. Output ranges are 0-based and use `file:`
  URIs.
- `hover` returns LSP hover content or `null`.
- `find-references` returns locations sorted by URI, line, and column;
  `--include-declaration` adds the declaration.
- `call-hierarchy` returns `item`, `incoming`, and `outgoing`.

## Limits

- Reads files from disk, not unsaved buffers.
- Each invocation creates a new analysis state. References and call hierarchy
  index the project and can be slow or memory-heavy on large repositories.
- Results are limited to the configured `project-includes`/`project-excludes`;
  an empty result does not prove that no callers exist.
