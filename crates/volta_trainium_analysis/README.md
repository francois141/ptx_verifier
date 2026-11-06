# volta_trainium_analysis

AWS Trainium kernel analysis for Volta, parallel to `volta_ptx_analysis` and
`volta_amd_analysis`. Its input is an NKI kernel: a Python function decorated
with `@nki.jit` that moves tiles between device memory (HBM) and the on-chip
buffers (SBUF, PSUM) and computes on them with `nki.isa` instructions.

The directories mirror the other analyses' stages:

- `src/frontend/`: NKI source parsing.
- `src/ir/`: the instruction representation used by execution.
- `src/lower/`: conversion from parsed kernels to that representation.
- `src/eval/`: symbolic execution.

The frontend is public; the other stages are private.

## The tile-returning `nki.language` API

v1 is written with `nki.language` functions that return a new tile rather than
writing a `dst`. The parser rewrites each into a tile declaration, named after the
assigned variable, and the one `nki.isa` instruction NKI lowers it to, so lowering
and execution see only `nki.isa`:

| Call | Tile | Instruction |
|---|---|---|
| `x = nl.load(src)` | SBUF, `src`'s region shape | `dma_copy` |
| `nl.store(dst, value)` | (none) | `dma_copy(dst, src=value)` |
| `p = nl.matmul(x, y, transpose_x=True)` | PSUM `[x.free, y.free]` | `nc_matmul(stationary=x, moving=y)` |
| `m = nl.max(x, axis, keepdims=True)` | SBUF `[P, 1]` | `tensor_reduce(op=maximum)` |
| `s = nl.sum(x, axis, keepdims=True)` | SBUF `[P, 1]` | `tensor_reduce(op=add)` |
| `e = nl.exp(x)` | SBUF, `x`'s shape | `activation(op=exp)` |
| `r = nl.reciprocal(x)` | SBUF, `x`'s shape | `reciprocal` |
| `t = nl.transpose(x)` | PSUM `[F, P]` | `nc_transpose` |

`t = nl.zeros(shape, dtype, buffer)` declares an on-chip tile and a `memset` of it
to zero, so a later `nc_matmul` into it accumulates onto zeros: the accumulator
v3 and v4 contract into over a loop. `nl.load` reads and `nl.store` writes device
memory only. `transpose_x=False`, where
NKI inserts a transpose, and `keepdims=False` are rejected, as are `dtype=` and
`mask=`. `True` and `False` are values.

## Instructions

Lowering accepts eleven `nki.isa` instructions: `dma_copy`, `tensor_copy`,
`memset`, `tensor_tensor`, `tensor_scalar`, `activation`, `activation_reduce`,
`tensor_reduce`, `reciprocal`, `nc_matmul` and `nc_transpose`. Their
`nki.language` operands come from `ArithOp` (`nl.add`, `nl.subtract`,
`nl.multiply`, `nl.maximum`) and `ActivationFunc` (`nl.sigmoid`, `nl.relu`,
`nl.square`, `nl.rsqrt`, `nl.exp`); a new member means a variant in the enum's
`ALL` array, not a case in lowering. Binary ops take their operands in NKI's
order: `tensor_tensor` computes `data1 op data2` and `tensor_scalar` `data op
operand`, so `nl.subtract` is `data - operand`.

`tensor_reduce` folds `op` over each partition of a tile into one free element,
`dst[p, 0]`, seeded with the partition's first element (as `activation_reduce`
does), so `nl.maximum` needs no `-inf`. NKI reduces free axes only, so its `axis`
must be the tile's free axis, `1` or `(1,)`; `negate` and `keepdims` are not
supported yet. `reciprocal` is elementwise `1 / x`: it lowers to an `Activation`
of `ActivationFunc::Reciprocal`, which is outside `ALL`, so `activation`'s `op`
cannot name it.

Each activation is built from `volta_expr`'s primitives rather than an opaque
node, so the decision procedure can reason through it: `nl.rsqrt` becomes
`rcp(sqrt(x))` and `nl.relu` becomes `max(x, 0)`.

## Shapes and compile-time integers

`@nki.jit` specializes a kernel to the shapes of the arguments it is called
with, so `parse_kernel(source, name, shapes)` takes each parameter's shape, e.g.
`&[("q", &[128, 128]), ...]`: a missing, unknown, repeated or empty shape is a
`ParseError::ParamShape`. The parser then evaluates everything that depends only
on shapes, as NKI's tracer does:

- `d_head, seqlen_q = q.shape` and `seqlen_kv = seqlen_q` bind integers; `t.shape`
  is a tuple of `t`'s extents, so `nl.ndarray(q.shape, ...)` works too.
- `+`, `*` and `//` on integers, and `nl.tile_size.pmax` (128),
  `gemm_stationary_fmax` (128) and `gemm_moving_fmax` (512).
- `assert`s are checked rather than kept: a chain of `==`, `!=`, `<`, `<=`, `>` and
  `>=` over integers (tuples, such as shapes, by `==` and `!=` only). A false one
  is a parse error naming the comparison, e.g. ``assertion fails for this call:
  `64 == 128` is false``.

