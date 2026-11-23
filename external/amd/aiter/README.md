# Aiter kernels (gfx950)

Kernels of [Aiter](https://github.com/ROCm/aiter), AMD's AI Tensor Engine for ROCm, compiled for
gfx950 at commit `183a6ce66ebb975223534f3bdeaca4132d2f4530` (2026-11-22) and checked by Volta:
every output against a spec over the reals, and the event graph for LDS races. The registry is
`cases.py`; `build.py` compiles it and `external/amd/verify.py` runs it.

    just aiter                                    # check every case (verify.py aiter/)
    python3 external/amd/aiter/build.py [CASE...]  # recompile, rewrite assembly and launch files

Some cases reproduce an Aiter bug that Volta found. Where the fix is in the kernel, a `_fixed` twin
(`cases.py`'s `Fix`es, applied to the kernel text before it compiles) shows that Volta accepts
the fixed kernel.

## How the kernels are built

- **HIP kernels** (`<source>.hip`). Each file includes Aiter's headers. Its
  `// aiter: <path> <first>-<last>` lines are replaced by those lines of Aiter's source file at the
  pinned commit, so the kernel text is Aiter's own. The rest of the file explicitly instantiates
  the template that Aiter's host dispatch picks for the case's shape (the comment at the top of
  each file names that dispatch).
- **Compiler.** clang 21 (Homebrew `llvm@21`), device only, for `gfx950:xnack-`, with the flags
  `aiter/jit/core.py` passes under HIP 7.0 (`-O3`, `-fgpu-flush-denormals-to-zero`, kernarg preload,
  early inlining, ...), plus the module's own flags from `aiter/jit/optCompilerConfig.json`.
  `-nogpulib` replaces ROCm's device library with `prelude.h` (ockl's work-item functions and the
  ocml math the kernels call). `NDEBUG` compiles out device asserts, whose printf that library
  would provide.
- **Checkouts.** `build.py` checks Aiter out in `target/aiter/aiter` (with its pinned Composable
  Kernel submodule). It assembles the HIP, CLR and rocPRIM headers of ROCm 7.0.2 in `target/aiter/hip`.
- **Launch files.** `build.py` writes each launch file from the compiled kernel's own argument
  metadata: each pointer, scalar or by-value struct the case gives, then the hidden arguments.

Volta runs workgroup 0 of the grid. Each case's output arrays hold exactly what that workgroup
writes, so a write outside them is visible.

## Cases

| Case | Kernel and configuration | Verdict |
|---|---|---|
| `silu_and_mul`, `_d200` | `aiter.silu_and_mul`, bf16, d=4096 (8 waves, 8-wide) and d=200 (one partial wave) | ACCEPT |
| `silu_and_mul_bias` | `aiter.silu_and_mul_bias`, bf16 with fp32 expert bias, expert ids as concrete input | ACCEPT |
| `rmsnorm_hip`, `_1024` | `aiter.rms_norm`'s HIP kernel (`add_rmsnorm_quant_kernel`, no quant), bf16 rows of 4096 and 1024 | ACCEPT |
| `add_rmsnorm_hip` | `rmsnorm2d_fwd_with_add`, the same kernel with the residual add, rows of 4096 | ACCEPT |
| `rmsnorm`, `rmsnorm_rows`, `rmsnorm_strided` | opus RMSNorm (`rms_norm_opus`): one 4096-row; four 512-rows in one workgroup (segmented LDS reduction); row-strided input | ACCEPT |
| `fused_add_rmsnorm` | `rmsnorm2d_fwd_with_add_opus` (out-of-place residual add), 4096 | ACCEPT |
| `fused_qk_rmsnorm` | `aiter.fused_qk_rmsnorm`, bf16 q/k heads of 1024, m < 4096 (one row per workgroup) | ACCEPT |
| `groupnorm_up`, `groupnorm_down` | `aiter.groupnorm_run`'s two kernels, fp32 [2, 64, 32], 32 groups | ACCEPT |
| `groupnorm_down_align4` | the down kernel's 4-wide path, [128, 64, 61444] | ACCEPT |
| `moe_sum`, `moe_sum_topk4` | `aiter.moe_sum`, fp32, top-2 over 2048 and top-4 over 704 | ACCEPT |

## RoPE and KV-cache kernels (`rope_cache/`) and Triton kernels (`triton/`)

These come from the reviews' probes, one launch file per case beside the kernel it runs
(`volta solve <kernel>.s --config <case>.launch.json` from the folder). `rope_cache/` holds HIP
kernels built by `rope_cache/build.sh`, which uses this folder's flags; the `rope` probes include
`rope/rope_common.h` and the cache probes copy their kernel's lines of `cache_kernels.cu`.
`triton/` holds Aiter's Triton kernels, compiled offline by `triton/compile_case.py` (Triton 3.5.1
for the `.t3.5.1` cases, else 3.9) with their arguments specialized as Triton's launcher does.

