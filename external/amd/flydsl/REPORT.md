# `just flydsl` report, 2026-11-22

`just flydsl` (`external/amd/verify.py flydsl/`) on master at `bea15a6` plus the working tree,
on an Apple-silicon MacBook Pro. 36 cases, **12 min 46 s** in total.

**Result: 35 of 36 cases give their expected verdict.** The recipe exits 1 because of one
regression, `rope_d96` (see below).

## Summary

| | Cases |
|---|---|
| ACCEPT or VERIFIED, as expected | 28 |
| REJECT, REJECTED or ABORT, as expected (6 FlyDSL bugs, and Q and K swapped as a negative control) | 7 |
| **Unexpected verdict** | **1** (`rope_d96`: UNKNOWN, expected REJECT) |

`verify.py` prints `FAIL` for every case that does not verify, including the expected
rejections, which it marks `(expected)`. Only `rope_d96` is a real failure.

## Every case

| Case | Expected | Got | Outputs | Time |
|---|---|---|---|---|
| `flash_attn_gfx950` | ACCEPT | ACCEPT | 16384 | 484.2 s |
| `flash_attn_gfx950_swapped_qk` | REJECT | REJECT, 64 sampled outputs refuted | 64 of 16384 | 170.3 s |
| `gemm_nt` | ACCEPT | ACCEPT | 4096 | 3.2 s |
| `gemm_nn` | ACCEPT | ACCEPT | 4096 | 3.1 s |
| `gemm_tn` | ACCEPT | ACCEPT | 4096 | 3.0 s |
| `gemm_tt` | ACCEPT | ACCEPT | 4096 | 3.3 s |
| `gemm_nt_bf16` | ACCEPT | ACCEPT | 4096 | 3.3 s |
| `gemm_nt_bias` | ACCEPT | ACCEPT | 4096 | 3.7 s |
| `gemm_nt_block_k32` | REJECT | REJECT, 3072 refuted (first `out[8]`) | 4096 | 3.7 s |
| `gemm_tn_block_k32` | ACCEPT | ACCEPT | 4096 | 3.1 s |
| `gemm_nt_block_k32_fixed` | ACCEPT | ACCEPT | 4096 | 3.1 s |
| `gemm_hti` | REJECT | REJECT, LDS read/write conflict at shared byte 51200 | 65536 | 29.5 s |
| `gemm_hti_fixed` | ACCEPT | ACCEPT | 65536 | 29.4 s |
| `softmax` | ACCEPT | ACCEPT | 1024 | 0.7 s |
| `softmax_tail` | ACCEPT | ACCEPT | 300 | 0.2 s |
| `softmax_bwd` | ACCEPT | ACCEPT | 1024 | 0.9 s |
| `softmax_bwd_tail` | ACCEPT | ACCEPT | 300 | 0.1 s |
| `rmsnorm` | ACCEPT | ACCEPT | 1024 | 0.1 s |
| `rmsnorm_tail` | ACCEPT | ACCEPT | 300 | 0.0 s |
| `fused_add_rmsnorm` | ACCEPT | ACCEPT | 2048 | 0.5 s |
| `layernorm` | ACCEPT | ACCEPT | 128 | 0.5 s |
| `flash_attn_generic` | ACCEPT | ACCEPT | 4096 | 4.9 s |
| `flash_attn_generic_causal` | ACCEPT | ACCEPT | 4096 | 2.4 s |
| `flash_attn_generic_cross` | REJECT | REJECT, 64 sampled outputs refuted | 64 of 4096 | 2.7 s |
| `flash_attn_generic_cross_fixed` | ACCEPT | ACCEPT | 4096 | 5.5 s |
| `rmsnorm_block4` | ACCEPT | ACCEPT | 8 | 0.0 s |
| `rmsnorm_block4_tail` | REJECT | REJECT, `y[12]` and `y[13]` never written | 12 of 14 | 0.0 s |
| `rmsnorm_block4_tail_fixed` | ACCEPT | ACCEPT | 14 | 0.0 s |
| `vector_add` | ACCEPT | ACCEPT | 512 | 0.0 s |
| `vector_add_ragged` | ABORT | ABORT, 4-byte read at `0x207c0` past `B` | - | 0.0 s |
| `rope_d128` | ACCEPT | ACCEPT | 256 | 0.0 s |
| **`rope_d96`** | **REJECT** | **UNKNOWN**: wave 0 aborts at instruction 104 | 0 | 0.0 s |
| `rope_d96_fixed` | ACCEPT | ACCEPT | 192 | 0.0 s |
| `moe_sorting_p23_masked` | VERIFIED | VERIFIED | - | 0.0 s |
| `moe_sorting_p23` | REJECTED | REJECTED by the graph checks | - | 0.0 s |
| `moe_sorting_p23_fixed` | VERIFIED | VERIFIED | - | 0.0 s |

