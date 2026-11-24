# Pyrefly Infer

`pyrefly infer` adds type annotations automatically. The feature is under active
development; review every change before keeping it.

## Usage

```bash
pyrefly infer src/module.py --dry-run
pyrefly infer src/module.py
pyrefly infer src/ --return-types --parameter-types
```

Run in small batches so the diff stays reviewable. `--dry-run` prints the
changes and exits 1 if any are needed, without writing files.

## Flags

- `--containers[=true|false]` — annotate container types.
- `--return-types[=true|false]` — annotate return types.
- `--parameter-types[=true|false]` — annotate parameters.
- `--imports[=true|false]` — add imports for types used in annotations.
- `--dry-run` — preview only.
- Standard configuration and environment flags such as `-c`, `--preset`, and
  `--python-interpreter-path`.

## Workflow

1. Run `--dry-run` on one file or a small directory and inspect the diff.
2. Apply the change to that scope.
3. Run `pyrefly check` on the changed files. New annotations often expose new
   errors; fix them or suppress them deliberately.
4. Keep the annotation change separate from behavior changes when reporting or
   committing.

Do not run `pyrefly infer` across a whole repository without the user's explicit
request. It rewrites many files and is not part of the normal type-fix loop.
