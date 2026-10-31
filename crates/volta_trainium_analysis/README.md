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

## Fixtures

`tests/fixtures/add.py` adds two 128 x 128 tensors elementwise: it copies `a`
and `b` from HBM into SBUF tiles (`nisa.dma_copy`), adds the tiles
(`nisa.tensor_tensor` with `op=nl.add`), and copies the sum back to `out` in
HBM.
