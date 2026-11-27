# volta_expr

The expression language every other part of Volta speaks. The interpreter
builds expressions, `volta_spec` unfolds specs into them, and the equivalence
checker consumes them. It depends on no other Volta crate, which is how
`volta_ptx_analysis` (the producer) and `volta_equivalence` (the consumer) stay
independent of each other.

The language comes in two forms. Producers build `symbolic_full`: every
operation exactly as executed, nothing folded. `lower` turns it into
`symbolic_simplified` (also reachable as `symbolic` and from the crate root),
the constant-folded form the backends decide.

## Full expressions (`symbolic_full/`)

`symbolic_full::ExprArena` has the simplified arena's constructors and node
kinds, plus the operations kernels name that the simplified form spells out (`Exp2`,
`Log2`, `Fma`, `Rcp`, `Tanh`, `Rsqrt`, `Sigmoid`, `Copysign`, `Median3`), and each
constructor pushes its node as given.
An operation also records its *value* (`value`, `value_node`): the constant,
operand or input element lowering replaces it with, else the node itself.
`value.rs` computes it by lowering the operation in a scratch arena, each
operand standing in as its constant value or an opaque symbol, so a value
always agrees with the lowering. Execution decides on values (`as_i64`,
`as_bool`, `is_undefined`, ...): addresses, branches and modelled cases see
the constants they computed, while the outputs keep every operation.

Every operation carries the `Type` its frontend's instruction states (`ty`):
`Float(w)`, `Int(signedness, w)`, `Bits(w)`, `Pred`, or `Real` for a spec's or an
NKI kernel's values, which have no machine width.

## Lowering (`lower.rs`)

`lower(&FullOutputs) -> SymbolicOutputs` (also `FullOutputs::lower`) rebuilds
the nodes an output reaches, children first, with the simplified
constructors. A node with a value takes its value's lowering, so no fold runs
twice. The full forms the simplified language lacks are written out there: `fma` as
`a * b + c`, `rcp` as `1 / a`, `exp2`/`log2` through `exp`/`log` (folding a float32
`log2(e)` factor into the exact `exp` it approximates), `tanh` as
`(e^{2a} - 1) / (e^{2a} + 1)` so the decision procedure reasons about it, `rsqrt` as
`1 / sqrt(a)`, `sigmoid` as `1 / (1 + e^-a)`, `copysign` as a select on the sign, and
the median of three as `max(min(a, b), min(max(a, b), c))`. A float-typed `x ^ sign` or
`x & !sign` (the mask touching only the sign bit of the type's width) lowers to `-x` or
`|x|`; the same masks on integers or untyped bits stay bitwise. Each input array keeps one string.
Each language defines its own atoms (`Real`, `SymbolId`, `NanError`) in its
`node.rs`: lowering converts a full constant to a simplified one and gives each
machine symbol a fresh simplified one. `volta_pipeline` lowers every analysis's and spec's outputs before the
equivalence branch; the event graph's stored values stay in the full arena.
`tests/lower_tests.rs` checks that an operation stays as built while its value
and its lowering follow the simplified folds, and that float sign masks lower to `-x`
and `|x|` while untyped bits stay bitwise.

## Simplified expressions (`symbolic_simplified/`)

Expressions are a **DAG in an arena**. `ExprArena` owns the nodes (and
interned strings); an `ExprId` is a copyable handle into it. A value computed
once and used many times is referenced by the same id, not copied, which keeps
FlashAttention-sized outputs linear in their DAG size. The arena does not
deduplicate structurally equal nodes; the equivalence checker's canonicalizer
does that.

- **Atoms**: `IntConst`, `RealConst(Real)`, `BoolConst`, `Symbol(SymbolId)`,
  `ParamSymbol(StringId)`, `InputElement { array, index }`, `Undefined`.
- **Operators**: arithmetic (`Add`, `Sub`, `Mul`, `Div`, `Rem`, `Neg`),
  transcendental (`Exp`, `Log`, `Sqrt`), bitwise, comparisons, boolean,
  `Select`, `Min`, `Max`, `Abs`, conversions.
- **Exact constants**: a float constant is a `Real` (behind an `Arc`), an
  arbitrary-precision rational (`rug`) or `±inf`. NaN is rejected at every f64 entry point. Floats are modeled as
  reals, not IEEE values.
- **Eager, exact constant folding**: every constructor folds what it can,
  exactly over ℚ. Undefined forms (`inf - inf`, `0 * inf`, `x / 0`) stay
  unfolded, so the canonicalizer reports them instead of hiding them.
- **Symbol identity** (`SymbolRef`: `Param` / `Element` / `Machine`) comes
  only from launch-config names, never from PTX register names. Values with no
  config binding get fresh `Machine` symbols (`SymbolId::fresh()`).

## Outputs (`outputs.rs`)

`FullOutputs` is what a producer returns, `SymbolicOutputs` its lowering.
`SymbolicOutputs { arena, outputs }` is the hand-off type: for each output
array, the written elements as `(index, root ExprId)` pairs sorted by index.
`validate()` bounds-checks every id, and `element(array, index)` looks one up.
Both a kernel run and an unfolded spec lower to this type, so a kernel can be
checked against a spec exactly as against a second kernel.

## Text format (`text.rs`, `.vexpr`)

A deterministic exchange format (`write_text` / `to_text` / `read_text`). It
has one node per line, children before parents, sharing preserved, and only
the nodes reachable from an output:

```
volta-expr 2
n0 = elem "in" 0
n1 = elem "in" 1
n2 = add n0 n1
out "out" 0 n2
```

Reading rebuilds nodes exactly as written (no folding) and validates them.
The writer matches exhaustively over `ExprNode`, so a new node kind cannot be
added without a text form. `volta analyze --emit-exprs` writes this format and
`volta compare --exprs` reads it.

Lean challenge generation lives in [`volta_lean`](../backend/volta_lean/README.md).

### Folds against infinity and zero

Comparisons fold when one side is an infinite constant and the other provably finite, or one
side is zero and the other provably positive and finite (`exp` of a finite value, a positive
constant, sums, products, `max` and `|x|` of such). Kernels guard softmax denominators this way
(`sum == 0 ? inf : log(sum)`, FlashMLA's combine); `and`/`or`/`not` fold a constant operand, so
such guards disappear. Covered by `volta_pipeline`'s `float_bit_comparisons` fixture.