| Case | Kernel | Verdict |
|---|---|---|
| `rope_cache/pos2c_neox_vp2`, `_vp1`, `pos2c_gptj_vp1` | `rope_cached_positions_2c_fwd` (`kn_entry_2c_sbhd_cached_indirect`), bf16, GQA 4/2 heads, rotary 64 of 128 | ACCEPT |
| `rope_cache/posenc_f32_neox` | vLLM-style `rotary_embedding` (pos_encoding), fp32, separate output pointers | ACCEPT |
| `rope_cache/rope2d_noreuse` | `rope_2d_fwd` (`kn_entry_1c_2d_cached`), fp32 | ACCEPT |
| `rope_cache/rac_f32` | `reshape_and_cache`, fp32 | ACCEPT |
| `rope_cache/cacm_opt_f32_r512_p64` | `concat_and_cache_mla` (opt kernel), fp32 | ACCEPT |
| `rope_cache/hpt_bf16` | `fused_qk_rope_concat_and_cache_mla` (DeepSeek MLA decode, HPT kernel), bf16 | ACCEPT |
| `rope_cache/xor_partner_f32_rd64` | `fused_qk_norm_rope_cache_quant_shuffle` (`fusedQKNormRopeQuantCacheShuffleKernel`), fp32, rotary 64 | ACCEPT |
| `triton/mha_bf16_d64_h1_nolse.t3.5.1.full` | flash attention `_attn_fwd`, bf16, head 64, 128 queries, 100 keys (masked tail) | ACCEPT |
| `triton/ea_extend_bf16_d64` | extend attention `_fwd_kernel`, bf16, causal, prefix through `kv_indices` (about 5 min) | ACCEPT |
| `triton/ng_gemm_m16`, `ng_gemm_tail` | `gemm_a16w16`, bf16; M=20 N=40 K=200 with bias and relu | ACCEPT |
| `triton/rmsnorm_fp32_64`, `ng_rms_tail`, `ng_rms_lmsn` | `_rms_norm_kernel` | ACCEPT |
| `triton/ng_addrms_*` | fused add + rmsnorm | ACCEPT |
| `triton/ng_ln_fp32_*`, `ng_addln_fp32_100` | layernorm, fused add + layernorm | ACCEPT |
| `triton/ng_reduce` | gemm split-K reduce with bias and silu | ACCEPT |
| `triton/rc_rope_thd2c_*` | Triton RoPE, thd layout | ACCEPT |
| `triton/rc_silu_mul_f32`, `rc_silu_mul_bwd_f32` | `silu_and_mul` and its backward | ACCEPT |
| `triton/rc_kv_cache_mla_bf16` | `cat_and_cache_mla` | ACCEPT |

## Bugs

All bugs Volta found, with each fixture, its configuration, the cause and the fix, are in
`bug.txt`. The ones in this folder's `cases.py`:

