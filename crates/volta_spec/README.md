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
                                                              spec.rs: unfold ──► SymbolicOutputs
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
    and reductions `sum(k in 0..K, e)` / `max(k in 0..K, e)`. A range's ends
    are index expressions over dims and enclosing variables, so a scan's causal
    sums read `sum(s in 0..t + 1, ...)` and `sum(r in s + 1..t + 1, ...)`; an
    empty range is the identity (0, or -infinity for `max`), and a non-empty
    one starting below 0 is an `unfold` error. Bodies parse directly into
    `SpecExpr` (`spec.rs`).
- **`instantiate.rs`**: `instantiate(parsed, dims)` resolves every dim to a
  concrete value, producing the `SpecEnv` and `OutputSpec`s `unfold` takes.
  Parsing and instantiation are separate, so one parsed spec serves many sizes.
- **`spec.rs`**: the mathematical form of a spec: `OutputSpec` (an output
  array as a formula `SpecExpr` over other arrays, with `sum`/`max`
  reductions over `start..end` `IndexExpr`s), `Shape` and `SpecEnv`. `unfold`
  memoizes each reduction on its site and the values of the variables its body
  and range read, then expands every output element
  into a `volta_expr::SymbolicOutputs`, using the same arena constructors the
  interpreter uses. The root re-exports these types and `unfold`
  (`volta_spec::unfold`).

`extract_expressions_from_spec(source, dims)` runs the whole pipeline: spec text
and dim values in, `SymbolicOutputs` out (every element, no sampling). Its
`ExtractError` says which stage failed (`Parse`, `Instantiate`, `Unfold`).

Each spec output must be declared `out` or `inout` in the kernel's launch
config. The unfolded spec then plays the role of the reference kernel in the
equivalence check.

Depends on `volta_common` (spans, errors) and `volta_expr`.
