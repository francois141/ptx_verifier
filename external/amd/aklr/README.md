# AKLR kernels (gfx950)

Kernels of [AKLR](https://github.com/AMD-AGI/AKLR), AMD's kernel library for LLM serving on MI355X,
at commit `766a200e367fac608a91db74b22e67fbf140397e` (2026-11-22), compiled for gfx950 and checked
by Volta: every output against a spec over the reals, and the event graph for LDS races. The
registry is `cases.py`; `build.py` compiles it and `external/amd/verify.py` runs it.

    just aklr                                      # check every case (verify.py aklr/)
    python3 external/amd/aklr/build.py [CASE...]   # recompile, rewrite assembly and launch files
    cd external/amd/aklr && ../../../target/release/volta solve <case>.s --config <case>.launch.json

AKLR stores each kernel in a schema, `aklr/ops/<op>/impls/<language>/<name>/<uuid>.json`, whose
`kernel.sources` hold its text. `build.py` checks AKLR out in `target/aklr/AKLR` and writes a case's
sources to `target/aklr/build/<case>/`, so every kernel is AKLR's own text.

## How the kernels are built

- **Triton** (`Triton`): the `@triton.jit` function of the schema's `kernel.py`, with the
  arguments and constexprs its `run` passes at the case's shape, compiled with Triton 3.9 (AKLR
  requires >= 3.8) in the `volta-gluon:triton-3.9.0-torch-2.15.0` image. Arguments are specialized
  as Triton's launcher specializes them on gfx950: an integer equal to 1 is a constexpr, pointers
  and multiples of 16 get `tt.divisibility`, and pointers get `tt.pointer_range=32` (a tensor under
  2 GB), so loads are buffer instructions.
- **HIP** (`Hip`): `<source>.hip` beside this file includes or splices (`// aklr: <file>
  <first>-<last>`) the schema's device code and instantiates the template its `run` launches for
  the case's shape; the torch binding is left out. clang 21 (Homebrew `llvm@21`), device only,
  `gfx950:xnack-`, `-O3`, against the HIP headers `external/amd/aiter/build.py` assembles, with
  Aiter's `prelude.h` for ockl's work-item ids.
- **FlyDSL** (`FlyDSL`): the schema's `kernel.py` run with `COMPILE_ONLY=1` in the `volta-flydsl:0.5.1`
  image (`external/amd/flydsl/extract.py` builds it), through the launcher its `run` calls.
- **Launch files** are written from the compiled kernel's own argument metadata. Volta runs
  workgroup 0; its output arrays hold exactly what that workgroup writes. Where it writes a column
  tile of a wider tensor, each row of the tile is its own array (`row_views`) at the address the
  tensor gives it.

## Cases (`just aklr`)

| Case | Kernel and configuration | Verdict |
|---|---|---|
| `rms_norm_triton` | `rms_norm_hidden_size6144` (Triton `_rms_kernel`), bf16 rows of 6144, three 2048-wide chunks, 4 warps | ACCEPT |
| `add_rms_norm_triton` | `add_rms_norm_hidden_size6144` (Triton), residual add + RMSNorm | ACCEPT |
| `add_rms_norm_hip` | `add_rms_norm_hidden_size6144` (HIP): the same op, DPP wave sums, one LDS exchange | ACCEPT |
| `gemm_rows_dot_m40`, `_m64` | `gemm_n32_k4096` (Triton `_rows_dot_kernel`): one output column a workgroup, BLOCK_M 1 (m = 40) and 2 (m = 64) | ACCEPT |
| `gemm_n6144_m2`, `_m16` | `gemm_n6144_k2048` (Triton), `_gemm_m16_kernel`: 16x32 tile, BLOCK_K 256, XCD remap; m = 2 (masked), 16 | ACCEPT |
| `gemm_n6144_m24`, `_m64` | the same schema's `_gemm_xcd_kernel`: 32x32 tile, BLOCK_K 64 unrolled 4, rotated K walk (m = 24, masked); 64x32, BLOCK_K 256 (m = 64) | ACCEPT |
| `lmhead_n62080_m8` | `gemm_n62080_k4096` (HIP), `gemm_stream.h`'s weight-streaming GEMM, DMA rings for b and a, Tile<16, 512, 1, 2, 3, 1, 8, 2> | ACCEPT |
| `lmhead_n25256_m6` (`_fixed`) | `gemm_n25256_k8192` (HIP), the same kernel, Tile<32, 243, 1, 5, 3, 1, 2, 1> | REJECT: bug 1 (`bug.txt`); fixed twin ACCEPT |
| `gemm_n2304_gemv_m8` (`_fixed`) | `gemm_n2304_k8192` (FlyDSL), its m <= 16 "gemv" kernel: 9 rows of b a workgroup, A and B staged by DMA through a 4-deep LDS ring | REJECT: bug 2; fixed twin ACCEPT |
| `paged_segment` | `paged_attention_decode` (Triton `_segment`), batch 1, 40 tokens over a shuffled block table: the 16 heads' split-KV partials (`acc`, then `m` and `l` in the log2 domain) against a generated spec of the softmax over the paged context | ACCEPT |
| `unified_segment` | `unified_attention` (Triton `_attn_segment`), one request of 8 queries over 40 tokens | REJECTED: see below |

The lm-head GEMM's `pack_bf16x2` rounds to bf16 with integer operations on the float's bits, which
Volta does not model on symbolic values, so every lm-head case replaces it with
`v_cvt_pk_bf16_f32`, which rounds the same way except on NaN (`HW_BF16_PACK`).

`unified_segment` runs to completion, but Triton's epilogue converts `m_i`'s layout through LDS
with two waves storing their copies of the same row maxima to the same LDS words, unordered.
Volta's memory-conflict check counts that as a write/write race: it has no exception for equal
values stored by different threads (`test_same_value_store_to_one_address_races`), and a graph
thread is a wave. On the hardware the values are equal, so it is benign; it is Triton's code
generation, not AKLR's source.

## What is checked, and what is not

- **Exact reals.** As everywhere in Volta, floats are exact reals: bf16 roundings are not modeled.
- **One workgroup.** Workgroup 0 of the grid runs. Cross-workgroup races, global-memory races and
  atomics are not checked, so the split-K paths, which spin on flags other workgroups raise (the
  lm-head GEMM for m > 64, the FlyDSL GEMMs between m = 17 and 192), are out of reach.
- **Served points.** AKLR's dispatch serves only the schema's listed workloads (its Points), so
  every case runs at a served shape.
- **Not checkable here.** AKLR's fp8/mxfp4 kernels (quantization, the a8w8 GEMMs, most MoE),
  integer outputs on LDS atomics (DSA top-k, top-k routing), and the mHC and Gluon kernels that
  pack or round values with integer operations on the data (mHC's int16 Gram, Qwen3.5 GDN decode,
  Kimi-K3 MLA). The FlyDSL kernels that import Aiter (the KDA conv) need an image with Aiter.
