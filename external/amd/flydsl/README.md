# FlyDSL kernels (gfx950)

Kernels of [FlyDSL](https://github.com/ROCm/FlyDSL), AMD's Python kernel DSL, compiled for gfx950
at commit `304d441202a30e524971a0de49233121e5d17a51` (the `flydsl==0.5.1` wheel) and checked by
Volta: every output against a spec over the reals, and the event graph for LDS races. The
registry is `cases.py`; `extract.py` compiles it and `external/amd/verify.py` runs it.

    just flydsl                                   # check every case (verify.py flydsl/)
    python3 external/amd/flydsl/extract.py [CASE...]   # recompile, rewrite assembly and launch files

Seven cases reproduce a FlyDSL bug Volta found, and each has a twin built with the fix
(`cases.py`'s `Fix`es, applied to a copy of FlyDSL's sources), which Volta accepts.

## Files

- `cases.py`: each case's FlyDSL build (run in the container), its kernel arguments and arrays,
  its grid and workgroup, its spec and expected verdict, and any fixes.
- `extract.py`: compiles each case in a `linux/amd64` Docker container (`volta-flydsl:0.5.1`:
  `python:3.12-slim`, `flydsl==0.5.1`, CPU-only torch; `COMPILE_ONLY=1`, `FLYDSL_GPU_ARCH=gfx950`,
  `FLYDSL_DEBUG_DUMP_ASM=1`) from a checkout in `target/flydsl/FlyDSL`, then writes the launch
  file from the compiled kernel's own argument metadata: each tensor's address and FlyDSL's dynamic
  layout (shapes as i32s, then non-unit strides as i64s), each scalar, and the hidden arguments.
- `<case>.s` (the final ISA behind a provenance comment), `<case>.launch.json`, and the specs.

Volta runs workgroup 0 of the grid; every case's spec covers exactly what it writes.

## Cases

| Case | Kernel and configuration | Expected |
|---|---|---|
| `flash_attn_gfx950` | dual-wave flash attention, non-causal, bf16, S=384, D=64, eager rescaling | ACCEPT |
| `flash_attn_gfx950_swapped_qk` | the same kernel with the Q and K pointers swapped | REJECT |
| `flash_attn_generic` | generic flash attention, non-causal, bf16, S=64, D=64, the N32 tile | ACCEPT |
| `flash_attn_generic_causal` | the same, causal | ACCEPT |
| `gemm_nt`, `gemm_nn`, `gemm_tn`, `gemm_tt` | bf16 GEMM, f32 output, 64x64x256, 64x64x64 tiles, each layout | ACCEPT |
| `gemm_nt_bf16`, `gemm_nt_bias` | bf16 output; with a bias | ACCEPT |
| `gemm_tn_block_k32` | `block_k=32`, layout tn (both operands K-major in LDS) | ACCEPT |
| `softmax`, `softmax_tail` | softmax of a 1024-column row (vector path), a 300-column row (masked tail) | ACCEPT |
| `softmax_bwd`, `softmax_bwd_tail` | softmax backward, 1024 and 300 columns | ACCEPT |
| `rmsnorm`, `rmsnorm_tail` | RMSNorm, 1024 and 300 columns, f32 | ACCEPT |
| `rmsnorm_block4` | RMSNorm of an 8-column bf16 row with `BLOCK_THREADS=4` | ACCEPT |
| `fused_add_rmsnorm` | residual add, then RMSNorm, 1024 columns | ACCEPT |
| `layernorm` | LayerNorm, 128 columns | ACCEPT |
| `rope_d128` | fused NeoX RoPE + KV cache, bf16, head_dim 128 | ACCEPT |
| `moe_sorting_p23_masked` | MoE sorting's multiphase P23 kernel, E=8, topk=2, M=64, with an expert mask | VERIFIED |
| `vector_add` | `examples/01-vectorAdd.py`, 8x64 f32 | ACCEPT |

The row kernels run one row (M = 1), so workgroup 0 writes every output. LayerNorm runs 128
columns because its variance, expanded, has about N^2 monomials.

## Bugs

| Case (fixed twin: `<case>_fixed`) | Bug | What Volta reports |
|---|---|---|
| `moe_sorting_p23` | `p23_kernel` reads `cumsum[bid]` and `cumsum[bid + 1]`, then, with no expert mask, stores `cumsum[tid] = local_idx` with no barrier between (`moe_sorting_kernel.py:1627`): a wave holding lane `bid` can overwrite cells another wave has yet to read. The fix adds `gpu.barrier()` before the store. | REJECTED: 384 LDS read/write conflicts on `cumsum[0]` and `cumsum[1]` |
| `rope_d96` | `pair_lane = tid ^ vecs_per_half` (`fused_rope_cache_kernel.py:193`) is `tid +- 24` only when 24 is a power of two: lanes 8..15 pair with 16..23, and lanes 32..47 read inactive lanes. The fix is `(tid + vecs_per_half) % vecs_per_head`. | REJECT: 128 of 192 outputs refuted, e.g. `q_out[16]` uses `q[32]`, not `q[64]` |
| `gemm_nt_block_k32` | `Swizzle<3,3,3>` over `r * block_k + c` (`gemm_a16w16_gfx950_utils.py:273`) reaches row bit 0 when `block_k = 32`, while the loader assumes the row is kept: rows and columns with bit 3 set read their neighbor. Layouts nt, nn and tt are affected. The fix sizes the swizzle to `block_k`. | REJECT: 3072 of 4096 outputs refuted |
| `gemm_hti` | The default configuration (half-tile interleaved, 256x256x64, 2x4 waves): the two wave groups run one barrier apart, so (a) group 0's operand reads of `a1` are still in flight when group 1 stores C01 over the same bytes, and (b) the epilogue without split-K neither re-aligns the groups nor waits for LDS (`wait_vmcnt_and_barrier` waits on `vmcnt` only). LDS operations of different waves may reorder unless `s_waitcnt lgkmcnt(0)` precedes the barrier (LLVM's AMDGPU memory model). The fix needs all three: the wait after `load_a_fragment(1, 1)`, the re-alignment, and LDS waits at the epilogue's barriers. | REJECT: LDS read/write conflicts |
| `flash_attn_generic_cross` | The padding-mask dispatch picks the build without the KV mask when `seq_len % 64 == 0`, reading the query length only (`flash_attn_generic.py:692`): with 64 queries and 65 keys, the loader's clamp makes the 63 padded columns copies of key 64. The fix also checks `seq_len_kv`. | REJECT: all 4096 outputs refuted |
| `rmsnorm_block4_tail` | With fewer threads than tail elements, `if tid < TAIL_ELEMS` (`rmsnorm_kernel.py:357`, `:387`) covers the first `BLOCK_THREADS` of them: at 14 bf16 columns and 4 threads, 2 elements are left out of the sum and never stored. The fix strides the tail over the block. | REJECT: `y[12]` and `y[13]` never written |
| `vector_add_ragged` | `examples/01-vectorAdd.py` predicates each float4 on its first column only: at 62 columns the last float4 of a row covers two columns of the next, and on the last row reads and writes past both arrays. No fixed twin. | ABORT: a read 4 bytes past `B` |