| Case (fixed twin) | Bug | What Volta reports |
|---|---|---|
| `fused_qk_rmsnorm_rows` (`_fixed`) | `fused_qk_rmsnorm_kernel`'s row loop (`fused_qk_norm.cu:84`) calls `block_reduce` once per row with no barrier between rows, although `hip_reduce.h:387` requires one between two calls: a fast wave's partial for row r+1 overwrites the LDS slot a slow wave has yet to read for row r. Reached by `aiter.fused_qk_rmsnorm` (no quant) whenever m >= 4096 (num_row 4, or 2 above 2048 columns) and the heads span more than one wave. The fix adds `__syncthreads()` before each later row's reduction. | REJECT: LDS write/read conflicts on `block_reduce`'s staging buffer, and 1536 outputs refuted (first `q_out[512]`); the fixed twin ACCEPT |
| `groupnorm_down_straddle` | The host takes the 4-wide path when `inner_size % 4 == 0` (`groupnorm.cu:300`) but never checks the channel length: each 4-vector reads one channel's weight and bias (`groupnorm.cu:170`), so at a channel length that is not a multiple of 4 the vectors straddling a channel boundary use the wrong channel's affine parameters. Shapes such as [N, 512, 8001] with 32 groups, or FPN's [N, 256, 125, 126], reach it. The fix also requires `numel_per_channel % 4 == 0` (the scalar path is then taken). | REJECT: exactly `y[61442]` and `y[61443]` (channel 1's first elements) refuted; they use `weight[0]`, `bias[0]` |
| `silu_and_mul_odd_d` | `act_and_mul_kernel` rounds its buffers' sizes up to whole words (`activation_kernels.cu:55-63`) and has no tail loop, so for an odd d the last 2-element vector reads the next row's first element and stores into the next token's `out[t + 1, 0]`, racing its workgroup (and writing past `out` for the last token). Nothing in `silu_and_mul`, its dispatch or the Python wrapper rejects an odd d; `scaled_act_and_mul` already has the scalar tail this kernel lacks. The same rounding is in `swiglu_and_mul` and the `_bias` variants. | REJECT: workgroup 0 writes `out[65]`, token 1's first output |
| `gelu_fast_ragged` | `activation_kernel_vec` (`activation_kernels.cu:2091`) loads and stores whole vectors, predicated on their first element only: when numel is not a multiple of VEC_SIZE (any numel >= 320 not a multiple of 8, or e.g. 131), the last vector reads and writes past the tensor. `relu2` was moved to `activation_kernel_vec_safe`, which bounds every element; `gelu_fast` still uses the unsafe kernel. | ABORT: a read 4 bytes past `input` |

## What is checked, and what is not

- **Exact reals.** As everywhere in Volta, floats are exact reals: bf16 roundings
  (`v_cvt_pk_bf16_f32`) are not modeled, and `exp2(x * log2(e))` is `exp(x)`.
- **One workgroup.** Workgroup 0 of the grid runs. Cross-workgroup races, global-memory races and
  atomics are not checked. A workgroup writing outside its own outputs is visible.
- **In-place kernels.** Volta's arrays are input or output, so the in-place RoPE, rotary
  embedding and fused-add kernels are checked through their out-of-place forms, or with a probe
  writing to separate outputs (`posenc`, `xor_partner`; noted in each `.hip`).
- **Not checkable here.** Integer outputs (MoE sorting/alignment, top-k ids) are not compared
  against specs, and LDS atomics (`moe_align_block_size`) are not modeled. `gelu_fast`'s
  `fast_tanh` branches on `|x|` of the data, so only its out-of-bounds access is checked. fp8/int8
  quantized outputs are not modeled. The opus flash-attention forward rescales lazily, a branch on a
  wave ballot over the data.
- **bf16 storage.** Aiter's HIP-typed (`hip_bfloat16`) kernels round in software with bit
  operations on the data, so `moe_sum` is checked in fp32.
