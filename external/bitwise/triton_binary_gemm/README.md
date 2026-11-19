# Triton binary GEMM, 256×256

A binary XOR-popcount GEMM written in Triton, [kernel.py](kernel.py), specialized to
**M=N=K=256**. Both inputs hold packed bits, eight 32-bit words per row; the output
holds i32 Hamming distances, the same operation as CUTLASS's `OpXorPopc`
([../cutlass_binary_gemm/](../cutlass_binary_gemm/README.md)):

```text
c[m,n] = sum(w=0..7, popc(a[m,w] xor b[n,w]))
```

A is `[256, 8]` words (row m's bits), B is `[256, 8]` words (column n's bits) and C
is row-major `[256, 256]`. Each program computes a 16×256 tile one K-word at a time,
with CUDA-core `xor.b32` and `popc.b32`: Hopper and Blackwell have no XOR binary
tensor-core instruction, so this kernel runs natively on them.

| Setting | Value |
|---|---|
| Triton | 3.5.1 |
| Target | `sm_100a`, PTX ISA 8.7 |
| Tile | 16×256 outputs per program, `num_warps=4`, `num_stages=1` |
| Launch | 16×1×1 blocks, 128 threads per block, no shared memory |

`extract.py` compiles the kernel offline (no GPU) and writes `kernel.ptx`,
`kernel.json` (compiler, constants, source/PTX hashes) and `kernel.launch.json`.
All are checked in. On this Mac it runs in the Triton 3.5.1 image:

```sh
cd external/bitwise/triton_binary_gemm
docker create --name volta-triton-binary-gemm --workdir /work \
  volta-tritonbench:triton-3.5.1 python extract.py
docker cp kernel.py volta-triton-binary-gemm:/work/
docker cp extract.py volta-triton-binary-gemm:/work/
docker start --attach volta-triton-binary-gemm
for f in kernel.ptx kernel.json kernel.launch.json; do
  docker cp volta-triton-binary-gemm:/work/$f .
done
docker rm volta-triton-binary-gemm
```

From the repository root, verify (`just bitwise` runs the same check):

```sh
cargo build --release -p volta_cli
target/release/volta solve external/bitwise/triton_binary_gemm/kernel.ptx \
  --config external/bitwise/triton_binary_gemm/kernel.launch.json --print-outputs 0
```

**Result: ACCEPT for all 4,096 outputs of CTA 0** (its 16×256 tile of C), with no
sampling, on the unmodified compiler PTX; all ten graph checks pass. Volta
analyzes CTA 0 of the 16×1×1 grid, so the other fifteen tiles are not checked.
Negative controls: adding one to the spec is `REJECT`, and pairing `a[m,w]` with
`b[n,7-w]` is not proved (`UNKNOWN`).