Names bind and rebind as in Python: to tensors (an alias `b = a` included),
integers, tuples and lists, and a name a function assigns anywhere is local
throughout it, so reading it first is an error. Every tensor gets a name of its
own: a name declared again, as `x = nl.exp(x)` does, takes a version suffix Python
cannot write (`x~1`, `x~2`). `asserted_shapes(source,
name)` reads the shapes a kernel's own `assert param.shape == (extent, ...)`
statements state, for running a kernel without a caller, as `volta_pipeline`'s NKI
frontend does.

## Modules and helper functions

A kernel's file is read whole, but a function only when it is reached, so code no
kernel calls may use any Python: the samples' file also holds v10's classes. The
lexer therefore tokenizes all of Python, strings (docstrings included), every
bracket and `\` continuations; what the subset does not support becomes an
`Unsupported` token, an error only in code that is parsed. A module's top level
may hold imports, `from module import name`s, functions, classes (whose bodies are
never read; using one is an error) and docstrings.

`parse_kernel_with_modules(source, modules, name, shapes)` also takes the modules
the file imports from, as `(module name, source)`; `parse_kernel` takes none. A
`from nki.language import add` needs no source. A call to a helper function,
`scores = softmax_isa(qk_sbuf)`, runs its body in a frame of its own: arguments by
position or keyword, defaults (`axis=(1,)`), and its value from a final `return`.
Its tiles take the call as a prefix, `softmax_isa[0].row_max`, so two calls declare
distinct tiles. A helper call may be a statement, an assignment's value or a
`return`'s, not part of a larger expression; calls nest at most 32 deep. An error
inside a helper names it and its module, its line being that module's.

The helpers may use `list(...)` and `tuple(...)`, list literals (`[]`), item reads
and writes (`shape[a] = 1`), `items.append(value)` and `for` over a tuple or list.
An appended tensor call, `qk_tiles.append(nl.ndarray(...))` as v4 writes, declares
a tile named after its item, `qk_tiles[0]`. Lists are shared, as in Python:
they live in the trace and a `Value::List` is an index into it, so every name bound
to one sees a change.

## Loops and regions

A `for` over `nl.affine_range(count)`, `range(count)`, a tuple or a list is unrolled while the
kernel is resolved, since execution has no control flow; each iteration's tiles are
named after its index (`x.0`, `x.1`), so they stay distinct, while other names
rebind as in Python (`n = n + i` accumulates, and the loop variable keeps its last
value). The count is any compile-time integer, e.g. `seqlen_kv // 4`.

A subscript such as `a[0:4, :]` names a rectangular region, one slice per
dimension, an omitted bound meaning the tensor's own edge; an empty slice is an
error, and so is an integer index, since it would drop its dimension. Every
instruction operand may be a region, as v3 and v4 write `dst=row_max_kv[:, j:j+1]`
or `stationary=q_sbuf[0:PMAX, ...]`: lowering resolves each one into an
`ir::TensorRegion`, and every shape rule (same shape, the result's shape, a
`[partitions, 1]` broadcast operand, the matmul contraction) is a rule on the
regions' shapes, not their tensors'. A whole tensor is the region from zero over its
own shape, which `.ir` prints as the bare name. An instruction reads every operand
before writing any element, so regions of one tile may overlap: `t[:, 1:4] =
mov(t[:, 0:3])` shifts the old values. Hardware limits on where a region may start
(e.g. partition offsets) are not checked.

## Outputs

A kernel's outputs are the arguments it writes, such as an `out` parameter, and
the tensor it returns. A kernel may end with `return t`, where `t` is an HBM
tensor it allocates with `nl.ndarray(shape, dtype, buffer=nl.shared_hbm)`, of
any rank; returning an argument or a tile is a lowering error, and `return`
anywhere but the last statement is a parse error. The returned tensor's output
array is named after it (`kernel_out` in the attention samples).

Each tensor records what its unwritten elements hold (`ir::Initial`): an
argument's are its input symbols, while reading an unwritten element of a tile
or of a kernel-allocated HBM tensor is an `EvalError::UninitializedRead`.

## Fixtures

`tests/kernels.rs` runs each fixture for one call, giving each parameter's shape
(`common::check(name, kernel, shapes)`, or `check_importing` with the fixture
modules it imports from); the fixtures' own shape `assert`s check those shapes.

`tests/fixtures/nki_samples/` holds the NKI samples' `attention_kernels.py` and
`attention_kernel_utils.py` unmodified, from `aws-neuron/nki-samples` at
`ef43bf3` (`src/nki_samples/tutorials/attention_fwd_performance/`, MIT No
Attribution). `attn_fwd_v2.ast` and `.ir` are v2's parsed and lowered forms at the
128 x 128 size it asserts (`common::check_lowering`, no `.out`: its outputs are
checked against `attention.spec` instead).