## What is checked, and what is not

- **Exact reals.** As everywhere in Volta, floats are exact reals: bf16 roundings (`v_cvt_pk_bf16_f32`,
  `v_perm_b32` truncation) are not modeled, and `exp2(x * log2(e))` is `exp(x)`.
- **One workgroup.** Workgroup 0 of the grid runs; cross-workgroup races are not checked, and
  global memory is not checked for races.
- **Eager rescaling.** The dual-wave attention is compiled with `dualwave_swp_lazy_rescale=False`:
  the lazy default branches on a ballot over the data, which Volta cannot decide. The sliding-window
  kernel (`swa_gfx950.py`) always rescales lazily and is not included.
- **Masking by a finite score.** The causal dual-wave kernel (and its padded tails) masks with the
  score `-3e38`, so over the reals each masked key keeps the weight `exp(-3e38 - m) > 0`: its output
  is not exactly causal attention, and the canonical solver leaves it UNKNOWN (the numeric oracle
  agrees). It is not included; the generic kernel masks exactly and is.
- **Atomics.** The backward normalizations accumulate their weight gradients with global atomics,
  which Volta does not model; they are not included.
- **`ds_read_b64_tr_b16`.** The CDNA4 ISA describes this transposing read only in prose; Volta uses
  the lane mapping Triton's and FlyDSL's CDNA4 backends encode.
