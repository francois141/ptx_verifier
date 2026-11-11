# volta_pipeline

The integration point. This is the only crate that composes the analysis stage
with its two branches and combines their results into a verdict.

```
analysis (volta_ptx_analysis::analyze) ──► AnalysisResult { symbolic outputs, event graph, provenance }
   ├─ equivalence branch: symbolic outputs only  ──► EquivalenceVerdict    (equivalence.rs)
   └─ graph branch: event graph only, ten checks ──► GraphReport           (kernel.rs)
                                    aggregation (decide) ──► ACCEPT / REJECT / UNKNOWN   (aggregate.rs)
```

The analysis stage runs neither branch. The branches share only the stage's
artifacts and never call each other or the stage.

## API

- **`verify_kernel(module, kernel, config) -> KernelVerification`**
  (`kernel.rs`): runs the analysis, then `volta_graph_check::check_graph` on its
  graph. Returns the analysis result with the graph report.
- **`check_equivalence(...) -> EquivalenceVerdict`** (`equivalence.rs`): runs
  `volta_equivalence` over the two sides' symbolic outputs. A claimed
  difference counts as a refutation only once the numeric oracle separates it
  (`confirm_differences`); otherwise it is `Unproven`.
- **`decide(&equivalence, &[KernelEvidence]) -> Decision`** (`aggregate.rs`):
  - **ACCEPT** requires a complete (unsampled) equivalence proof and every
    kernel's graph conclusion `Verified`;
  - **REJECT** on any refutation, failed graph check, or deadlock;
  - **UNKNOWN** otherwise (sampled check, unresolved obligations, aborted run,
    unproven difference).

  The `Decision` carries the verdict, its evidence, and the union of the
  modeling assumptions the analyses ran under.

## Tests