Where the two attention runs spend their time: `flash_attn_gfx950` is 8 of the 12.8 minutes and
`flash_attn_gfx950_swapped_qk` almost 3 more; every other case takes under 30 s.

## FlyDSL bugs reproduced

The bugs of `bugs.txt`, each with its fixed twin accepted (no twin for #7):

| # | Bug | Case | Verdict |
|---|---|---|---|
| 1 | MoE sorting P23: no barrier between the `cumsum` reads and writes | `moe_sorting_p23` | REJECTED (LDS race) |
| 2 | Fused RoPE: `tid ^ vecs_per_half` pairs the wrong lanes at head_dim 96 | `rope_d96` | **not reproduced in this run** |
| 3 | GEMM: swizzle wrong for `block_k = 32` | `gemm_nt_block_k32` | REJECT, 3072 of 4096 |
| 4 | GEMM, half-tile interleaved (default config): LDS races | `gemm_hti` | REJECT (LDS conflict) |
| 5 | Generic flash attention: KV padding mask dropped | `flash_attn_generic_cross` | REJECT (64 sampled) |
| 6 | RMSNorm: tail elements dropped | `rmsnorm_block4_tail` | REJECT, 2 never written |
| 7 | `01-vectorAdd.py`: out-of-bounds float4 on ragged rows | `vector_add_ragged` | ABORT |

## The regression: `rope_d96`

The AMD interpreter now stops at instruction 104 of `rope_d96.s`: *integer operand in lane 32
must be a concrete 32-bit word*. Lane 32 is one of the lanes bug 2 makes read an inactive lane.
Earlier today, with the code committed at `bea15a6`, the same case was REJECT. The current
working tree has uncommitted AMD frontend changes from parallel work (`eval/interp.rs`,
`eval/scalar.rs`, `eval/wave.rs`, `lower/mod.rs`, ...). Taking the `sqrt` change below back out
does not change the result. So the regression comes from those uncommitted changes, which now
produce a symbolic word where the committed code had a concrete one.

## Changes this run depends on (uncommitted)

1. **Exact `sqrt` of perfect-square constants** (`crates/volta_expr/src/symbolic_simplified/build.rs`).
   The dual-wave attention computes its scale as `1 / sqrt(head_dim_runtime)` with
   `head_dim_runtime = 64`. Unfolded, `sqrt(64)` was an opaque atom: `flash_attn_gfx950` was
   UNKNOWN even on 4 outputs (the numeric oracle agreed with the spec at every probe), at about
   0.9 s per output. With the fold it is ACCEPT on all 16384.
2. **`sample=64` for the two slow REJECT cases** (`cases.py`). A REJECT needs only some refuted
   outputs; refuting all 16384 of `flash_attn_gfx950_swapped_qk` ran for over 9.5 minutes
   without finishing.
3. **`volta.solve` renders outputs lazily** (`crates/volta_py/src/solve.rs`, `verify.py`).
   `SolveResult.outputs` printed every output expression as a tree with no sharing, before
   returning. For the attention kernel this went on for over an hour, while `verify.py` only
   counts the outputs. The expressions are now kept and printed only when `outputs` is read;
   `output_indices` gives the written indices, and `verify.py` counts with it.

## Reproduce

```sh
just flydsl                     # every case, about 13 minutes
cd external/amd/flydsl
../../../target/release/volta solve <case>.s --config <case>.launch.json
```
