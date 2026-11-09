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
| `m = nl.max(x, axis, keepdims=False)` | SBUF, `x`'s shape less `axis` | `tensor_reduce(op=maximum)` |
| `s = nl.sum(x, axis, keepdims=False)` | SBUF, `x`'s shape less `axis` | `tensor_reduce(op=add)` |
| `e = nl.exp(x)` | SBUF, `x`'s shape | `activation(op=exp)` |
| `r = nl.reciprocal(x)` | SBUF, `x`'s shape | `reciprocal` |
| `t = nl.transpose(x)` | PSUM `[F, P]` | `nc_transpose` |
| `b = nl.broadcast_to(x, shape)` | SBUF `shape` | `tensor_copy(src=nl.broadcast_to(x, shape))` |

`t = nl.zeros(shape, dtype, buffer=nl.sbuf)` declares an on-chip tile and a `memset` of it
to zero, so a later `nc_matmul` into it accumulates onto zeros: the accumulator
v3 and v4 contract into over a loop. `nl.load` reads and `nl.store` writes device
memory only. `transpose_x=False`, where
NKI inserts a transpose, is rejected, as are `dtype=` and `mask=`. `nl.max` and
`nl.sum` reduce trailing free axes of a tile, a region or an access-pattern view
(`nl.sum(pool_view, axis=[3, 4])`), `keepdims=True` keeping them as extents of 1.
`nl.broadcast_to` follows numpy's rule, each extent of `x` matching `shape` or 1, the
partitions included (mamba's one-partition `B_i` to 128); the docs say it returns a
tile, so it is a copy into one, its source an `ast::Operand::Broadcast` that lowering
reads through a pattern stepping 0 along each repeated dimension (`dtype=` is
rejected). A region's `.shape` (its kept extents) and `.dtype` are values, as a
tensor's are. `True` and `False` are values.

## Instructions

Lowering accepts fourteen `nki.isa` instructions: `dma_copy`, `tensor_copy`,
`memset`, `tensor_tensor`, `tensor_scalar`, `tensor_scalar_reduce`, `activation`,
`activation_reduce`, `tensor_reduce`, `tensor_tensor_scan`, `reciprocal`, `nc_matmul`,
`nc_transpose` and `dma_transpose`. An instruction's `engine=` (`nisa.vector_engine`,
`nisa.scalar_engine` or `nisa.gpsimd_engine`) is accepted and dropped, since the
engine does not change the result. Their
`nki.language` operands come from `ArithOp` (`nl.add`, `nl.subtract`,
`nl.multiply`, `nl.maximum`) and `ActivationFunc` (`nl.sigmoid`, `nl.relu`,
`nl.square`, `nl.rsqrt`, `nl.exp`); a new member means a variant in the enum's
`ALL` array, not a case in lowering. Binary ops take their operands in NKI's
order: `tensor_tensor` computes `data1 op data2` and `tensor_scalar` `data op
operand`, so `nl.subtract` is `data - operand`.

`tensor_reduce` folds `op` over `axis`, which must be its data region's trailing
free axes (`1`, `(1,)`, `(2,)` of a 3-D region, `[3, 4]`), NKI reducing free axes
only: each element of `dst`, the region's other dimensions, is the fold of one run of
consecutive elements of its `[partitions, free]` view, seeded with the run's first
element, so `nl.maximum` needs no `-inf`. Reducing every free axis leaves one element
per partition, `t[:, 0:1]` or `t[:, 0]`; `negate=True` negates the result
(`ir::Sign`). `reciprocal` is elementwise `1 / x`: it lowers to an `Activation` of
`ActivationFunc::Reciprocal`, which is outside `ALL`, so `activation`'s `op` cannot
name it.

