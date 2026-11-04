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
