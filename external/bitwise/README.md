# Bitwise kernels

Kernels whose operands are sign bits packed into integer words. The word operations (`and`,
`xor`, `shl`, `shr`, `popc`) are opaque functions of their operands, in the full IR as in a spec,
which names them `and(a, b)`, `xor(a, b)`, `shl(a, n)`, `shr(a, n)` and `popc(a)`.

| Kernel | Launch | Spec | Verdict |
|---|---|---|---|
| `binary_gemm.ptx` | `binary_gemm.launch.json` (8 x 8 outputs, K = 128) | `binary_gemm.spec` | ACCEPT |
| `bitdelta/kernel_tile.ptx` | `bitdelta/kernel_tile.launch.json` | `bitdelta/bitdelta.spec` | ACCEPT (see `bitdelta/README.md`) |

`binary_gemm.ptx` is an XNOR-popcount GEMM, `c[r, n] = K - shl(sum_w popc(a[r, w] ^ b[n, w]), 1)`:
the dot product of two rows of `±1` signs. The spec states those same operations; the solver
compares the opaque `popc`s inside the opaque `shl` as polynomials, and `xor`'s operands in either
order.

```sh
cargo run --release -q -p volta_cli -- solve external/bitwise/binary_gemm.ptx \
  --config external/bitwise/binary_gemm.launch.json
```

The `.ptx` files are git-ignored (`/external/**/*.ptx`).
