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

## Instructions

Lowering accepts eight `nki.isa` instructions: `dma_copy`, `tensor_copy`,
`tensor_tensor`, `tensor_scalar`, `activation`, `activation_reduce`,
`nc_matmul` and `nc_transpose`. Their `nki.language` operands come from
`ArithOp` (`nl.add`, `nl.multiply`) and `ActivationFunc` (`nl.sigmoid`,
`nl.relu`, `nl.square`, `nl.rsqrt`); a new member means a variant in the enum's
`ALL` array, not a case in lowering.

Each activation is built from `volta_expr`'s primitives rather than an opaque
node, so the decision procedure can reason through it: `nl.rsqrt` becomes
`rcp(sqrt(x))` and `nl.relu` becomes `max(x, 0)`.

## Loops and regions

A `for` over `nl.affine_range(count)` is unrolled while the kernel is resolved,
since execution has no control flow; each iteration's tiles are named after its
index (`x.0`, `x.1`), so they stay distinct. The count must be a literal.

A subscript such as `a[0:4, :]` names a rectangular region, one slice per
dimension; `nisa.dma_copy` and `nisa.tensor_copy` copy between regions, and an
omitted bound means the tensor's own edge. An integer index is rejected, since
it would drop its dimension.

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

`tests/fixtures/matmul.spec` and `tests/fixtures/gemm_relu.spec` state the
`matmul` and `gemm_relu` kernels' math over the kernels' own array names, with
`a_t` as A transposed (`[K, M]`), the layout `nc_matmul`'s stationary operand
takes. `volta_pipeline`'s `trainium_equivalence_tests.rs` checks each kernel
against its spec by the decision procedure rather than by text, and `gemm_relu`
against `matmul.spec` (the product without the clamp) as a negative test;
`just trainium` runs them with this crate's tests.

`tests/fixtures/attention.spec` is the reference for the NKI attention samples
(`attention_fwd_v1` onward): `numpy_attention` from their `test_attention.py`
transcribed, in their layout, with `q`, `k` and `v` as `[D, N]` (head dimension
by sequence length) and the kernels' `kernel_out` as `[N, D]`. No kernel is
checked against it yet.
