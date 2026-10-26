# volta_expr

The expression language every other part of Volta speaks. The interpreter
builds expressions, specs unfold into them, and the equivalence checker
consumes them. It depends on no other Volta crate, which is how
`volta_analysis` (the producer) and `volta_equivalence` (the consumer) stay
independent of each other.

## Expressions (`symbolic.rs`)

Expressions are a **DAG in an arena**. `ExprArena` owns the nodes (and
interned strings); an `ExprId` is a copyable handle into it. A value computed
once and used many times is referenced by the same id, not copied, which keeps
FlashAttention-sized outputs linear in their DAG size. The arena does not
deduplicate structurally equal nodes; the equivalence checker's canonicalizer
does that.

- **Atoms**: `IntConst`, `RealConst(Real)`, `BoolConst`, `Symbol(SymbolId)`,
  `ParamSymbol(StringId)`, `InputElement { array, index }`, `Undefined`.
- **Operators**: arithmetic (`Add`, `Sub`, `Mul`, `Div`, `Rem`, `Neg`, `Fma`),
  transcendental (`Exp`, `Log`, `Sqrt`, `Rcp`), bitwise, comparisons, boolean,
  `Select`, `Min`, `Max`, `Abs`, conversions.
- **Exact constants**: a float constant is a `Real`, an arbitrary-precision
  rational (`rug`) or `±inf`. NaN is rejected at every f64 entry point. Floats
  are modeled as reals, not IEEE values.
- **Eager, exact constant folding**: every constructor folds what it can,
  exactly over ℚ. Undefined forms (`inf - inf`, `0 * inf`, `x / 0`) stay
  unfolded, so the canonicalizer reports them instead of hiding them.
- **Symbol identity** (`SymbolRef`: `Param` / `Element` / `Machine`) comes
  only from launch-config names, never from PTX register names. Values with no
  config binding get fresh `Machine` symbols (`SymbolId::fresh()`).

## Outputs (`outputs.rs`)

`SymbolicOutputs { arena, outputs }` is the hand-off type: for each output
array, the written elements as `(index, root ExprId)` pairs sorted by index.
`validate()` bounds-checks every id, and `element(array, index)` looks one up.
Both a kernel run and an unfolded spec produce this type, so a kernel can be
checked against a spec exactly as against a second kernel.

## Specs (`spec.rs`)

The mathematical form of a spec: `OutputSpec` (an output array as a formula
`SpecExpr` over other arrays, with `sum`/`max` reductions), `Shape` and
`SpecEnv`. `unfold` expands every output element into the arena using the same
constructors the interpreter uses. The textual `.spec` language is parsed by
`volta_spec`.

## Text format (`text.rs`, `.vexpr`)

A deterministic exchange format (`write_text` / `to_text` / `read_text`). It
has one node per line, children before parents, sharing preserved, and only
the nodes reachable from an output:

```
volta-expr 1
n0 = elem "in" 0
n1 = elem "in" 1
n2 = add n0 n1
out "out" 0 n2
```

Reading rebuilds nodes exactly as written (no folding) and validates them.
The writer matches exhaustively over `ExprNode`, so a new node kind cannot be
added without a text form. `volta analyze --emit-exprs` writes this format and
`volta compare --exprs` reads it.
