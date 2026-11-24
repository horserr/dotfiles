---
name: tensor-shapes
description: >-
  This skill should be used when adding or debugging Pyrefly tensor shape
  annotations: `Tensor[[...]]`, `Int[X]`, symbolic dimensions, variadic batch
  dimensions, `assert_type` shape checks, PyTorch/NumPy/JAX array shapes,
  jaxtyping interop, or "张量形状", "shape annotations", "shape checking". Also
  use it when a shape error appears in `pyrefly check` or when porting a torch
  model to shape typing.
---

# Pyrefly Tensor Shapes

Pyrefly can track array and tensor dimensions as types:
`Tensor[[B, C, H, W]]`, `np.ndarray[[2, 3], np.dtype[np.float64]]`, and
`jax.Array[[2, 3]]`. Shape checking is opt-in and depends on the stub package
installed in the project environment.

## Version and installation

Current shape stubs are 1.5.0 and require Pyrefly 1.5.0 or newer. Verify
`pyrefly --version` before diagnosing shape results; 1.4.x parses shape syntax
but does not apply shape inference.

Install the stub package for the array library into the Python environment
Pyrefly uses, not the Claude Code environment:

- PyTorch: `pyrefly-torch-stubs`
- NumPy: `pyrefly-numpy-stubs`
- JAX: `jax-pyrefly-stubs`
- einops: `pyrefly-einops-stubs`

```bash
uv add --dev pyrefly-torch-stubs
# or install into the active environment:
uv pip install pyrefly-torch-stubs
```

The stub packages install `pyrefly-shape-extensions` and enable shape inference
automatically. Do not pass `--tensor-shapes`: it is a deprecated no-op (and
removed in 1.5+). Support is derived from whether `shape_extensions` is
resolvable.

Shape errors do not appear under the `basic` preset. Run `pyrefly init` or set
`preset = "default"` or `"strict"` in `pyrefly.toml`.

Confirm that Pyrefly selected the right environment:

```bash
pyrefly dump-config path/to/model.py
```

The interpreter and site-packages path must point at the environment containing
the stub package.

## Syntax quick reference

Add `from __future__ import annotations` to implementation files that contain
shape annotations.

```python
from __future__ import annotations

from shape_extensions import IntTuple, IntVar
from torch import Tensor

concrete: Tensor[[3, 4]]

def example[B: IntVar, C: IntVar, H: IntVar, W: IntVar](
    x: Tensor[[B, C, H, W]],
) -> Tensor[[B, 3 * C, H // 2]]: ...

def forward[Bs: IntTuple, M: IntVar, N: IntVar](
    self, x: Tensor[[*Bs, M, N]]
) -> Tensor[[*Bs, M * N]]: ...

def reshape[D: IntVar](x: Tensor[[D]], n: Int[D]) -> Tensor[[D, 1]]: ...
```

- `Tensor[[...]]` fixes the rank. Use `Tensor[[*Bs, D]]` with `Bs: IntTuple` for
  leading dimensions that should be preserved without being enumerated.
- Bare `Tensor` means the shape is unknown. Use it deliberately at a gradual
  boundary, never as a shortcut.
- `Int[X]` is an integer tied to dimension `X`; plain `int` erases that tie.
- When `x: Tensor[[B, C, H, W]]`, `x.size(0)` has type `Int[B]` and `x.shape`
  has type `IntTuple[B, C, H, W]`.
- `assert_type(expr, Tensor[[...]])` verifies inferred shapes. `reveal_type`
  probes a type temporarily.
- Runtime-evaluated positions such as `cast(...)` and `assert_type(...)` need
  `IntVar[N]` / `Elements[Bs]` wrappers or a quoted type string.

## Workflow

1. Record the check command, the project interpreter, and a known-good baseline
   file.
2. Collect shape evidence from existing annotations, comments, layer
   dimensions, reshape operations, and tests before inventing symbolic names.
3. Annotate module boundaries first, then probe intermediates with temporary
   `reveal_type` calls. Remove the probes before finishing.
4. Run `pyrefly check` after each module. If an operation's shape is untracked,
   keep that region gradual and make its exit precise instead of rewriting
   runtime code.
5. Verify with `pyrefly check` and the project's tests. Report remaining gradual
   boundaries and why they are untracked.

Do not narrow a public API from `int` to `Int[X]`, rewrite loops or factories to
improve inference, or edit shared stubs without the user's approval.

## jaxtyping interop

For minimal churn, keep existing jaxtyping annotations and declare dimensions
with `@static_jaxtyping("batch channels *rest")` from `shape_extensions`; the
existing `Float[Tensor, "..."]` annotations become statically checked.

For a native-syntax conversion, preserve rank, literal dimensions,
named-dimension equalities, and variadic prefixes. Do not downgrade a precise
annotation to bare `Tensor`.

## Full model port

For a complete PyTorch model port, the Pyrefly repository ships a dedicated
agent skill with a five-phase workflow, porting principles, a style guide, and
`verify_port.sh`:

<https://github.com/pyrefly-org/pyrefly/tree/main/tensor-shapes/skills/add-shape-types-to-torch-model>

Read that `SKILL.md` before a full port. It covers environment validation,
operation auditing, module-by-module porting, and reporting untracked
boundaries.

## Claude Code notes

The plugin's LSP and Stop hook run the `pyrefly` binary on `PATH`. Upgrade that
binary to 1.5.0 or newer so shape diagnostics appear in Claude Code:

```bash
pixi global update pyrefly
# or: uv tool install pyrefly
```

The plugin configuration itself needs no change for tensor shapes.
