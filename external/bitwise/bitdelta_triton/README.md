# BitDelta upstream Triton kernels

Both JIT kernels from
[FasterDecoding/BitDelta](https://github.com/FasterDecoding/BitDelta/blob/ecbee1e28f6b02444d535e0a165b48cba3fe217a/bitdelta/binary_gemm_kernel.py),
commit `ecbee1e28f6b02444d535e0a165b48cba3fe217a`:

- `binary_matmul_kernel`: ordinary packed-sign matmul.
- `binary_bmm_kernel`: the same operation with independent inputs per batch.

The source snapshot and Apache 2.0 license are in `upstream/`; it is the only copy
of the kernels. `extract.py` checks the snapshot's SHA-256, imports it, and compiles
the `@triton.jit` function under each `@triton.autotune` directly, since the
autotuner would need a GPU to benchmark. The older AI-generated PTX example
is now in `../bitdelta_llm/`, with its original dimensions and math unchanged.

The compilation specializes **M=N=K=256**, with f16 A, i32 packed B, and f16 C.
An unpacked 256×256 weight matrix occupies **8×256 i32 words**. Each bit means
`+1` when set and `-1` otherwise; this is the same specification as the LLM
example, with an additional batch index for BMM. There is no scale, bias, or
activation in these upstream kernels.

Triton **3.5.1** compiles for **Hopper `sm_90a`**, PTX ISA 8.7. Upstream pins
Triton 2.0.0; these artifacts explicitly use 3.5.1 from the local extraction
toolchain. Compilation is offline and does not require a GPU. The first
upstream autotuning configuration is selected explicitly (no performance tuning):

| Setting | Matmul | Batched matmul |
|---|---:|---:|
| Tile M×N×K | 16×256×64 | 16×256×64 |
| Group size M | 8 | 8 |
| Warps | 8 | 4 |
| Pipeline stages | 3 | 3 |
| Threads/block | 256 | 128 |
| Grid | 16×1×1 | 16×2×1 |
| Dynamic shared memory | 165,888 bytes | 165,888 bytes |

Hopper accommodates this configuration's shared-memory requirement. Each
`*.json` records the compiler, target, constants, launch, and source/PTX hashes.
The `*.ptx` files are compiler output without manual edits. They and their
metadata JSON are checked in with the source, launch files and specs, so
verification needs no Triton toolchain; the extraction script regenerates them.

To compile on Linux with `triton==3.5.1` and `torch` (which upstream imports) installed:

```sh
python3 external/bitwise/bitdelta_triton/extract.py
```

On this Mac, the existing compiler image was used through Docker. From the
repository root (copying files also works when the VM does not mount the repo):

```sh
docker create --name volta-bitdelta-triton-extract --workdir /work \
  volta-tritonbench:triton-3.5.1-torch-2.9.0 python extract.py
docker cp external/bitwise/bitdelta_triton/. volta-bitdelta-triton-extract:/work/
docker start --attach volta-bitdelta-triton-extract
docker cp volta-bitdelta-triton-extract:/work/. external/bitwise/bitdelta_triton/
docker rm volta-bitdelta-triton-extract
```

To verify the first tile directly from the unmodified PTX:

```sh
cargo build --release -p volta_cli
for kernel in binary_matmul_kernel binary_bmm_kernel; do
  target/release/volta solve external/bitwise/bitdelta_triton/$kernel.ptx \
    --config external/bitwise/bitdelta_triton/$kernel.launch.json \
    --recycle-terms 1000000 --print-outputs 0
done
```

The launch files describe all 4,096 outputs of CTA (0,0,0), without sampling.
Their 16×256 output tile is contiguous with the original 256-element row stride,
so no output-stride patch is needed. Both return `ACCEPT`, and all ten graph
checks pass.

A negative control with the spec's sign flipped (`1 - 2 * bit`) returns `REJECT`
on a one-element sample. The renamed LLM example still returns `ACCEPT` on a
one-element regression sample, with all graph checks passing. The
`volta_expr` and `volta_equivalence` test suites pass (159 tests total).

Volta analyzes CTA (0,0,0) only, so the other 15 matmul tiles and the other
BMM tiles and batches are not checked.

Verification uses Volta's real-arithmetic model and graph checks, not an
on-GPU numerical test or a bit-exact floating-point rounding proof.

Triton's optimizer expresses the sign extraction as `((word >> (i-1)) & 2) - 1`
for bits 1–31 and `((word << 1) & 2) - 1` for bit 0. The previous bitfield
normalizer only recognized `& 1`, producing `UNKNOWN` for all outputs. The
normalizer now maps a non-sign single-bit mask to the corresponding input bit
times its power-of-two weight, preserving complemented bits. It excludes the
sign bit and multi-bit masks. Regression tests cover all 32 source bits, both
mask operand orders, and direct/complemented signs. The mathematical spec has
not been rewritten to match the compiler's optimized expression.
