# AMD kernel libraries

Kernels from Aiter, AKLR, CLBlast, Composable Kernels, FlyDSL, HipKittens, MIOpen and Triton,
compiled for gfx950, each library in its own folder with a `cases.py` registry (Composable
Kernels' and Triton's cases are listed in `verify.py`). `verify.py` runs the cases.

## Results table

`table.py` runs every library's cases and writes `table.md`: per library, how many kernels Volta
tests and how many are correct or buggy, then every case's verdict. From the repository root:

```sh
uv run --reinstall-package volta --package volta python external/amd/table.py -j 4
```

- `-j N` runs N cases in parallel (the full run takes about 40 minutes at `-j 4`).
- `-o FILE` writes the table elsewhere (default `external/amd/table.md`).
- Library names (`"Composable Kernels" FlyDSL ...`) run only those libraries.

The Composable Kernels cases decided in Lean (`ck_hardswish`, `ck_leaky_relu`,
`ck_gemm_sigmoid`) need `$VOLTA_LEAN_PROJECT`, a Lake project with Mathlib built, given by the
environment or the repository's `.env`, and Claude Code to write a proof when the one in
`target/lean/<case>/` no longer matches its challenge.
