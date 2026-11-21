# Triton tutorial kernels on AMD

Triton's classic tutorial kernels (triton-lang.org, "Getting Started"), in fp32, compiled for AMD
gfx950 (CDNA4) and checked against a spec each. `kernels.py` holds them with every size a
`constexpr`; `extract.py` compiles each case offline and writes `<case>.s` (the AMDGCN assembly),
`<case>.json` (compiler, constants, hashes) and `<case>.launch.json`. Volta runs workgroup 0 of
the grid, so each launch file's output arrays are what that workgroup writes.

| Setting | Value |
|---|---|
| Triton | 3.5.1 |
| Target | `hip`, `gfx950`, wave64 |
| Workgroup | `num_warps=4`: 256 work-items in 4 waves |

| Case | Tutorial | Size | Grid | LDS | Spec |
|---|---|---|---|---|---|
| `vector_add` | 01 vector addition | 4096 elements, blocks of 1024 | 4 | none | `vector_add` |
| `softmax` | 02 fused softmax | 4 x 100, 128-lane blocks, one program looping over the rows | 1 | 8 bytes | `softmax` |
| `matmul` | 03 matrix multiplication | M=128, N=64, K=64, tiles 32 x 64 x 16, `GROUP_SIZE_M=8` | 4 | 6 KiB | `matmul` |
| `matmul_leaky_relu` | 03, with its fused `leaky_relu` | the same | 4 | 6 KiB | `matmul_leaky_relu` |
| `layer_norm` | 05 layer normalization, forward | 4 x 100, 64-lane blocks, eps f32(1e-5) | 4 | none | `layer_norm` |

Every case is ACCEPT: all its outputs proved equal to its spec, and every graph check passes. The
tutorials use fp16 operands for the GEMM; here they are fp32, so `tl.dot` is
`v_mfma_f32_16x16x4_f32` (`matrix_instr_nonkdim=16`). Softmax's 100 columns and layer norm's 100
leave a partly masked block: softmax loads `-inf` there, which drops out of the max and the sum.
Layer norm also stores each row's mean and reciprocal standard deviation, which its spec states.

## What the compiled kernels use

Triton's AMD code differs from the Composable Kernel examples beside it in ways the AMD frontend
models as follows:

- Kernel arguments are preloaded into SGPRs (`.amdhsa_user_sgpr_kernarg_preload_length`), with
  the compatibility prologue that loads the same dwords on older firmware.
- LDS is allocated at launch (`metadata.shared`), so each launch file's `dynamic_shared_bytes`
  is added to the descriptor's fixed group segment.
- Global accesses take 64-bit VGPR-pair addresses (`off`), built with `v_lshl_add_u64` or
  `v_add_co_u32`/`v_addc_co_u32`.
- `tl.max` and `tl.sum` reduce within a wave with DPP (`row_shr`, `row_bcast`, `quad_perm`) and
  `v_readlane_b32`, then across waves through LDS. A DPP lane whose source the ISA leaves
  unspecified (a row `row_bcast` does not reach) gets a fresh unknown value, so no output may
  depend on it.
- `/` is LLVM's IEEE division sequence (`v_div_scale`, `v_rcp`, Newton steps, `v_div_fmas`,
  `v_div_fixup`). Its 2^±64 scaling only guards the f32 range, so over Volta's reals no step
  scales and the steps compute the exact quotient.
- `tl.exp` is LLVM's denormal-safe `exp2`, `2^(a + (c ? 64 : 0)) * 2^(c ? -64 : 0)`: the two
  selects between constant words stay selects whose readers interpret their bits, and the
  `v_ldexp_f32` that undoes the shift folds the pair to `2^a`.

## Running

`just amd_triton` runs every case through `external/amd/verify.py`. One case runs with

```sh
volta solve external/amd/triton/softmax.s --config external/amd/triton/softmax.launch.json
```

## Building

`extract.py` runs under `triton==3.5.1` on Linux (no GPU) and needs no ROCm installation. On this
Mac it runs in the `volta-tritonbench:triton-3.5.1` image, from this directory:

```sh
docker create --name volta-triton-amd --workdir /work \
  volta-tritonbench:triton-3.5.1 python extract.py --out /work/out
docker cp kernels.py volta-triton-amd:/work/
docker cp extract.py volta-triton-amd:/work/
docker start --attach volta-triton-amd
docker cp volta-triton-amd:/work/out/. .
docker rm volta-triton-amd
```

Case names after `extract.py` build only those.
