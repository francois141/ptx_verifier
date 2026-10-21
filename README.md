<p align="center">
  <img src="docs/volta-logo.png" alt="Volta logo" width="400">
</p>

Volta checks NVIDIA PTX kernels for data races and deadlocks, and proves a kernel equivalent to a reference kernel or a math spec (floats are modeled as reals). This is an experimental fork of [Volta](https://github.com/willtunnels/volta).

Kernels must have statically known sizes, and their addresses and branches must resolve from thread indices and concrete parameters, not from input values. Only CTA 0 is executed; it stands for every CTA of the grid.

## Build

```bash
cargo build --release   # the binary is target/release/volta
just test               # Rust and Python tests
```

`cargo run --release -p volta_cli -- <command> ...` builds and runs in one step.

## CLI

### Launch flags

`analyze`, `verify` and `compare` share these flags. They must match the kernel's parameters.

- `-b, --block X[,Y[,Z]]` / `-g, --grid X[,Y[,Z]]`: launch dims (default `1`)
- `--array name:base:elem_width:len:kind`: a global array of `len` elements of `elem_width` bytes at address `base`; `kind` is `in`, `out`, `inout` or `index` (concrete `a[i] = i`). Repeatable.
- `--param int:N | float:X | sym:name | ptr:array`: the kernel's parameters, in declaration order. Repeatable.
- `--global NAME=value`: value of a module-scope `.global` variable. Repeatable.
- `--dyn-shared N`: dynamic shared memory, in bytes
- `--no-profile`: skip the per-instruction-kind profile

### Check a kernel for races and deadlocks

```bash
volta analyze relu.ptx -k relu -b 128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out
```

Prints the symbolic outputs (`--print-outputs N`, default 8 per array), the verdict of each graph check, and `GRAPH VERIFICATION: VERIFIED | REJECTED | UNKNOWN` (exit 0/1/2). `--emit-exprs FILE` writes the outputs as `.vexpr` text, `--dump-graph FILE` the event graph.

### Check a kernel against a spec

```
# relu.spec
dim N;
array x[N];
array out[N];
out[i] = max(x[i], 0);
```

```bash
volta verify relu.ptx relu.spec -k relu -b 128 --dim N=128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out
```

The spec can also be passed inline as a string. Each spec output must be declared `out` or `inout`, and each `dim` needs a `--dim NAME=VALUE`.

### Compare two kernels

```bash
volta compare ref.ptx opt.ptx --kernel1 ref --kernel2 opt -b 128 \
  --array x:0x10000:4:128:in --array out:0x20000:4:128:out \
  --param ptr:x --param ptr:out --check-array out
```

`--check-array NAME` (required, repeatable) names the outputs to compare. Arrays, params and globals are shared by both kernels; `--block2`/`--grid2` override the optimized kernel's dims.

`verify` and `compare` print `VERDICT: ACCEPT | REJECT | UNKNOWN` (exit 0/1/2) and take:

- `--sample N`: check at most N elements per array (a sampled check is never ACCEPT)
- `--verify-numeric`: confirm each verdict with an f64 oracle at random inputs
- `--recycle-terms N`: bound memory by recycling intern tables past N terms
- `--iterations N`: re-run the solve N times (timing and determinism check)

`compare` can skip symbolic execution: `--exprs a.vexpr b.vexpr` (from `analyze --emit-exprs`), or `--dump-vcs pair.vcdump` once and then `--from-dump pair.vcdump`.

### Other commands

- `volta parse file.ptx`: syntax check
- `volta viz <run-store> -o page.html`: the event-graph viewer (`just viz` builds it over every test run)

Every run writes a log under `volta-logs/` (`--log-dir DIR`, `--no-log-file`). Build with `--features logging` and pass `--log-level info` for a trace of the run.

## Python

Add the bindings to your project's `pyproject.toml`, then run `uv sync`:

```toml
[project]
dependencies = ["volta"]

[tool.uv.sources]
volta = { path = "<path/to/volta>/crates/volta_py", editable = true }
```

```python
import volta

src = open("relu.ptx").read()

config = volta.Config(block=(128, 1, 1), grid=(1, 1, 1), dynamic_shared_bytes=0)
config.add_array(volta.ArrayDef("x", base=0x10000, elem_width=4, len=128, kind=volta.ArrayKind.Input))
config.add_array(volta.ArrayDef("out", base=0x20000, elem_width=4, len=128, kind=volta.ArrayKind.Output))
config.add_param(volta.Param.array_ptr("x"))  # also Param.int, Param.float, Param.sym_float
config.add_param(volta.Param.array_ptr("out"))
# config.set_global("NAME", 42)

volta.parse(src)  # raises VoltaError on a syntax error

result = volta.analyze(src, config, kernel="relu")
result.outputs        # [("out", [(0, "max(x[0], 0)"), ...])]
result.race_verified  # True when every graph check passed
result.stats, result.op_counts

spec = "dim N; array x[N]; array out[N]; out[i] = max(x[i], 0);"
check = volta.verify(src, spec, config, kernel="relu", dims={"N": 128}, sample=0, verify_numeric=False)
check.equivalent, check.mismatches, check.elements_checked
```

`ArrayKind` is `Input`, `Output`, `InputOutput` or `IndexInput`. A race raises `volta.DataRaceError`, a deadlock `volta.DeadlockError`, and any other failure `volta.VoltaError` (the base class of both). An inconclusive graph check emits a `RuntimeWarning` and sets `race_verified` to `False`. `compare` is CLI-only for now.

## Citation

```bibtex
@misc{costa2026aicompilercompilingtriton,
      title={AI as a Compiler: Compiling Triton kernels without the Triton compiler},
      author={François Costa and Charly Castes and Thomas Bourgeat and Azalia Mirhoseini},
      year={2026},
      eprint={2609.36800},
      archivePrefix={arXiv},
      primaryClass={cs.AI},
      url={https://arxiv.org/abs/2609.36800},
}
```

```bibtex
@article{volta,
  author    = {Driscoll, Benjamin and Dubey, Kshitij and Wei, Anjiang and Kayal, Neeraj and Sharma, Rahul and Aiken, Alex},
  title     = {Equivalence Checking of {ML} {GPU} Kernels},
  journal   = {Proc. ACM Program. Lang.},
  volume    = {10},
  number    = {OOPSLA2},
  articleno = {338},
  numpages  = {28},
  year      = {2026},
  doi       = {10.1145/3839470}
}
```

## License

MIT — see [LICENSE](LICENSE).
