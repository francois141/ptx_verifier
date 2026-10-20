<p align="center">
  <img src="docs/volta-logo.png" alt="Volta logo" width="400">
</p>

## Crate overview

```
          +-------------------------------------------------------------+
          |  volta_cli                                      volta_py    |
          |  `volta` binary:                                Python      |
          |  analyze, compare,                              bindings    |
          |  verify                                                     |
          +-------------------------------------------------------------+
                 |   front ends: wire a producer to a consumer
                 v

     kernel.ptx                                             kernel.spec
         |                                                       |
         v                                                       v
 +----------------+     AST     +------------------+     +----------------+
 | volta_frontend | ----------> |  volta_analysis  |     |   volta_spec   |
 | PTX lexer,     |             | lowering,        |     | parser for the |
 | parser, typed  |             | symbolic exec,   |     | .spec language |
 | instructions   |             | race + deadlock  |     |                |
 +----------------+             | detection        |     +----------------+
                                +------------------+             |
                                         |                       |
                          kernel outputs |   as SymbolicOutputs  | unfolded spec
                                         v                       v
                    +------------------------------------------------------+
                    |                      volta_expr                      |
                    |  the shared expression language: arena, specs,       |
                    |  SymbolicOutputs, .vexpr text format (no deps)       |
                    +------------------------------------------------------+
                                         |  two SymbolicOutputs: reference vs
                                         |  optimized kernel, or kernel vs spec
                              +----------+--------------+
                              v                         v
                   +---------------------+   +---------------------+
                   |  volta_equivalence  |<--|      volta_z3       |
                   |  canon decision     |   |  Z3 baseline: same  |
                   |  procedure, f64     |   |  VCs as SMT-LIB2,   |
                   |  oracle, .vcdump    |   |  solved by libz3    |
                   +---------------------+   +---------------------+
                              |                         |
                              v                         v
                    per-output-element verdict (equivalent / not / unknown)

 volta_common (spans, file cache, error reporting, run logs) sits under
 volta_frontend, volta_analysis, volta_spec and the front ends.
```

`volta_bench` holds only the end-to-end tests: PTX kernels run through the whole pipeline, checking race verdicts and symbolic outputs.

Arrows show data flow. `volta_analysis` (the producer) and `volta_equivalence` (the consumer) never depend on each other: `volta_expr` is their only shared contract, so the checker accepts expressions from a kernel, a spec, a `.vcdump`, or a `.vexpr` file alike. `volta_z3` reuses `volta_equivalence`'s element pairing so both backends check exactly the same elements.

# NOTICE

