# BitDelta matmul

The AI compiler's `sm_100a` kernel for PTX Gym's `BitDeltaNeurIPS2024Matmul`
(`../../ptx/ai_compiler/sm_100a/BitDeltaNeurIPS2024Matmul/kernel.ptx`): `c = a @ W`, where `a`
is f16 `[4096, 4096]` and `W[k, n]` is `+1` when bit `k % 32` of the i32 word `b[k / 32, n]` is
set, else `-1`. The kernel decodes each word into packed f16 `±1.0` pairs with shifts, `lop3`
delta swaps and a `prmt` (no numeric conversion), stores them to Tensor Memory, and multiplies them
by `a` with `tcgen05.mma`'s `[a-tmem]` form.

Volta follows a weight from the kernel to the spec in three steps:

1. **The instruction** (`volta_ptx_analysis`, `eval/arithm.rs`, `lop3_signed_ones`). The kernel's
   `lop3.b32 d, q, 0x80008000, 0xbc00bc00, 0x6a` is f16 -1.0 in each half with its sign bit
   flipped by `q`'s, so the analysis writes the packed pair `2 * bit - 1` for bits 15 and 31 of
   `q`, each bit the test `and(shr(q, i), 1)`. `tcgen05` then multiplies ordinary f16 pairs.
2. **Lowering** (`volta_expr`, `lower/bit_delta_pattern.rs`). `q` is the kernel's delta swaps, `prmt` and
   `shl` over `b[w, n]`. Lowering reads through them which input bit each test selects
   (`lower/word_bits.rs`) and writes it as that bit, `and(shr(b[w, n], i), 1)`.
3. **The spec** states the same bit, `and(shr(b[w, n], i), 1)`, so the canonical solver sees
   one opaque atom on both sides and compares polynomials over it.

`kernel_tile.ptx` is `kernel.ptx` with only the output row stride changed, from 4096 to 128 f16s,
so that CTA 0's 64 x 128 tile of `c` is a dense array: a spec's output must cover exactly the
elements a kernel writes. The math path is unchanged.

```sh
cargo run --release -q -p volta_cli -- solve external/bitwise/bitdelta_llm/kernel_tile.ptx \
  --config external/bitwise/bitdelta_llm/kernel_tile.launch.json --recycle-terms 1000000
```

The output has 8192 elements, each a 4096-term sum. With the default recycle bound, a session
overruns the solver's term-operation budget before it recycles; `--recycle-terms 1000000` avoids
that.

Result: `VERDICT: ACCEPT`. All ten graph checks pass, and all 8192 outputs are proved equal to the
spec: about 20 s of analysis, 23 minutes of solving and 10 GB peak memory on an M-series laptop.
With the spec's sign flipped (`1 - 2 * and(shr(b[w, n], i), 1)`), the solver refutes the outputs.
