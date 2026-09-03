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

Original README below:

# Volta

Volta is a data race and equivalence checker for NVIDIA GPU kernels, implementing "Equivalence Checking of ML GPU Kernels" (OOPSLA 2026). Given a reference kernel and an optimized counterpart, Volta proves them semantically equivalent over the reals — identical outputs on all valid inputs, with floating-point values modeled as real numbers — thereby verifying the correctness of the optimized kernel.

## Relationship to the paper

The evaluation in the published version of the paper was produced with this implementation. The raw results live in [`results/`](results/): the full 2026-08-12 run at commit `e86ef2d`, plus a 2026-08-14 re-measurement of the racy reduction kernels at commit `cc9fb434` after recompiling them at the correct block size — `results/README.md` records the exact provenance. [Reproducing the paper's evaluation](#reproducing-the-papers-evaluation) below regenerates all of it.

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

The workspace has two binaries — `volta` (the analysis CLI, package `volta_cli`) and `volta-bench` (the benchmark harness, package `volta_bench`) — so `cargo run` needs `-p`; equivalently, run `target/release/volta` and `target/release/volta-bench` directly.

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

- `--sample N`, `--verify-numeric`, `--recycle-terms N`, `--iterations N`: same meaning as the `volta-bench` flags below (`--iterations` defaults to 1 here and applies to the decision backend only)
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

Every `volta`/`volta-bench` run writes a log file under `volta-logs/` (`<unix-seconds>-<pid>-<command>.log`), recording the exact command line and a one-line outcome summary — independent of the `logging` feature, so it works in a plain build. `--log-dir <path>` changes the directory; `--no-log-file` disables it. Building with `--features logging` also mirrors the `log` crate's trace/debug/info/warn output into the same file (level via `--log-level`), in addition to stderr:

```bash
cargo run --release -p volta_cli --features logging -- --log-level info analyze ...
```

### Z3 backend

Checks the same verification conditions with Z3 instead of Volta's own decision procedure, for a timing/capability comparison. Queries are generated as SMT-LIB2 text (auditable: any query can be replayed against a standalone `z3`) and evaluated through libz3's C API via a small hand-written binding — no `z3-sys`/bindgen, no temp files, and no `z3` binary needed at runtime. The one prerequisite is the Z3 shared library at build time:

```bash
sudo apt-get install -y libz3-dev
cargo run --release -p volta_cli -- compare <ref.ptx> <opt.ptx> ... --backend z3
```

The expected shape of the results reproduces the paper's Section 6.5 and Table 9. Z3 decides the polynomial fragment (reduction/matmul/conv) in milliseconds. On the exponential fragment (softmax/attention) the backend implements both documented baselines:

- **Default encoding**: the exponential is a nonlinear power term with a strictly-bounded base. Z3 returns `unknown` — no decision procedure covers symbolic real exponents. This is the paper's no-intervention baseline.
- **`--exp-axiom`**: the exponential becomes an uninterpreted function plus the addition-law axiom `forall x y. e^x e^y = e^(x+y)` (the paper's "Z3 with axiom" setup). The axiom sends Z3 into an unbounded quantifier-instantiation loop on softmax-shaped VCs, so instead of a fast `unknown` the query runs until the time budget kills it — reported as `timeout`. The paper used a 10-minute budget.

`--z3-timeout` (default 30 s, `0` = no limit) is a _hard_ per-query bound: z3 4.8.12 does not reliably honor its own soft timeout in the axiom-induced loop (measured: a 3-second soft timeout still running after 90 seconds), so each query evaluates in a worker subprocess — this same binary re-invoking itself — that is killed on expiry. `timeout` in the element counts means the budget expired; `unknown` means z3 itself gave up with budget to spare.

Reported Z3 time is _solver_ time only, measured inside the worker around exactly libz3's evaluation of the query text: process spawn and z3 context setup (~10.5 ms together, measured) and translation/query construction are excluded. Elements that exhaust the budget report the budget itself as their time — the paper's convention for timeout rows. Because the translation deliberately does no reasoning, every element costs a genuine spawn+solve, so a full-footprint run over tens of thousands of elements takes hours where the decision procedure takes seconds; that gap is a result, not an inefficiency. Use `--sample` to bound the element count (the paper's Table 9 uses `--sample 1`).

The translation covers the arithmetic + `exp` + `max`/`min` fragment as a direct semantic image: every expression node maps to its defining SMT term, and all algebraic reasoning (commutativity, cancellation, distribution, `max`/`min` case analysis) is left to the solver, so the timings measure Z3, not the translator. Float constants translate as exact rationals (the same reading as the decision procedure and the numeric oracle), and `let`-bound DAG sharing keeps query text linear in the expression arena. One inherited SMT semantic: real division is total but underspecified at zero, so field identities like `x/x = 1` are falsifiable (countermodel `x = 0`) — corpus VCs only divide inside exp-laden softmax terms, where the verdict is `unknown` regardless. Anything outside the fragment (`select`, comparisons, bitwise ops, data-dependent array reads, ...) is reported `unsupported` for that element rather than guessed at unsoundly. See `crates/volta_z3/src/translate.rs` for the exact boundary.

### Reproducing the paper's evaluation

`volta-bench` runs every benchmark from the paper (39 in total) over the PTX collected in `crates/volta_bench/kernels/`:

```bash
cargo run --release -p volta_bench -- list
cargo run --release -p volta_bench -- all
cargo run --release -p volta_bench -- category <reduction|matmul|attention|causal|conv|agent|tilelang|race>
cargo run --release -p volta_bench -- single "(Attention, FA1)"
```

Every benchmark runs through one pipeline: generate the verification conditions, write the VC dump, solve with the decision procedure, and optionally solve with Z3 (`--z3`), recording everything in one results document. Race-check benchmarks stop after generation — their whole analysis is the symbolic execution. The pipeline's two halves also run separately, over the same `all`/`category`/`single` selectors: `generate` runs just the generation phase and writes the dumps (plus `vcs/manifest.json`), and `solve` replays just the solve phase(s) from those dumps — no parsing, lowering, or symbolic execution — with `--backend decision|z3|both` choosing the solver(s). Both halves call the same phase functions as the one-shot pipeline, so they measure and decide exactly the same things.

Global flags:

- `--sample N`: check at most N output elements per array (0 = all)
- `--verify-numeric`: confirm every verdict with the f64 oracle (iteration 1 only)
- `--recycle-terms N`: recycle the VC intern tables past N interned terms (0 = never). Lower values bound memory at the cost of re-canonicalizing shared structure
- `--iterations N` (default 10): run every timed phase N times per benchmark — see [Timing and output files](#timing-and-output-files)
- `--z3` / `--z3-timeout N`: also solve every equivalence benchmark's VCs with Z3, side by side with the decision procedure (`--z3` belongs to the one-shot commands; `solve` picks its solver with `--backend`)
- `--out-dir <path>` (default `bench-out/`): where VC dumps and results JSON files land
- `--json <path>`: _also_ write the results document to this explicit path (the timestamped file under `<out-dir>/results/` is always written)

The full evaluation is four commands — generate every benchmark's VCs once, then solve the same dumps three ways. Each command runs its own timed phase the default 10 `--iterations`:

```bash
# 1. Generate and dump every benchmark's VCs - the "VC Gen" timings; no solving.
#    This also settles the race table (Table 8): those verdicts come from
#    generation, and `solve` skips race-check benchmarks with a note.
cargo run --release -p volta_bench -- generate all

# 2. Decision-solve ALL elements from the dumps - the full-footprint "VC Time" timings.
cargo run --release -p volta_bench -- --recycle-terms 0 solve all

# 3. Decision-solve one element per output array - the paper's sampled setting.
cargo run --release -p volta_bench -- solve all --sample 1

# 4. Z3 on the same sampled elements under a 10-minute budget - Table 9.
#    unknown/timeout/unsupported are Table 9's data, never failures; a z3
#    `not_equivalent` on any element FAILS that row (`Z3 DIFF`, nonzero exit).
cargo run --release -p volta_bench -- solve all --sample 1 --backend z3 --z3-timeout 600
```

Steps 2–4 never re-execute a kernel: they load `bench-out/vcs/*.vcdump`, hashing each file's bytes against `bench-out/vcs/manifest.json` _before_ decoding, so a stale, mixed, or corrupted dump directory fails loudly instead of quietly solving the wrong VCs (load time is reported separately as `dump_load_secs`). On a memory-limited machine, replace step 2 with per-category `solve category <c>` runs under a positive `--recycle-terms` (see the memory note below) — step 2 as written wants the full-footprint attention working set.

Render the tables from the four results files with

```bash
python3 scripts/generate_tables.py bench-out/results/
```

which emits the paper's tables in markdown or LaTeX (`--format latex`, booktabs), auto-discovering each run by its header and computing PTX LOC from the corpus. Every table includes a VC-generation column, even where the paper's version omits one.

**Z3 comparison details** (`--z3`, or step 4 above): the same sampled elements are solved by both backends, and the tables gain the median Z3 solve time plus a per-element equivalent/not-equivalent/unknown/timeout/unsupported/error breakdown. Both timing columns measure only the deciding work, so they are comparable. One carve-out: an element whose iteration-1 outcome is timeout/unsupported/error is not re-solved in later iterations — its iteration-1 time is charged to every iteration's total, and verdict counts always come from iteration 1. Benchmarks whose VCs contain exponentials additionally get a `+exp-axiom` sub-row: the same elements rerun under the axiom encoding (expected outcome: `timeout`, versus `unknown` on the default row). One caveat on small machines: the axiom-induced grind also eats memory, and if z3 exhausts memory before the deadline it gives up with `unknown` instead of surviving to the kill (measured on a 15 GiB box, the memory wall arrives after roughly half a minute; the paper's 10-minute timeouts ran on a 995 GB machine). Pick a budget below the memory wall — e.g. `--z3-timeout 20` — to see the `timeout` outcome on constrained hardware, and run one category at a time.

**Memory note**: symbolic execution plus a warm VC session can use tens of GiB on the attention benchmarks (each output row retains a large shared softmax denominator). On machines with limited RAM, run one category at a time and bound the VC tables, e.g.:

```bash
bash -c 'ulimit -v 12582912; exec cargo run --release -p volta_bench -- \
    --recycle-terms 250000 category attention'
```

which holds peak memory near the symbolic-execution floor (~5 GiB) in exchange for slower VC checking. The other categories are far lighter (full matmul: ~2 GiB).

### Timing and output files

Each benchmark's work splits into separately-timed phases: **VC generation** (`vc_gen_*`: lowering, both kernels' symbolic executions, and footprint pairing; parsing and dump-writing are excluded, the latter reported as `dump_write_secs`), **VC solving** (`solve_*`: the per-element equivalence checks only), and optionally **Z3 solving** (in-worker solver time, as above). Each phase runs `--iterations` times (default 10); **the median is the headline number** — iteration 1 includes process/allocator warmup, and the median absorbs it. The results JSON keeps every phase's full per-iteration array plus median/min/mean and the coefficient of variation, and the harness warns per benchmark when a phase's CV exceeds 0.10. At startup the binary also prints loud warnings when the environment would corrupt the timings: a build without `--release` (~20x off) or, under the `logging` feature, a `--log-level` of `info` or above.

Re-running phases doubles as a correctness check: every solve iteration re-solves the same elements from a fresh VC session and must reproduce iteration 1's verdicts, and every generation iteration must reproduce iteration 1's fingerprint (outcome kind, written footprints, and expression identities), so a nondeterministic interpreter regression fails loudly instead of silently timing different work.

Each run writes under `--out-dir` (default `bench-out/`, gitignored):

- `bench-out/vcs/<name>.vcdump` — each equivalence benchmark's verification conditions (both kernels' expression arenas + output footprints), named by a sanitized benchmark name (`(Attention, FA1)` becomes `attention-fa1.vcdump`) and overwritten on rerun; VCs are deterministic and dumps are byte-identical across runs. These are exactly `volta compare --dump-vcs` files, so they replay directly:

  ```bash
  cargo run --release -p volta_cli -- compare --from-dump bench-out/vcs/red-1-red-2.vcdump
  ```

- `bench-out/vcs/manifest.json` — per-dump provenance: benchmark name, generation timestamp, a hash of the exact dump bytes, and per-array element counts. `solve` verifies every dump against it before decoding and hard-errors on disagreement; a `generate` run that fails for a benchmark deletes that benchmark's leftover dump and entry. A missing manifest or entry is only a warning, so hand-copied dumps stay usable.

- `bench-out/results/<unix-seconds>-<pid>-<command>.json` — the results document: a header (argv, timestamp, iterations, sample, recycle-terms, Z3 settings; `solve` headers add the `backend` and `vcs_from_dumps: true`) and one record per benchmark with identity and verdict (`name`, `category`, `status`, `detail`, `passed`, `elements_checked`/`elements_total`), per-phase timing stats, iteration-1 per-element decision times (`decision_elements`), the `z3` section when applicable (per-iteration totals, verdict counts, iteration-1 elements, and the `axiom` sub-section), and instruction and sync counters. `generate` records carry only generation fields; `solve` records carry only solve fields plus `dump_load_secs`, with skipped race-check benchmarks as `status: "SKIP"` records.

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