Every kernel-driven test in the workspace lives here, end to end, for all three ISAs:
PTX kernels from `tests/ptx/`, AMD kernels from `tests/amd/` and NKI kernels from
`tests/trainium/`, each sorted into the outcome folders of [Kernel layout](#kernel-layout).
Each ISA is one test target, `tests/<isa>/main.rs`, its suites modules beside its kernels:
`cargo test -p volta_pipeline --test amd_tests` (or `ptx_tests`, `trainium_tests`), with a
module filter such as `-- equivalence_tests::` to run one suite. The analysis crates keep
only inline unit tests of their internals.

- `ptx/aggregation_tests.rs`: real kernels through both branches and `decide`.
- `amd/accepted_tests.rs`: AMD fixtures expected to complete, their symbolic outputs
  matching their `.out` files, and the launch and grid behavior around them;
  `amd/rejected_tests.rs`: the lowering or execution error each rejected kernel must
  raise; `amd/lean_tests.rs`: the sigmoid kernel stated against its spec as a Lean
  challenge, written to `target/lean/sigmoid.lean` (`just extract-lean`).
- `amd/equivalence_tests.rs`: compiled AMD matmul, MFMA matmul, CK GEMM, CK attention,
  and softmax against their formulas, including negative tests. It reuses
  the AMD assembly fixtures and the equivalence crate's specifications, accounting
  for CK's column-major B. Each kernel's graph must conclude `Verified` before its
  outputs are compared, as for PTX kernels. CK attention checks all 16,384 outputs
  across two batches and two heads, executing workgroups separately and checking each
  output footprint; a wrong Q head stride must be refuted. `just amd` runs them.
- `amd/graph_tests.rs`: LDS reuse and pending-read races in workgroup 0. CK GEMM compares
  one and three K tiles over the same LDS storage, and its main loop also verifies at
  K=200 and 64 x 64 x 256. CK attention verifies with all four waves writing and reading
  LDS. CK GEMM's equivalence tests check all 1,600 outputs at M=N=40, K=192 and refute
  swapped inputs.
- `trainium/accepted_tests.rs`: NKI fixtures expected to run, their parsed and lowered
  forms and symbolic outputs matching their `.ast`, `.ir` and `.out` files (and their
  hand-written `.expected`, which `VOLTA_BLESS` never rewrites);
  `trainium/rejected_tests.rs`: the error each rejected kernel must raise.
- `trainium/equivalence_tests.rs`: the NKI `matmul`, `gemm_relu` and `softmax`
  fixtures against their `.spec` files beside them in `tests/trainium/success/`,
  with `gemm_relu` against the unclamped product and `softmax` against the softmax
  of `-x` (a reversed `subtract`) as negative tests. Also the NKI samples' own
  `attn_fwd_v2`, read from its unmodified file with `softmax_isa` inlined, against
  `attention.spec`: on its first row of 128 outputs by default, on all 16,384 in an
  ignored test (`cargo test --release -p volta_pipeline --test
  trainium_tests -- --ignored equivalence_tests::`, about a minute), and refuted against
  attention with `q` and `k` swapped; `attn_fwd_v1` likewise, and v1 against v2
  directly, kernel to kernel. The tiled `attn_fwd_v3` to `attn_fwd_v8a` and
  `attn_fwd_v10` run from the same file, each called with its upstream input dtype
  (`bfloat16` for v10, whose allocator sizes tiles by it, else `float32`), with one
  line changed in v3 to v8a: their `assert seqlen_q >= 512` stated as
  the limit it stands for, `FMAX_MOVING` (`gemm_moving_fmax`), which a test checks
  leaves every kernel unchanged at the hardware's tile sizes (v10 states it so
  itself). At four reduced tile sizes (`TileSizes`, e.g. `pmax` 4 and
  `gemm_moving_fmax` 8 on `[4, 16]` inputs; the last gives eight key tiles, so v10's
  QK matmuls wrap around its seven PSUM banks as at seqlen 4096) each is proved
  equal to `attention.spec`, and to the version before it (v8a for v10),
  on every output, and refuted with `q` and `k` swapped; unmodified at full size
  (`[128, 512]`), an ignored test proves each against the spec and the version
  before it on one row of each of the four query tiles, each at another partition
  (rows 0, 170, 341 and 511: about 5 minutes and 12 GB, most of it unfolding the spec's
  65,536 outputs and running the eight kernels). Upstream runs v10 at seqlen 4096,
  out of reach here: each of its 524,288 outputs sums 4,096 exponentials. v7 to v8a
  keep their scores in `nl.bfloat16`, and v10 its inputs too, which is not
  modelled: they are checked over the reals. The
  `fused_softmax` fixture, softmax as v8 fuses it, is proved equal to
  `softmax.spec`. The other tutorials' kernels run from their unmodified files too:
  `nki_tensor_add` is proved equal to `tensor_addition.spec` (`a + b`) on every
  output at its torch driver's 256 x 1024 (its 128 x 512 tiles are literals, so
  there is no reduced size), and refuted against a subtraction. The matrix
  multiplication tutorial's five kernels are proved equal to
  `matrix_multiplication.spec` (`lhsT.T @ rhs`) on every output:
  `nki_matmul_basic_` at the 64 x 512 x 128 it asserts, and the tiled, hoisted,
  blocked and fully optimized kernels, each also to the one before, at two reduced
  tile sizes whose `[M, N, K]` give every loop two iterations (the driver's
  4096 x 2048 x 1024 is out of reach); the fully optimized kernel also with its
  `TILES_IN_BLOCK_*` meta-parameters given by the call. All five are refuted against
  a doubled product. The transpose2d tutorial's kernel, its `shape2D` given by the
  call, is proved equal to `transpose2d.spec` on every output at its drivers'
  5 x (3 x 4) and 5 x (37 x 44), and refuted against the identity. The
  average_pool2d tutorial's kernel, which sums a strided `.ap()` view of its tile over
  its two window axes and scales by `1.0 / (pool_size * pool_size)`, is proved equal
  to `average_pool2d.spec` (each window's mean) at its drivers' 2 x 6 x 6 with 2 x 2
  windows and at 3 x 8 x 12 with 4 x 4, and refuted against the unscaled sum and
  against overlapping windows. That scale is exact only for power-of-two pool sizes;
  a 3 x 3 pool's float `1/9` is not the mean over the reals. The fused_mamba
  tutorial's `mamba_v1` to `mamba_v3`, float32 as its drivers call them, are proved
  equal to `mamba.spec` (the torch reference's scan unrolled into causal sums) and v2
  to v1 and v3 to v2, on every output, at 2 batches x 128 channels x 8 steps x 2
  states with `pmax` 64 and `gemm_moving_fmax` 4. v3's `seq_len_fsize = 512` is
  stated as `nl.tile_size.gemm_moving_fmax`, the 512 it equals on the hardware (a test
  checks the three kernels unchanged there), so v3 runs two sequence tiles and carries
  its scan across them; the driver's 2048 steps x 256 channels x 16 states are out of
  reach. All three are refuted against a decay one step too long and a scan without
  its recurrence, and v3 restarting each tile's scan from zero is refuted too. The
  tensor_indirection tutorial's kernel, its index tensor's offsets given by the call
  (`KernelCall::contents`, three draws with repeats and one of extreme offsets), is
  proved equal to `tensor_indirection.spec` (`data[:, index[0]]`, the offsets its
  index array) on every output at its driver's 128 x 64 with 32 offsets, and at
  16 x 8 with 16 and 48 x 20 with 48 (one and three 16-partition groups and index
  columns); it is refuted against the spec given one other offset and against the
  ungathered `data[:, i]`.
  Functional equivalence only; `just trainium` runs them in release.
- the PTX suites below, over `tests/common/`.

### How a test runs

`tests/common/` is shared by every suite; `common::amd` and `common::trainium` hold
the AMD and NKI helpers (fixture runs, `.out` comparisons, CK argument layouts), and the
rest serves the PTX suites:

- `parse` / `parse_named` returns a `Ptx`: module, source text, file name.
- `verify`, `analyze_only`, `check` and `run_kernel` run the pipeline with an
  `AnalysisConfig`.
- For kernels expected to complete, the graph conclusion must be `Verified`
  (not merely "not rejected"). The rendered symbolic outputs must then match
  the kernel's `.out` file byte for byte. `VOLTA_BLESS=1` rewrites the `.out`
  files.
- Race and deadlock tests assert on the failed check's **typed witness** (the
  byte, the two threads, the access modes, the async op), not on message text.
- With `VOLTA_VIZ_DIR` set, every run is recorded into that `volta_viz` store,
  keyed `<suite>/<test>[~<n>]`, the suite being the ISA and the test's module
  (`ptx_accepted_tests`, `amd_graph_tests`; `just viz`).

### Suites

The PTX suites, modules of `tests/ptx/`:

| suite                              | what it checks |
|------------------------------------|----------------|
| `accepted_tests.rs`                | race-free kernels conclude `Verified` and match their `.out` |
| `mbarrier_epoch_tests.rs`          | Algorithm 1 over mbarrier phases |
| `mbarrier_ordering_tests.rs`       | Algorithm 2: unprotected `expect_tx` announcements |
| `memory_conflict_tests.rs`         | Algorithm 3: unordered conflicting accesses |
| `proxy_order_tests.rs`             | Algorithm 4: missing proxy / tensor-map fences |
| `tensor_order_tests.rs`            | Algorithm 5: unordered Tensor Memory accesses |
| `resource_lifetime_tests.rs`       | Algorithm 7: TMEM use after free, leaked allocation |
| `allocation_order_tests.rs`        | unordered `tcgen05.alloc` pairs |
| `allocation_permit_tests.rs`       | allocation after `relinquish_alloc_permit` |
| `mbarrier_release_order_tests.rs`  | waits observing phases out of order |
| `rejected_tests.rs`                | execution errors (`EvalError`, lowering errors) and deadlocks |
| `graph_tests.rs`                   | the recorded event graph itself, no checker |
| `negative_equivalence_tests.rs`    | kernel pairs differing in one detail must not be proved equivalent |
| `soundness_tests.rs`               | soundness regressions (`ptx/soundness/`) |

The unknown-directive regression requires a located `InvalidDirective` naming
the offending directive and verifies controls with that statement removed or
replaced by a known `.pragma`. The return regression rejects `ret 123;` and
`ret.uni 123;` specifically for expecting zero operands, while verifying their
operand-free forms.
The exit regressions verify plain `exit;` and require an unexpected-modifier
error for `exit.not_a_modifier;` and a zero-operand arity error for `exit 123;`.
The corresponding `brkpt` regressions check the same errors and verify plain `brkpt;`.
The `trap` regressions require those validation errors before execution and check
that plain `trap;` still produces `TrapReached` at runtime.
The `mbarrier` count regressions require an `init` count of 0 or `2^20` and an
`arrive` count of 0 to be rejected before any graph verdict, and the trailing
operand regression a lowering error for an `mbarrier.arrive` with four operands.

### Kernel layout

`tests/ptx/`, `tests/amd/` and `tests/trainium/` share one set of outcome folders,
each kernel filed by what its tests expect:

| folder                  | kernels |
|-------------------------|---------|
| `success/`              | complete (and verify, where the ISA records a graph); outputs match their `.out` |
| `check_failure/`        | a graph check rejects them, with a typed witness (PTX only) |
| `execution_error/`      | lowering or execution rejects them, or they deadlock |
| `negative_equivalence/` | pairs differing in one detail (PTX only) |
| `soundness/`            | soundness regressions (PTX only) |

Each kernel sits next to its expected `.out` where one applies, and its `.spec`,
source (`.cl`, `.hip`) or imported modules beside it. An AMD `.s` compiled from one
`.cl` may hold kernels of both outcomes; it sits in `success/`, and its tests name the
failing kernels. `trainium/success/nki_samples/` vendors the upstream samples unmodified.

```sh
cargo test -p volta_pipeline                    # all suites
VOLTA_BLESS=1 cargo test -p volta_pipeline      # regenerate .out files
```

The `logging` feature narrates the stages (`[analysis]`, `[graph]`,
`[equivalence]`).
