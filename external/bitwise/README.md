# Bitwise kernels

Kernels whose operands are bits packed into integer words. The word operations (`and`, `or`,
`xor`, `not`, `shl`, `shr`, `popc`) are opaque functions of their operands, in the full IR as in a
spec, which names them `and(a, b)`, `or(a, b)`, `xor(a, b)`, `not(a)`, `shl(a, n)`, `shr(a, n)`
and `popc(a)`.

| Kernel | Launch | Spec | Verdict |
|---|---|---|---|
| `binary_gemm.ptx` | `binary_gemm.launch.json` (8 x 8 outputs, K = 128) | `binary_gemm.spec` | ACCEPT |
| `cutlass_binary_gemm/kernel.ptx` | `cutlass_binary_gemm/kernel.launch.json` (M=N=K=256, CTA 0) | `cutlass_binary_gemm/binary_gemm.spec` | ACCEPT, all 16,384 tile outputs |
| `triton_binary_gemm/kernel.ptx` | `triton_binary_gemm/kernel.launch.json` (M=N=K=256, CTA 0) | `triton_binary_gemm/binary_gemm.spec` | ACCEPT, all 4,096 tile outputs |
| `bitdelta_llm/kernel_tile.ptx` | `bitdelta_llm/kernel_tile.launch.json` | `bitdelta_llm/bitdelta.spec` | ACCEPT (see `bitdelta_llm/README.md`) |
| `bitdelta_triton/binary_matmul_kernel.ptx` | `bitdelta_triton/binary_matmul_kernel.launch.json` (M=N=K=256, CTA 0) | `bitdelta_triton/bitdelta.spec` | ACCEPT, all 4096 tile outputs |
| `bitdelta_triton/binary_bmm_kernel.ptx` | `bitdelta_triton/binary_bmm_kernel.launch.json` (M=N=K=256, batch 0, CTA 0) | `bitdelta_triton/bitdelta.spec` | ACCEPT, all 4096 tile outputs |
| `simdjson/stage1.ptx` | `simdjson/stage1.launch.json` (4 rows of 4 blocks) | `simdjson/stage1.spec` | ACCEPT |
| `simdjson/escape.ptx` | `simdjson/escape.launch.json` (8 blocks) | `simdjson/escape.spec` | ACCEPT |
| `simdjson/structural_start.ptx` | `simdjson/structural_start.launch.json` (4 rows of 4 blocks) | `simdjson/structural_start.spec` | ACCEPT |
| `simdjson/indexer.ptx` | `simdjson/indexer.launch.json` (4 rows of 4 blocks) | `simdjson/indexer.spec` | ACCEPT |
| `simdjson/digits.ptx` | `simdjson/digits.launch.json` (8 fields) | `simdjson/digits.spec` | ACCEPT |

`binary_gemm.ptx` is an XNOR-popcount GEMM, `c[r, n] = K - shl(sum_w popc(a[r, w] ^ b[n, w]), 1)`:
the dot product of two rows of `±1` signs. The spec states those same operations; the solver
compares the opaque `popc`s inside the opaque `shl` as polynomials, and `xor`'s operands in either
order.

`bitdelta_llm/` is the previous `bitdelta/` AI-compiler example. `bitdelta_triton/`
contains the two original FasterDecoding/BitDelta Triton kernels compiled for
256×256 matrices; `just bitwise` checks CTA (0,0,0)'s 4,096 outputs of each. See
[the extraction and verification instructions](bitdelta_triton/README.md).

[`cutlass_binary_gemm/`](cutlass_binary_gemm/README.md) instantiates CUTLASS's
SM80 binary tensor-core GEMM at M=N=K=256. Its native `OpXorPopc` returns the
Hamming distance, `sum_w popc(a[m,w] ^ b[n,w])`; the older signed `binary_gemm.ptx`
above returns `K - 2 * distance`. `just bitwise` checks CTA 0's tile.
[`triton_binary_gemm/`](triton_binary_gemm/README.md) computes the same Hamming
distance in Triton with CUDA-core `xor` and `popc`, compiled for Blackwell (`sm_100a`).

```sh
cargo run --release -q -p volta_cli -- solve external/bitwise/binary_gemm.ptx \
  --config external/bitwise/binary_gemm.launch.json
```

`simdjson/stage1.cu` is simdjson's stage 1 on 32-character blocks, one thread per block: from
each block's quote and structural-character masks, the string regions by prefix XOR
(`x ^= x << 1`, then 2, 4, 8, 16) and the structural characters outside them, `op & ~in_string`.
A block starts inside a string when its row's earlier blocks hold an odd number of quotes, a sum
of `popc`s. The spec names each step of the prefix XOR with `let`. A spec without that carry
proves none of the 32 outputs (UNKNOWN; the numeric oracle cannot separate word operations).

`simdjson/escape.cu` is simdjson's escape scanner on independent 32-character blocks: adding each
backslash run's even-bit start to the backslash mask carries out of the run's end, which decides
the escaped characters, and the quotes that remain are the unescaped ones. A spec without the
addition proves none of its 16 outputs.

`simdjson/structural_start.cu` is stage 1's last step: where each structural character, string
and scalar begins, outside strings. It needs `stage1.cu`'s string regions, and a scalar may
continue from the previous block's last character, so a block reads its neighbor's masks. A spec
that ignores the neighbor proves only the 4 first blocks of its 16.

`simdjson/indexer.cu` computes the structural indexer's offsets: each block's structural
positions go to the tape after the row's earlier blocks', a sum of `popc`s, and each row's total.
The indexer's loop that writes each position (`tzcnt` over symbolic bits, stores at symbolic
addresses) is beyond Volta. An offset that counts its own block proves none of the 16 offsets.

`simdjson/digits.cu` is simdjson's `parse_eight_digits_unrolled` on 32-bit words: two SWAR
multiplies per word (2561, then 6553601) turn four ASCII digits into their value, and a field's
eight-digit value is its first word's times 10000 plus its second's. A spec with the two words
swapped proves none of the 8 values. Its multiplies are exact here: Volta's integers do not wrap.

clang folds some of simdjson's steps together (`~ODD_BITS` into `EVEN_BITS`, the complement of
the string tail into `~quote ^ in_string`), and each spec states the folded form.

```sh
for k in stage1 escape structural_start indexer digits; do
  /opt/homebrew/opt/llvm@21/bin/clang++ -x cuda --cuda-device-only -nocudainc -nocudalib \
    --cuda-gpu-arch=sm_80 -O3 -S -o external/bitwise/simdjson/$k.ptx external/bitwise/simdjson/$k.cu
done
```

The `.ptx` files are git-ignored (`/external/**/*.ptx`).
