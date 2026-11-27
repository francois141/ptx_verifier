# CUTLASS

Thirty CUTLASS kernel configurations (CUTLASS at the commit `../sources/frameworks.txt` pins),
each launched as CUTLASS's own host code launches it and checked by `races.py --framework cutlass`.

```sh
uv run external/ptx/extraction/fetch_sources.py cutlass   # target/ptx-sources/cutlass
uv run external/ptx/extraction/cutlass.py                 # PTX + launch files (Docker, nvcc 12.9)
python3 external/ptx/races.py --framework cutlass         # output/cutlass.csv
```

## How a launch is made

`units/<unit>.cu` instantiates one configuration and is also a host program
(`harness/volta_launch.h`). It builds the kernel's `Params` with CUTLASS's
`to_underlying_arguments` (for 2.x kernels, as `device::Gemm::initialize` does) over fake device
pointers, so the struct's every byte is CUTLASS's. The driver's TMA encoders are replaced by
stand-ins that record their arguments and stamp each descriptor, so the launch file gives each
descriptor by its fields; no GPU or driver is needed. Grid, block and shared memory come from the
kernel's `get_grid_shape`, `get_block_shape` and `SharedStorageSize`. SM100 GEMMs run on one
persistent CTA (`sm_count` 1) under `StaticPersistentScheduler`, so CTA 0 runs every tile, the
stage ring wraps and the TMEM accumulators are reused; `specs/` states each output.

## Units and verdicts

| Units | Verdict | Why |
|---|---|---|
| `sm80_bf16_tensorop_relu` | RACE-FREE, ACCEPT | |
| 14 SM100 TMA GEMMs | RACE-CONDITION | `bugs.txt` CL-1: every lane of the storing warp issues the same TMA store (equal values); each fixed copy in `patched/` is race free, 12 also ACCEPT |
| `gemm_bf16_tn_beta`, `gemm_bf16_tn_col_bias`, `gemm_bf16_tn_row_bias_relu` | ERROR | a packed bf16 pair used as a scalar in the C or bias fusion |
| `sm80_f16_tensorop`, `sm80_f16_batched`, `sm80_sgemm_simt`, `sm80_tf32_tensorop`, `gemm_bf16_tn_cpasync` | UNSUPPORTED | generic (spaceless) `ld`/`st` |
| `gemm_bf16_tn_nosmem`, `gemm_e4m3_blockwise` | UNSUPPORTED | TMA into shared memory off the 1024-byte swizzle boundary |
| `gemm_tf32_tn_128x128` | UNSUPPORTED | `tcgen05.mma.kind::tf32` |
| `gemm_mxfp8_blockscaled` | UNSUPPORTED | block-scaled MMA scale factors at TMEM lane offsets |
| `gemm_bf16_tn_streamk` | UNSUPPORTED | an untyped `ld` the parser rejects |
| `fmha_fwd_f16_d128` | UNSUPPORTED | `cvta.local` |
| `conv2d_fprop_f16` | UNSUPPORTED | the `im2col_no_offs` TMA store form |

`bugs.txt` gives the issue, the Volta gaps and the four Volta changes the SM100 kernels needed
(cluster launch control multicast, warp collectives in `G0`, mbarrier completions in `G0`, and
async completions carrying the async effects that reached their issue).