`activation` computes `op(data * scale + bias)`, as its docs' pseudo-code does, `scale`
and `bias` optional operands broadcast like a `tensor_scalar` one (a literal or a
`[partitions, 1]` tile, mamba's `scale=A_i`), and may reduce its result: with `reduce_op`, `reduce_res` and
`reduce_cmd=nisa.reduce_cmd.reset_reduce` all given, each `reduce_res[p, 0]` is the
fold of `reduce_op` over partition `p` of the result, seeded with its first element
(an `ir::Reduction`). The other `reduce_cmd`s carry the accumulator registers across
instructions, which is not modelled, so they are lowering errors.
`activation_reduce` is the same instruction, as the NKI docs define it, and lowers to
the same `Activation`. `tensor_scalar_reduce` is a one-step `tensor_scalar` with such
a reduction (`reduce_cmd`, if given, must be `reset_reduce`, its default).

`tensor_tensor_scan` is `LoweredInstr::Scan`, the docs' recurrence along each partition
of matrix regions: `dst[p, i] = op1(op0(data0[p, i], dst[p, i - 1]), data1[p, i])`,
`initial` (a literal or a `[partitions, 1]` tile, v3's carried `scan_init`) standing
for `dst[p, -1]`; `reverse0=True` and `reverse1=True` swap their op's operands
(`ir::Order`). Its rank-3 form is rejected: the docs do not say how two free
dimensions are ordered for the scan.

`nc_matmul` takes `accumulate=` as the NKI docs define it (`ir::Accumulation`):
`False` overwrites `dst`, `True` adds to it (an unwritten element is an
`UninitializedRead`, as reading uninitialized PSUM is undefined), and `None`, the
default, overwrites an element's first write and adds to later ones.
`dma_transpose` with `axes=(1, 0)` is a 2-D transpose of one tile region into
another, the same `Transpose` as `nc_transpose`; other `axes` are errors.

A tile's `dtype` is recorded but not modelled: every value is a real, so a kernel
that keeps scores in `nl.bfloat16`, as v7 to v8a do, is checked over the reals, and
the rounding it introduces is outside the check.

Each activation is built from `volta_expr`'s primitives rather than an opaque
node, so the decision procedure can reason through it: `nl.rsqrt` becomes
`rcp(sqrt(x))` and `nl.relu` becomes `max(x, 0)`.

## Shapes and compile-time integers

`@nki.jit` specializes a kernel to the shapes of the arguments it is called
with, so `parse_kernel(source, name, shapes)` takes each parameter's shape, e.g.
`&[("q", &[128, 128]), ...]`: a missing, unknown, repeated or empty shape is a
`ParseError::ParamShape`. A `KernelCall` (`parse_kernel_for_call(source, modules,
name, call)`) also gives parameter dtypes by `nki.language` name, e.g. `("q",
"bfloat16")`, and the tile sizes; a parameter's dtype is needed only when the kernel
compares it, as v10's allocator does to size its tiles. A parameter the call gives
no shape is not a tensor: it takes the call's `KernelCall::constants` value (a
`Constant`: an integer, a tuple of integers or a bool), else its default, as the
matrix multiplication tutorial's `TILES_IN_BLOCK_M=16` does. An `nki.isa`
instruction's operands are by keyword, except the leading ones of `dma_copy` and
`tensor_copy` (`dst`, `src`), `nc_matmul` (`dst`, `stationary`, `moving`) and
`nc_transpose` (`dst`, `data`), which may come by position in that order, as their
docs declare them. The parser then evaluates
everything that depends only on the call, as NKI's tracer does:

- `d_head, seqlen_q = q.shape` and `seqlen_kv = seqlen_q` bind integers; `t.shape`
  is a tuple of `t`'s extents, so `nl.ndarray(q.shape, ...)` works too.
- Integers are signed: `+`, `-`, `*`, `//`, `%`, `&`, unary `-` and `~`, and `+=`
  and the like, `//` and `%` rounding as Python's do. `/` is true division, of
  integers (within 2^53, which convert exactly) or floats, to the f64 quotient, so
  `1.0 / (pool_size * pool_size)` is the float literal it computes. `nl.tile_size.pmax` (128),
  `gemm_stationary_fmax` (128), `gemm_moving_fmax` (512) and `sbuf_fmax_bytes`
  (a tile's largest SBUF free size in bytes: a Trn2 partition's 192 KiB, a value the
  docs do not state) are the hardware's
  limits, `TileSizes::HARDWARE`. A `KernelCall` may give others, so a tiled kernel
  such as v3 runs its loops on small inputs with small tiles, tiled exactly as at
  full size.
- Comparisons are values: integers by any of `==`, `!=`, `<`, `<=`, `>` and `>=`,
  chained, and other values (tuples, bools, floats, `None`, objects by identity,
  dtypes, `q.dtype` by the call's dtype) by `==` and `!=`; `and`, `or` and `not`
  take Python's truth of a bool, an integer or `None`.
- `assert`s are checked rather than kept, any message unread. A false one is a
  parse error, naming the comparison if it is one, e.g. ``assertion fails for
  this call: `64 == 128` is false``.
- An `if`, `elif` and `else` runs its taken branch only, and a `return` may come
  anywhere, a bare one returning `None`. `with nl.no_reorder():` runs its body: it
  only keeps the instructions in program order, which they always are here.

Names bind and rebind as in Python: to tensors (an alias `b = a` included),
integers, tuples, lists, `None` and objects, and a name a function assigns anywhere is local
throughout it, so reading it first is an error. Every tensor gets a name of its
own: a name declared again, as `x = nl.exp(x)` does, takes a version suffix Python
cannot write (`x~1`, `x~2`). `asserted_shapes(source,
name)` reads the shapes a kernel's own `assert param.shape == (extent, ...)`
statements state, for running a kernel without a caller, as `volta_pipeline`'s NKI
frontend does.

## Modules and helper functions

A kernel's file is read whole, but a function only when it is reached, so code no
kernel calls may use any Python. The lexer therefore tokenizes all of Python, strings (docstrings included), every
bracket and `\` continuations; what the subset does not support becomes an
`Unsupported` token, an error only in code that is parsed. A module's top level
may hold imports, `from module import name`s, functions, classes (each read when
first instantiated), docstrings and an `if __name__ == "...":` block, skipped
unread: a script's driver, which does not run where the module is imported, as NKI
imports a kernel's.

`parse_kernel_with_modules(source, modules, name, shapes)` also takes the modules
the file imports from, as `(module name, source)`; `parse_kernel` takes none. A
`from nki.language import add` needs no source. A call to a helper function,
`scores = softmax_isa(qk_sbuf)`, runs its body in a frame of its own: arguments by
position or keyword, defaults (`axis=(1,)`, evaluated in the helper's module), and
its value from a `return`. Its tiles take the call as a prefix,
`softmax_isa[0].row_max`, so two calls declare distinct tiles, but a tensor it
declares in a `return nl.ndarray(...)` takes the name its caller assigns it to, so
`bufs.q_sbuf = sb.create_ndarray(...)` declares `q_sbuf`. Calls nest at most 32
deep. An error inside a helper names it and its module, its line being that
module's.

A class, `class Buffers(nl.NKIObject):` (`nl.NKIObject` is the only base allowed),
holds attributes assigned in its body (`q_sbuf = None`) and methods. Calling it makes
an object, run through its `__init__` if it has one; objects are shared like lists
(`Value::Object` is an index into the trace). An attribute reads the object's own,
else its class's, else a method bound to the object, and `obj.name = value` assigns
the object's own, a tensor call included (named `name`). A method call `sb.allocate(n)`
runs like a helper call with `self` bound, its tiles prefixed
`SBLinearAllocator.allocate[0].`.

The helpers may use `list(...)`, `tuple(...)` and `len(...)`, list literals (`[]`),
item reads and writes (`shape[a] = 1`), slices of a tuple or list (`shape[1:]`),
`items.append(value)` and `for` over a tuple or list.
An appended tensor call, `qk_tiles.append(nl.ndarray(...))` as v4 writes, declares
a tile named after its item, `qk_tiles[0]`. Lists are shared, as in Python:
they live in the trace and a `Value::List` is an index into it, so every name bound
to one sees a change.

## Loops and regions

A `for` over `nl.affine_range(count)`, `nl.sequential_range(count)`,
`nl.static_range(count)`, `range([start,] stop)`, a tuple or a list is unrolled while the
kernel is resolved, since execution has no control flow; each iteration's tiles are
named after its index (`x.0`, `x.1`), so they stay distinct, while other names
rebind as in Python (`n = n + i` accumulates, and the loop variable keeps its last
value). The count is any compile-time integer, e.g. `seqlen_kv // 4`.

A subscript such as `a[0:4, :]` or `qk[i, j, :, :]` names a rectangular region:
each index is a slice, an omitted bound meaning the tensor's own edge, or an
integer, which selects one position and drops the dimension, as in numpy;
`nl.ds(start, size)` is the slice `start:start + size`. A
subscript may omit trailing dimensions, which it then selects whole, so
`norm_row[i]` is `norm_row[i, :, :]`; an empty slice or an index outside its
dimension is an error. `ast::resolve_region` resolves a subscript for both the
parser (an `nl.load`'s tile takes the region's shape) and lowering.

Every instruction operand may be a region, as v3 and v4 write `dst=row_max_kv[:,
j:j+1]`, `stationary=q_sbuf[0:PMAX, ...]` or `operand0=inverse_sum_row[:, i]`:
lowering resolves each one into an `ir::TensorRegion`, and every shape rule is a
rule on the regions' shapes with their indexed dimensions dropped, not on their
tensors'. So `dma_copy(dst=qk[i, j, :, :], src=qk_sbuf)` copies a `[PMAX, FMAX]`
tile, and a broadcast operand or reduction result needs one element per partition:
`t[:, 0:1]` and `t[:, 0]` both qualify. A whole tensor is the region from zero over
its own shape, which `.ir` prints as the bare name; an indexed dimension prints as
its position (`stats[0:2, 0]`). An instruction reads every operand before writing
any element, so regions of one tile may overlap: `t[:, 1:4] = mov(t[:, 0:3])`
shifts the old values. Hardware limits on where a region may start (e.g. partition
offsets) are not checked.

An operand may also be an access-pattern view, `t.ap(pattern, offset=0)`, which
the docs liken to `torch.as_strided`: `pattern` is `[step, count]` pairs, one
dimension of the view each, and the element at `local` is the one at position
`offset + sum(step * local)` of `t`'s row-major layout (`ir::Layout::Pattern`;
rectangles are `Layout::Rectangle`, and `TensorRegion::element` maps either). It must
stay within `t`, and on a tile its first pair is the partitions, so its step must be
the tile's free size and every other element must stay in the partition it starts in
(`StatementError::AccessPattern`, a `PatternProblem`). The `ap` parameters for
dynamic or reinterpreted views (`scalar_offset`, `vector_offset`, `indirect_dim`,
`dtype`) are rejected. `.ir` prints a view as `t.ap([[step, count], ...], offset=o)`.

A tile has its partitions and one or more free dimensions, e.g. v4's
`nl.ndarray((PMAX, seqlen_kv // PMAX, d_head), buffer=nl.sbuf)`. A tile region must
slice its partition dimension. Instructions see each tile region as `[partitions,
free]`, its other dimensions flattened row-major into one free axis, so an
elementwise instruction pairs `v_sbuf_t[:, i, :]` with a `[PMAX, d_head]` tile;
`nc_matmul`, `nc_transpose` and an instruction's reduction take regions of exactly
one free dimension once indexed ones are dropped. Copies pair their regions' elements in row-major order.

v3 to v8a and v10 parse, lower and run unmodified at the size they assert (`q`, `k`
and `v` of `[128, 512]`; v10's in `bfloat16`), each in about ten seconds in release;
`volta_pipeline` checks them there and at reduced tile sizes.

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

## Placed tiles

`nl.ndarray(shape, dtype, buffer, address=(partition, offset))` places an on-chip
tile itself, as attn_fwd_v10's allocators do: its partitions from `partition`, each
holding the tile's free elements row-major from byte `offset` (`ast::Address`,
`Tensor::address`). Elements take their dtype's size, `float32` 4 bytes and
`bfloat16` or `float16` 2, so the dtype must be known (a `q.dtype` from the call's
dtypes); any other dtype is an error. The tile must fit in its buffer: 128 partitions
of `nl.tile_size.sbuf_fmax_bytes` in SBUF, or of 16 KiB in PSUM (eight 2 KiB banks,
as v10 assumes). `address=` on an HBM tensor and `name=` are errors, and a kernel
places all its on-chip tiles or none (`LowerError::MixedAllocation`), since the
compiler could place an unplaced tile anywhere.

Two placed tiles may overlap, as v10's `v_psum_t` and `qk_psum` share PSUM bank 0.
The interpreter finds each pair of tiles whose bytes overlap (`eval/alias.rs`), and a
write through one clobbers every element of the other that covers any of its bytes:
reading a clobbered element before writing it again is an
`EvalError::ClobberedRead`, which names the write, so a kernel is checked only on
values its own tile wrote. This holds in program order. Whether the compiler orders
accesses through two tiles placed over each other, inside or outside
`nl.no_reorder()`, the docs do not say; that ordering is outside the check, like the
asynchrony of DMAs.

## Fixtures

`tests/kernels.rs` runs each fixture for one call, giving each parameter's shape
(`common::check(name, kernel, shapes)`, or `check_importing` with the fixture
modules it imports from); the fixtures' own shape `assert`s check those shapes.

`tests/fixtures/nki_samples/` holds the NKI samples' `attention_kernels.py` and
`attention_kernel_utils.py` unmodified, from `aws-neuron/nki-samples` at
`ef43bf3` (`src/nki_samples/tutorials/attention_fwd_performance/`, MIT No
Attribution), and the other tutorials' kernel files the same way, each with a
`.spec` of its reference beside the fixtures: `tensor_addition_nki_kernels.py`
(`tensor_addition.spec`, `a + b`), `matrix_multiplication_nki_kernels.py`
(`matrix_multiplication.spec`, `lhsT.T @ rhs`), `transpose2d_nki_kernels.py`
(`transpose2d.spec`, each row's `[X, Y]` matrix transposed, its arrays viewed as
`[P, X, Y]` and `[P, Y, X]` since a spec index is affine) and
`average_pool2d_nki_kernels.py` (`average_pool2d.spec`, the mean of each `S x S`
window) and `mamba_nki_kernels.py` (`mamba.spec`, `mamba_torch.py`'s `mamba_layer`, its
scan unrolled into causal sums). `attn_fwd_v2.ast` and `.ir` are v2's parsed and lowered forms at the
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

`tests/fixtures/subscripts_softmax.py` and `subscripts_matmul.py` compute the same
two fixtures' math through integer and partial subscripts and N-D tiles, so their
`.expected` files are again `softmax.expected` and `matmul.expected`: the softmax
writes its statistics to `stats[:, 0]` and `stats[:, 1]`, stores an intermediate as
`norm_row[0]` of a 3-D HBM tensor and loads it back, and keeps its exponentials in
a `(rows, 1, cols)` tile; the matmul stages each contraction chunk at `staged[i]` in
HBM and `sb[:, i, :]` of a 3-D SBUF tile, multiplies `sb[:, i, 0:rows]` by
`sb[:, i, rows:]`, and stores through a 4-D HBM tensor, as v3 and v4 do.

`tests/fixtures/fused_softmax.py` computes softmax over a 2 x 4 tile as v8 does, in
two chunks of columns: `tensor_scalar_reduce` (a multiply by `1.0`) takes each
chunk's max, `tensor_reduce` with `negate=True` folds them into the negated row max,
and `activation` exponentiates each chunk with that as its `bias` and a
`reset_reduce` sum; its `.expected` is written out by hand, and `volta_pipeline`
proves it equal to `softmax.spec`.

`tests/fixtures/pipelined_scale.py` doubles a 6 x 4 tensor as v10 schedules its
work: an allocator class sizing two tiles from the call's `bfloat16` dtype, a buffers
object, and three stages, each skipping the tile indices outside the tensor, called
in a software-pipelined `range(0, count + 2)` inside `with nl.no_reorder()` (its
`.expected` is hand-written).
`tests/fixtures/placed_tiles.py` computes `matmul.py`'s product transposed with every
tile placed by `address=`, including a PSUM tile placed over the accumulator once it
is dead: `accumulate=(i != 0)` over two contraction chunks, twice, so the second
pass's `accumulate=False` must overwrite the first's sum, then `engine=` copies and a
`dma_transpose` (a hand-written `.expected`, `matmul.expected` transposed).
`tests/fixtures/placement_errors.py` holds kernels `tests/kernels.rs` expects to fail:
a read of the bytes a `bfloat16` tile overwrote in one column of a `float32` one
(`ClobberedRead`, at exactly that column), `accumulate=True` into unwritten PSUM, a
kernel placing only some tiles, and a tile past the end of PSUM.
`tests/fixtures/access_patterns.py` transposes each row's 2 x 3 matrix into a 3-D
tile through a strided HBM view, sums it over `axis=(2,)` and copies a column out
through a tile view with an offset (a hand-written `.expected`);
`pattern_errors.py`'s kernels must fail to lower: a tile view whose first step is not
the free size, one leaving its partition, one past its tensor's end, and a
`tensor_reduce` over a leading axis.
`tests/fixtures/scan.py` scans each row of a 2 x 3 tile with a one-partition row
`nl.broadcast_to` both partitions, from a `[2, 1]` tile (`acc = a * acc + b`) and from
`1.0` with both ops reversed (`acc = b - (acc - a)`), and takes `exp(a * c)` through
`activation`'s `scale`, its `scale` tile an `nl.zeros` without a `buffer` (a
hand-written `.expected`); a test widens its parsed broadcast to a shape its row
cannot take, which lowering rejects (`StatementError::BroadcastShape`).
`tests/fixtures/helper_call.py` imports `row_sums` from `tests/fixtures/helpers.py`
and calls it twice, by default and by keyword argument; `row_sums` builds its
`[partitions, 1]` shape with `list`, a `for` over its `axes` and an item write, as
`softmax_isa` does. Both modules also hold code no call reaches, using syntax the
subset lacks (a conditional expression, a dict, an f-string as a value), which is
never parsed.

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