`tests/fixtures/language_api.py` calls each tile-returning `nki.language` function
on 2 x 2 inputs: a row max of `a.T @ b`, a reciprocal of row sums of `exp(a)`, and
a transpose through PSUM, stored with `nl.store`. `attn_fwd_v1.ast` and `.ir`
snapshot v1, whose lowered form is v2's algorithm.

`tests/fixtures/accumulate.py` computes `matmul.py`'s product with its contraction
split in two chunks of rows over a `range(2)` loop, accumulated into an
`nl.zeros` PSUM tile, so its `.expected` is `matmul.expected`; it then copies the
result through a list of two tiles built with `.append`.

`tests/fixtures/regions_softmax.py` and `regions_matmul.py` compute `softmax.py`'s
and `matmul.py`'s math with every operand a region of a wider tile, so their
`.expected` files are those fixtures'. Between them every instruction takes a
region: the softmax's input sits in the middle columns of a scratch tile and is
reduced one column at a time (v3's two-level max), its statistics share one
`[rows, 2]` tile and broadcast from its columns; the matmul's operands share one
SBUF tile, its contraction runs in two partition chunks accumulated into a
`memset` region of a wider PSUM tile, and its result is transposed there and back
through regions.

`tests/fixtures/helper_call.py` imports `row_sums` from `tests/fixtures/helpers.py`
and calls it twice, by default and by keyword argument; `row_sums` builds its
`[partitions, 1]` shape with `list`, a `for` over its `axes` and an item write, as
`softmax_isa` does. Both modules also hold code no call reaches: a class, and
functions using `if`, `%` and f-strings.

`tests/fixtures/add.py` adds two 16 x 16 tensors elementwise: it copies `a`
and `b` from HBM into SBUF tiles (`nisa.dma_copy`), adds the tiles
(`nisa.tensor_tensor` with `op=nl.add`), and copies the sum back to `out` in
HBM.

`tests/fixtures/gemm_relu.py` computes `relu(a_t.T @ b)`: the activation reads
the matmul's PSUM tile directly, fusing the move to SBUF with the relu
instead of a separate `tensor_copy`.

`tests/fixtures/rms_norm.py` normalizes each partition of a 4 x 8 tensor by
`rsqrt(mean(x^2) + eps)`: `nisa.activation_reduce` squares the tile and sums
each partition into a `(4, 1)` tile, `nisa.tensor_scalar` scales and biases it,
`nisa.activation` takes its reciprocal square root, and a second
`nisa.tensor_scalar` broadcasts that `(4, 1)` tile back across the free axis.

`tests/fixtures/tiled_copy.py` copies an 8 x 4 tensor through SBUF one `(4, 4)`
tile of rows at a time: `nl.affine_range(2)` unrolls into two iterations, each
with its own SBUF tile, copying `a[i * 4:(i + 1) * 4, :]` in and back out to the
matching rows of `out`.

`tests/fixtures/returned_output.py` multiplies two 2 x 4 tensors elementwise
into `kernel_out`, an HBM tensor it allocates with `nl.shared_hbm` and returns.

`tests/fixtures/call_shapes.py` opens like the attention kernels: it unpacks
`a.shape` into `rows, cols`, aliases `width = cols`, reads `nl.tile_size.pmax`
and checks chained, `<=` and `>=` `assert`s. It then adds two 2 x 4 tensors one
`(rows, cols // 2)` tile of columns at a time.

`tests/fixtures/softmax.py` is `attention_kernel_utils.softmax_isa`'s body
written inline over a 2 x 3 tile: a `tensor_reduce` max, a `tensor_scalar`
subtract of that `[2, 1]` row max, `activation` with `nl.exp`, a `tensor_reduce`
sum, `reciprocal` and a `tensor_scalar` multiply. `tests/fixtures/softmax.spec`
states softmax along each row.

`tests/fixtures/matmul.spec` and `tests/fixtures/gemm_relu.spec` state the
`matmul` and `gemm_relu` kernels' math over the kernels' own array names, with
`a_t` as A transposed (`[K, M]`), the layout `nc_matmul`'s stationary operand
takes. `volta_pipeline`'s `trainium_equivalence_tests.rs` checks each kernel
against its spec by the decision procedure rather than by text, and `gemm_relu`
against `matmul.spec` (the product without the clamp) as a negative test.
They also check `softmax` against `softmax.spec`, and, as a negative test,
against the softmax of `-x`, which a `subtract` with its operands reversed would
compute. `just trainium` runs them, in release, with this crate's tests.

`tests/fixtures/attention.spec` is the reference for the NKI attention samples
(`attention_fwd_v1` onward): `numpy_attention` from their `test_attention.py`
transcribed, in their layout, with `q`, `k` and `v` as `[D, N]` (head dimension
by sequence length) and the kernels' `kernel_out` as `[N, D]`. In
`volta_pipeline`'s `trainium_equivalence_tests.rs`, v2, read
from its own file with `softmax_isa` inlined, is proved equal to it on the first row
of 128 outputs by default and on all 16,384 by an ignored test (about a minute in
release), and attention with `q` and `k` swapped is refuted. v1 is proved equal to
it the same way, and to v2 directly, kernel against kernel, on their first row.
