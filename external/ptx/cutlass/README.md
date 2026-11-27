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
| the five `sm80_*` GEMMs, `gemm_bf16_tn_nosmem` | RACE-FREE, ACCEPT | |
| 19 other SM100 GEMMs and `conv2d_fprop_f16` | RACE-CONDITION | `bugs.txt` CL-1: every lane of the storing warp issues the same TMA store (equal values) |
| `gemm_mxfp8_blockscaled` | RACE-CONDITION | CL-1, and CL-2: the TMEM scale factors are refilled while earlier MMAs may read them |
| `gemm_bf16_tn_cpasync` | RACE-CONDITION | CL-1, and CL-3: no `fence.proxy.async` between the stage's `cp.async` writes and the MMA |
| `gemm_bf16_tn_streamk` | UNSUPPORTED | stream-K's acquire loads (cross-CTA atomic protocols) |
| `fmha_fwd_f16_d128` | inconclusive | the run stops at a branch on a symbolic predicate |

Each fixed copy in `patched/` (`cutlass.py --patched`, the `FIXES` of `bugs.txt`) is race free;
the GEMMs with a spec are also ACCEPT. `bugs.txt` gives each issue, the remaining Volta gaps, one
open lead and the Volta changes the kernels needed.
