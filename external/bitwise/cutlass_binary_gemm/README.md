# CUTLASS binary GEMM, 256×256

The standard CUTLASS SM80 `OpXorPopc` tensor-core GEMM, specialized to
**M=N=K=256**. Both inputs contain packed bits; the output contains i32 Hamming
distances:

```text
c[m,n] = sum(w=0..7, popc(a[m,w] xor b[n,w]))
```

A is logically row-major `[M,K]` and B column-major `[K,N]`, each occupying
`[256,8]` 32-bit words. C is row-major `[256,256]`. This is CUTLASS's native
binary operation: the signed ±1 dot product in `../binary_gemm.spec` is
`256 - 2*c[m,n]`. The specification here states XOR and population count directly.

`kernel.cu` instantiates the configuration from
[CUTLASS's SM80 binary GEMM tests](https://github.com/NVIDIA/cutlass/blob/ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e/test/unit/gemm/device/gemm_b1t_b1n_s32t_tensor_op_s32_sm80.cu),
test `64x256x512_64x64x512`. It invokes the library's unmodified GEMM mainloop and
epilogue. The small CUDA wrapper constructs CUTLASS's normal launch parameters
inside the kernel using constant dimensions; it is not a reimplementation of
the GEMM. No CUTLASS headers or generated PTX instructions are patched.

| Setting | Value |
|---|---|
| CUTLASS | v3.9.2, commit `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e` |
| CUDA compiler | 12.9, V12.9.86 |
| PTX | ISA 8.8, `sm_80` |
| Problem | M=N=K=256 |
| Threadblock / warp / instruction shapes | 64×256×512 / 64×64×512 / 16×8×256 |
| Pipeline stages | 3 |
| Launch | 4×1×1 blocks, 128 threads per block |
| Dynamic shared memory | 61,440 bytes |
| Epilogue | Integer linear combination, alpha=1, beta=0 |

The 512-bit mainloop tile zero-fills its unused K range; verification checks
that only the actual 256 input bits contribute. The native instruction is
`mma.sync.aligned.m16n8k256.row.col.s32.b1.b1.s32.xor.popc`.

**Result: ACCEPT for all 16,384 outputs of CTA 0** (its 64×256 tile of C), with
no sampling, on the unmodified compiler PTX. All ten graph checks pass;
`kernel.json` records the SHA-256 of the checked PTX. A negative control adding
one to the specification returns `REJECT` on a one-element sample.

From the repository root, reproduce extraction and verification with:

```sh
python3 external/bitwise/cutlass_binary_gemm/extract.py
cargo build --release -p volta_cli
target/release/volta solve external/bitwise/cutlass_binary_gemm/kernel.ptx \
  --config external/bitwise/cutlass_binary_gemm/kernel.launch.json --print-outputs 0
```

`extract.py` downloads the pinned CUTLASS tag, verifies its commit, and uses
local `nvcc` if available or Docker image
`nvidia/cuda:12.9.1-devel-ubuntu24.04`. No GPU is needed. To use an existing clean
checkout, add `--cutlass /path/to/cutlass`; `--backend local` or `--backend docker`
selects the compiler explicitly. The run creates `kernel.ptx` and `kernel.json`
(compiler, shapes, launch, source/PTX hashes). Both are checked in, so
verification needs no CUDA toolchain; a rerun reproduces them byte for byte.
The CUTLASS license is retained here.

`just bitwise` runs the same check. Volta analyzes CTA 0 of the 4×1×1 grid, so
the other three tiles of C are not checked. The spec's `ROW` dimension selects
the tile's first row (0) in the full inputs.

Volta models this exact binary MMA instruction as eight 32-bit
`popc(xor(...))` terms plus the integer accumulator, using the
[PTX fragment layouts](https://docs.nvidia.com/cuda/parallel-thread-execution/index.html#warp-level-matrix-fragment-mma-168256).
The evaluator snapshots all source fragments before writing destinations,
requires a full live warp, validates vector lengths and register widths, and
rejects unmodeled binary shapes/operators. The PTX test `test_mma_xor_popc`
snapshots all 128 outputs of one instruction, and a lowering test rejects
invalid instruction forms.

This is symbolic verification with Volta's integer model, not GPU execution.
For this kernel the accumulator starts at zero and remains in `[0,256]`, so
integer overflow cannot occur.
