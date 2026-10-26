# volta_spec

The textual spec language: a math description of what a kernel should
compute. `volta verify` checks a kernel against one.

```
# relu.spec
dim N;
array x[N];
array out[N];
out[i] = max(x[i], 0);
```

```
dim M; dim N; dim K;
param alpha;
array A[M, K]; array B[K, N]; array C[M, N];
C[i, j] = alpha * sum(k in 0..K, A[i, k] * B[k, j]);
```

## Pipeline

```
.spec text ──lex.rs──► tokens ──parse.rs──► ParsedSpec ──instantiate.rs──► (SpecEnv, Vec<OutputSpec>)
                                            (named dims)  (dim values,        │
                                                           e.g. --dim N=128)  ▼
                                                              volta_expr::spec::unfold ──► SymbolicOutputs
```

- **`lex.rs`**: ASCII-only tokenizer.
- **`parse.rs`**: `parse_spec` produces a `ParsedSpec` (`ast.rs`):
  - `dim NAME;`: an integer size, given a value at instantiation;
  - `param NAME;`: a symbolic scalar, matched to the kernel's symbolic float
    parameter of the same name;
  - `array NAME[d0, d1, ...] [padded];`: an array's shape. With `padded`, an
    out-of-shape read is 0 (convolution borders) instead of an error;
  - `NAME[i, j, ...] = expr;`: an output equation. Bodies use `+ - * /`,
    unary `-`, builtins (`exp`, `log`, `sqrt`, `abs`, `sign`, `min`, `max`)
    and reductions `sum(k in 0..K, e)` / `max(k in 0..K, e)`. Bodies parse
    directly into `volta_expr::spec::SpecExpr`.
- **`instantiate.rs`**: `instantiate(parsed, dims)` resolves every dim to a
  concrete value, producing the `SpecEnv` and `OutputSpec`s `unfold` takes.
  Parsing and instantiation are separate, so one parsed spec serves many sizes.

Each spec output must be declared `out` or `inout` in the kernel's launch
config. The unfolded spec then plays the role of the reference kernel in the
equivalence check.

Depends on `volta_common` (spans, errors) and `volta_expr`.
