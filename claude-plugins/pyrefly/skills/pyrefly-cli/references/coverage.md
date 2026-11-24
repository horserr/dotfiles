# Type Coverage

`pyrefly coverage` measures how much of the public API is annotated.

- A typable is a function return type, parameter, module-level variable, or class
  attribute.
- Coverage counts annotated typables; `Any` counts as covered.
- Strict coverage counts only typables whose resolved type contains no `Any`.
- Only public names count by default; `--public-only` restricts the report to
  re-exported API.

## Check a threshold

```bash
pyrefly coverage check src/ --fail-under 60
pyrefly coverage check src/ --fail-under 80 --strict
```

Findings are reported as `coverage-missing` or `coverage-partial`. The summary
goes to stderr; the exit code is nonzero when coverage is below the threshold.

## JSON report

```bash
pyrefly coverage report src/ > coverage.json
pyrefly coverage report src/ | jq .summary.strict_coverage
```

The report contains a schema version, a summary, and per-module and per-symbol
counts, locations, public names, and suppression comments.

## Use in practice

Pyrefly's agent experiments found that type checking helps agents mainly in
well-typed codebases; in poorly typed code, pre-existing errors distract from the
task. Use coverage to choose the strategy:

- Low coverage: add annotations first (`pyrefly infer`, reviewed) or adopt a
  baseline instead of escalating to `strict`.
- High coverage: enable `strict`, fix new errors, and keep the project clean.