This is an experimental fork of Volta, for the original repo see [here](https://github.com/willtunnels/volta).

## Usage

To check a kernel for data races:

```
volta analyze <path/to/kernel.ptx> \
  -k kernel -b 128 -g 1 \
  --array x:0x100000000:4:1048576:in --array output:0x200000000:4:1048576:out \
  --param ptr:x --param ptr:output --param int:0 --param int:0
```

Note that the parameters and tensor array addresses and sizes must match the expected parameters of the kernel.

To check a kernel against a spec, first write the spec in a file, e.g. relu.spec:

```
dim N;
array x[N];
array output[N];
output[i] = max(x[i], 0);
```

Then invoke `volte verify`:


```
volta verify <path/to/kernel.ptx> relu.spec \
  -k kernel -b 128 -g 1 --dim N=256 \
  --array x:0x100000000:4:1048576:in --array output:0x200000000:4:1048576:out \
  --param ptr:x --param ptr:output --param int:0 --param int:0
```

## Python Bindings

In the other project's pyproject.toml:

```toml
[project]
dependencies = ["volta"]

[tool.uv.sources]
volta = { path = "<path_to_this_root_folder>/crates/volta_py", editable = true }
```

Then just run `uv sync` and `import volta` should work immediately.

---

Original README below:

---

# Volta

Volta is a data race and equivalence checker for NVIDIA GPU kernels, implementing "Equivalence Checking of ML GPU Kernels" (OOPSLA 2026). Given a reference kernel and an optimized counterpart, Volta proves them semantically equivalent over the reals — identical outputs on all valid inputs, with floating-point values modeled as real numbers — thereby verifying the correctness of the optimized kernel.

## Relationship to the paper

The evaluation in the published version of the paper was produced with this implementation. The raw results live in [`results/`](results/): the full 2026-08-12 run at commit `e86ef2d`, plus a 2026-08-14 re-measurement of the racy reduction kernels at commit `cc9fb434` after recompiling them at the correct block size — `results/README.md` records the exact provenance. `python3 scripts/generate_tables.py results/2026-08-12/` renders the paper's tables from them. The `volta-bench` harness and kernel corpus that produced them are no longer in the tree; commit `a8e9967` is the last one that has both.

## Features

- **Data race detection**: identify races arising from under-synchronization
- **Deadlock detection**: identify deadlocks arising from over-synchronization
- **Equivalence checking**: verify that optimized GPU kernels are semantically equivalent to their reference implementations
- **CLI comparison**: `volta compare` checks a reference/optimized pair directly
- **VC dump/replay**: persist the verification conditions from one run and rerun just the equivalence check later, skipping parse/lower/symbolic-execution entirely
- **Z3 backend**: check the same verification conditions with Z3 instead of the built-in decision procedure, for a "decides vs. cannot decide" timing/capability comparison
- **Per-run logging and execution profiling**: every run gets a log file, and a per-instruction-kind execution profile is available

## How it works

Volta has two phases:

1. **Symbolic execution**: executes both kernels symbolically (round-robin over all threads of CTA 0), tracking memory accesses and synchronization to detect data races and deadlocks, and producing symbolic expressions for each output element as a function of the input tensors.

2. **Equivalence checking**: verifies that the two kernels' symbolic expressions are mathematically equal over the reals. Each output element canonicalizes to a rational function whose polynomials are sums of `c * monomial * e^{poly}` terms with exact rational coefficients. An optional `f64` oracle (`--verify-numeric`) re-checks every verdict at seeded random inputs.

## Soundness and completeness

Equivalence checking treats floating-point values as reals. Within that model:

- **Race and deadlock detection** is sound and complete for structured-CTAs (see [Requirements](#requirements)): every report corresponds to a real schedule, and every race or deadlock is detected. Only CTA 0 is checked, under the symmetry assumption that all CTAs run the same code (the grid size still matters for index computations).

- **Equivalence checking** is sound. It is provably complete for verification conditions built from `+`, `-`, `*`, `/`, and `exp` (the paper's sums-of-`p_i * e^{h_i}` class). `max`/`min` are handled by normalization in the restricted patterns that arise in ML kernels, such as softmax's max-subtraction.

- `sqrt`, `log`, `abs`, `rem`, bitwise ops, shifts, comparisons, boolean ops, `select`, and data-dependent array reads are carried as uninterpreted atoms, equal only when syntactically identical after canonicalizing their arguments. Soundness is preserved; completeness is not.

## Requirements

The input to Volta is PTX (the lowest documented level of the language stack for NVIDIA GPUs); `nvcc` produces it from CUDA or CUTLASS code.

Kernels must be _structured-CTAs_:

- Tensor/array sizes are statically known
- Branch targets and memory addresses resolve statically given the launch configuration — they may depend on thread/block indices and statically-known parameters, but not on symbolic input values
- No recursion

Supported synchronization is barriers: `syncthreads`, `syncwarp`, and the implicit warp-level barriers of tensor core operations (`mma.sync`, `wmma.*`, `ldmatrix`, `shfl.sync`). Asynchronous primitives such as `arrive` and `wgmma` are not supported.

## Building

```bash
cargo build --release   # release mode matters: ~20x faster analysis
cargo test --workspace  # run the test suite
```

The workspace's one binary is `volta` (the analysis CLI, package `volta_cli`), so `cargo run` needs `-p volta_cli`; equivalently, run `target/release/volta` directly.

## Usage

### Parse a PTX file (syntax check)

```bash
cargo run --release -p volta_cli -- parse <file.ptx>
```

### Analyze one kernel

Symbolically executes a kernel: reports data races and deadlocks, and prints the symbolic expressions for each output array element.

```bash
cargo run --release -p volta_cli -- analyze <file.ptx> -k <kernel> -b 32,4 -g 1 \
    --array "vals:0x100000000:4:2048:in" \
    --array "out:0x200000000:4:2048:out" \
    --param ptr:out --param ptr:vals --param int:2048 \
    --dyn-shared 1024
```

- `-k, --kernel`: kernel entry name (defaults to the first kernel in the module)
- `-b, --block` / `-g, --grid`: launch dimensions, e.g. `128` or `32,4,1`
- `--array "name:base:elem_width:len:kind"` (repeatable): declares a global array at address `base` with `len` elements of `elem_width` bytes; `kind` is `in` (symbolic input), `out`, `inout`, or `index` (concrete `arr[i] = i`, for index/permutation inputs)
- `--param` (repeatable, in declaration order): `int:N`, `float:X`, `sym:name` (a named symbolic float), or `ptr:array_name`
- `--global NAME=value` (repeatable): module-scope `.global` variable values
- `--dyn-shared N`: dynamic (extern) shared memory bytes
- `--print-outputs N`: print up to N elements per output array (default 8)
- `--no-profile`: skip the per-instruction-kind execution profile (shown by default)

### Compare two kernels

`volta compare` checks a reference/optimized pair for equivalence (races and deadlocks are still checked for each kernel individually). Arrays, params, and globals are shared by both kernels; give `--block2`/`--grid2` if the optimized kernel's launch config differs (e.g. a single-thread reference vs. a 128-thread optimized kernel computing the same tile). Comparison follows the paper's CTA-to-CTA model: `--check-array` names the output arrays to compare (repeatable, at least one required, each declared with an `out`/`inout` kind), and both CTA-0 runs must write each named array with identical footprints. Arrays you don't name are not compared — which is how auxiliary outputs like FlashAttention's softmax statistics stay out of a comparison against a reference that never computes them.

```bash
cargo run --release -p volta_cli -- compare <ref.ptx> <opt.ptx> \
    --kernel1 <ref_kernel> --kernel2 <opt_kernel> -b 128 \
    --array "in:0x10000:4:128:in" --array "out:0x20000:4:1:out" \
    --param ptr:in --param ptr:out --check-array out
```

- `--sample N`: check at most N output elements per array (0 = all)
- `--verify-numeric`: confirm every verdict with the f64 oracle (iteration 1 only)
- `--recycle-terms N`: recycle the VC intern tables past N interned terms (0 = never); lower values bound memory at the cost of re-canonicalizing shared structure
- `--iterations N` (default 1, decision backend only): re-solve the same elements N times, a fresh session each; the verdict comes from iteration 1 and later iterations must agree
- `--backend decision|z3` (default `decision`): which decision procedure checks equivalence — see [Z3 backend](#z3-backend)
- `--exp-axiom` (with `--backend z3`): the paper's "with axiom" exponential encoding
- `--no-profile`: skip the per-instruction-kind execution profile

`compare` exits 0 only when every checked element was proved equivalent (with `--backend z3`, `unknown`/`timeout`/`unsupported`/error elements also prevent exit 0, not just mismatches — a run that verified nothing does not exit 0).

**VC dump/replay**: `--dump-vcs` persists both kernels' verification conditions (the expression arenas + output footprints) after symbolic execution; `--from-dump` reruns just the equivalence check from that dump — no PTX parsing, lowering, or symbolic execution involved on replay. Dump files carry a magic/version header and are validated on load, so a truncated, corrupted, or version-skewed dump fails with a clean error rather than a crash.

```bash
cargo run --release -p volta_cli -- compare <ref.ptx> <opt.ptx> ... --dump-vcs pair.vcdump
cargo run --release -p volta_cli -- compare --from-dump pair.vcdump --check-array out
```

### Logging

Every `volta` run writes a log file under `volta-logs/` (`<unix-seconds>-<pid>-<command>.log`), recording the exact command line and a one-line outcome summary — independent of the `logging` feature, so it works in a plain build. `--log-dir <path>` changes the directory; `--no-log-file` disables it. Building with `--features logging` also mirrors the `log` crate's trace/debug/info/warn output into the same file (level via `--log-level`), in addition to stderr:

```bash
cargo run --release -p volta_cli --features logging -- --log-level info analyze ...
```

### Z3 backend

Checks the same verification conditions with Z3 instead of Volta's own decision procedure, for a timing/capability comparison. Queries are generated as SMT-LIB2 text (auditable: any query can be replayed against a standalone `z3`) and evaluated through libz3's C API via a small hand-written binding — no `z3-sys`/bindgen, no temp files, and no `z3` binary needed at runtime. The one prerequisite is the Z3 shared library at build time:

```bash
sudo apt-get install -y libz3-dev
cargo run --release -p volta_cli -- compare <ref.ptx> <opt.ptx> ... --backend z3
```

On macOS, install the Homebrew formula instead (its keg-only library path is discovered automatically):

```bash
brew install z3
```

For a nonstandard installation, set `Z3_LIB_DIR` to the directory containing `libz3` when invoking Cargo.

The expected shape of the results reproduces the paper's Section 6.5 and Table 9. Z3 decides the polynomial fragment (reduction/matmul/conv) in milliseconds. On the exponential fragment (softmax/attention) the backend implements both documented baselines:

- **Default encoding**: the exponential is a nonlinear power term with a strictly-bounded base. Z3 returns `unknown` — no decision procedure covers symbolic real exponents. This is the paper's no-intervention baseline.
- **`--exp-axiom`**: the exponential becomes an uninterpreted function plus the addition-law axiom `forall x y. e^x e^y = e^(x+y)` (the paper's "Z3 with axiom" setup). The axiom sends Z3 into an unbounded quantifier-instantiation loop on softmax-shaped VCs, so instead of a fast `unknown` the query runs until the time budget kills it — reported as `timeout`. The paper used a 10-minute budget.

`--z3-timeout` (default 30 s, `0` = no limit) is a _hard_ per-query bound: z3 4.8.12 does not reliably honor its own soft timeout in the axiom-induced loop (measured: a 3-second soft timeout still running after 90 seconds), so each query evaluates in a worker subprocess — this same binary re-invoking itself — that is killed on expiry. `timeout` in the element counts means the budget expired; `unknown` means z3 itself gave up with budget to spare.

Reported Z3 time is _solver_ time only, measured inside the worker around exactly libz3's evaluation of the query text: process spawn and z3 context setup (~10.5 ms together, measured) and translation/query construction are excluded. Elements that exhaust the budget report the budget itself as their time — the paper's convention for timeout rows. Because the translation deliberately does no reasoning, every element costs a genuine spawn+solve, so a full-footprint run over tens of thousands of elements takes hours where the decision procedure takes seconds; that gap is a result, not an inefficiency. Use `--sample` to bound the element count (the paper's Table 9 uses `--sample 1`).

The translation covers the arithmetic + `exp` + `max`/`min` fragment as a direct semantic image: every expression node maps to its defining SMT term, and all algebraic reasoning (commutativity, cancellation, distribution, `max`/`min` case analysis) is left to the solver, so the timings measure Z3, not the translator. Float constants translate as exact rationals (the same reading as the decision procedure and the numeric oracle), and `let`-bound DAG sharing keeps query text linear in the expression arena. One inherited SMT semantic: real division is total but underspecified at zero, so field identities like `x/x = 1` are falsifiable (countermodel `x = 0`) — corpus VCs only divide inside exp-laden softmax terms, where the verdict is `unknown` regardless. Anything outside the fragment (`select`, comparisons, bitwise ops, data-dependent array reads, ...) is reported `unsupported` for that element rather than guessed at unsoundly. See `crates/volta_z3/src/translate.rs` for the exact boundary.

## Citation

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
