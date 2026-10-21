# Volta Architecture Documentation

**Purpose**: Codebase context for AI-assisted development

## Overview

Volta is an abstract interpreter for NVIDIA PTX kernels, implementing the approach from "Equivalence Checking of ML GPU Kernels" (arXiv:2511.12638). It detects data races and verifies kernel equivalence.

## Coding practices

- Take advantage of the type system to ensure correctness. E.g., rather than using a `u32`, to avoid mixing up different kinds of indices, consider using a new type that wraps a `u32`. Likewise, consider where it is better to use a custom, two variant enum in place of a `bool`.
- Shared state makes reasoning about code complex. Err on the side of slightly less efficient but pure implementations.
- Comments:
  - Maximum 3 lines of comments per code block.
  - Prefer zero comments when the code is self-explanatory.
  - Never narrate what the code does.
  - Only document non-obvious invariants, assumptions, or design decisions.
  - Do not split long comments into multiple blocks to bypass this limit.

## Crate Structure

```
crates/
├── volta_common/     # Base utilities (spans, file caching, error reporting, run logs)
├── volta_frontend/   # PTX lexer and parser
├── volta_expr/       # Expression language (arena, SymbolicOutputs, .vexpr text format)
├── volta_graph/      # Typed event graph of one candidate execution (model, builder, invariants, dump)
├── volta_graph_check/ # The six graph checks of the Volta v2 design (Algorithms 1-6) and their suite
├── volta_analysis/   # Abstract interpreter (PTX -> expressions + event graph)
├── volta_equivalence/ # Equivalence checking of expressions (decision procedure, VC dumps)
├── volta_pipeline/   # Analysis -> {equivalence, graph} branches -> ACCEPT/REJECT/UNKNOWN
├── volta_bench/      # End-to-end tests only (PTX kernels through the pipeline)
└── volta_cli/        # Command-line interface
```

### Dependency Graph

Direct dependencies of each crate:

```
volta_cli         → volta_pipeline, volta_equivalence, volta_analysis, volta_graph_check, volta_graph, volta_expr, volta_frontend, volta_common
volta_bench       → (dev only) volta_pipeline, volta_equivalence, volta_analysis, volta_graph_check, volta_graph, volta_expr, volta_frontend
volta_pipeline    → volta_analysis, volta_equivalence, volta_graph_check, volta_graph, volta_expr, volta_frontend
volta_equivalence → volta_expr
volta_analysis    → volta_graph, volta_expr, volta_frontend, volta_common
volta_graph_check → volta_graph
volta_graph       → volta_expr
volta_expr        → (nothing)
volta_frontend    → volta_common
volta_common      → (nothing)
```

`volta_analysis` (the producer) and `volta_equivalence` (the consumer) share
only the expression language; neither depends on the other. Likewise the
event graph (`volta_graph`) is the analysis's only contract with graph
verification (`volta_graph_check`). The analysis runs no checker and no
equivalence and depends on neither branch; only `volta_pipeline` composes the
stage with the branches, and the two branches never depend on each other or on
the stage (`volta_pipeline/tests/architecture_tests.rs` enforces both). Tests follow the
split: `volta_equivalence`'s are spec-to-spec (`tests/spec_equivalence_tests.rs`
over the `.spec` files in `tests/specs/`, and `tests/spec_identity_tests.rs`:
one test per `tests/specs/equivalent/<case>_{lhs,rhs}.spec` identity;
dev-dependency `volta_spec` only), while every PTX-driven test is end-to-end in
`volta_bench/tests/` (kernels under `tests/ptx/`): `common::check` runs
`volta_pipeline::verify_kernel`, race and deadlock tests assert on the failed
property's typed witness, and every kernel run expected to complete must
conclude `Verified` (not merely unrejected) before its symbolic outputs are
compared with the kernel's `.out` file
(`VOLTA_BLESS=1` rewrites them). `volta_analysis` keeps only its inline unit
tests of internals.

## Crate: volta_common

**Path**: `crates/volta_common/`

- `Span` - Source location (low + high byte offset)
- `FileCache` - Caches file content to make sure we always use a consistent version of each file
- `Locate<E>` - Error wrapper with optional location info (span + file path)
- `report_error` - Produces an error message from a title, message, span, and file content. Extracts out and includes the code snippet at the given span in the given file content
- `run_log::RunLog` - Per-invocation log file (`<unix-seconds>-<pid>-<command>.log` under `--log-dir`, default `volta-logs/`), written by the `volta` binary; `tee` mirrors an `env_logger` target into it under its `logging` feature

The pattern is to create an error kind type, and then an alias for `Locate` of that error kind. `locate_span` can be used to tag a `Locate` with a span if it does not already have one. `locate_path` can be used to tag a `Locate` with a path if it does not already have one.

## Crate: volta_frontend

**Path**: `crates/volta_frontend/`

### Lexer (`lex.rs`)

Tokenizes PTX source. Key methods: `next()`, `peek()`, `expect(kind)`.

### Parser (`parse.rs`)

Pratt parser producing AST. Entry point: `parse_module()`.

### AST (`ast.rs`)

- `Module` - Top-level: version, target, address_size, directives
- `Function` - Kernel/device function with params and body
- `Instruction` - Generic instruction: the trie already resolves the mnemonic to a typed `InstrKind` at parse time (`InstructionOp::Unparsed { kind, modifiers, operands }`)
- `ScalarType` - Pred, Signed/Unsigned/Float/Bits with width

### Instruction Parsing (`instr.rs`, `instr_parse.rs`)

- `InstrTrie` - O(n) lookup for PTX mnemonics → `InstrKind`
- `ParsedInstruction` - Strongly-typed enum (~105 instruction variants, defined in `ast.rs`)
- Converts generic `Instruction` to typed variants with validated modifiers

## Crate: volta_expr

**Path**: `crates/volta_expr/`

The expression language shared by producers (the interpreter, specs) and
consumers (the decision procedure, the oracle). Depends on no other
Volta crate. IDs: `ExprId`/`StringId`/`SymbolId` (`SymbolId::fresh()` draws
from a process-global counter).

### Symbolic Expressions (`symbolic.rs`)

Arena-allocated: nodes live in an `ExprArena`, referenced by copyable `ExprId`
handles. Constructors constant-fold eagerly - **exactly**: float constants
are `Real`s (arbitrary-precision rationals via `rug`, boxed, plus
`NegInf`/`PosInf`; NaN is rejected at every f64 ingestion point -
`Real::from_f64`/`arena.float_from_f64` are fallible, NaN literals are a
lowering error, NaN params a config validation error), so the fold algebra
and canon's rational algebra coincide by construction. Folds are exact on
ℚ (div/rcp fold only fully-concrete quotients with a nonzero divisor -
`x/0` and `0/symbolic` both stay unfolded, so a formally-zero
denominator always reaches canon's loud division error); ±inf folds
only the unambiguous extended-real forms (max/min absorption, neg,
inf±finite, inf·nonzero), undefined forms (inf−inf, 0·inf - integer or
real zero alike - anything/0) build unfolded nodes.

- **Atoms**: `IntConst`, `RealConst(Real)`, `BoolConst`, `Symbol(SymbolId)`, `ParamSymbol(StringId)`, `InputElement { array, index }`, `Undefined`
- Symbol identity is typed (`SymbolRef`: `Param`/`Element`/`Machine`,
  disjoint namespaces; one mapping in `ExprNode::symbol_ref`). Identity
  comes only from launch-config names - PTX-source names are scoped and
  must not carry identity; values without a config binding are fresh
  machine `Symbol`s. `AnalysisConfig::validate` rejects ambiguous configs.
- **Arithmetic**: `Add`, `Sub`, `Mul`, `Div`, `Rem`, `Neg`, `Fma`
- **Transcendental**: `Exp`, `Log`, `Sqrt`, `Rcp`
- **Bitwise**: `BitAnd`, `BitOr`, `BitXor`, `BitNot`, `Shl`, `Shr`, `LShr`
- **Comparison**: `Eq`, `Ne`, `Lt`, `Le`, `Gt`, `Ge` (return boolean)
- **Boolean**: `And`, `Or`, `Not`
- **Other**: `Select` (ternary), `Min`, `Max`, `Abs`, type conversions

### Outputs (`outputs.rs`)

`SymbolicOutputs { arena, outputs }`: one run's written output elements as
`(index, root ExprId)` per array, sorted by index - the hand-off type
(`AnalysisResult::symbolic_outputs`, `spec::unfold`'s result, both sides of a
`VcDump`, the checker's input). `validate()` bounds-checks every id;
`element(array, index)` looks one up.

### Specs (`spec.rs`)

Mathematical specs: an output array as a formula over other arrays
(`OutputSpec`, `SpecExpr`, `Shape`, `SpecEnv`), unfolded by `unfold` into a
`SymbolicOutputs` with the arena's own constructors, so a kernel checks
against a spec exactly like against a second kernel (`volta verify`). The
`volta_spec` crate parses the textual `.spec` language into these types.

### Value equality (`value_equality.rs`)

`ValueEquality`: a same-value query over one arena;
`volta_equivalence::CanonValueEquality` implements it. The graph branch no
longer consumes it: the memory-conflict check (Algorithm 2) has no benign
equal-store exception.

### Text format (`text.rs`, `.vexpr`)

A producer-neutral exchange format: `write_text`/`to_text` and
`read_text`. Header `volta-expr 1`, then one node per line numbered densely
from `n0`, children before parents (sharing preserved, so size is linear in
the DAG), then `out "array" index nK` lines in ascending index order;
`#` comments and blank lines allowed.

```
volta-expr 1
n0 = elem "in" 0
n1 = elem "in" 1
n2 = add n0 n1
out "out" 0 n2
```

Operations: `int`/`real`/`bool`/`sym`/`param "name"`/`elem "array" i`/
`read "array" nK`/`discarded`/`undefined`, then the node names lowercased
(`add`, `fma`, `select`, `bitand`, `lshr`, `tofloat`, ...). Reals are exact
(`p/q`, `inf`, `-inf`). Only nodes reachable from an output are written, so
the interpreter's address/predicate scratch nodes drop out and the file is
deterministic. Reading rebuilds nodes exactly as written (no constant
folding) and validates; the writer's `match` is exhaustive over `ExprNode`,
so a new node kind cannot ship without a text form.

## Crate: volta_graph

**Path**: `crates/volta_graph/`

The typed operation/event graph of one candidate execution, recorded by the
analysis and consumed by the graph checks; depends only on
`volta_expr` (stored values are `ExprId`s of the analysis's arena). The
crate-level docs in `lib.rs` are the contract.

- Events (`EventId` = trace position) with an `ExecContext`: `Thread(t)`
  (program order of issuance), `Async(op)` (an async op's effect or
  completion, in no program order), `Generation(g)` (a generation's
  completion). Kinds: `Access`, `Contribute`, `WaitStart`, `Resume`,
  `GenerationComplete`, `AsyncIssue`, `AsyncComplete`, `GroupCommit`, `Fence`
  (`fence.proxy.async` over a space, `tcgen05.fence::before_thread_sync`,
  `::after_thread_sync`), `ObjectInit`/`ObjectInval`, `TmemAlloc`/`TmemDealloc`,
  `Exit`.
- `MemAccess`: space (`Global`/`Shared`/`Tensor`; local memory is not
  recorded), mode, `OrderingKind` (only `Ordinary` produced), proxy, canonical
  `Footprint` (byte range, or TMEM lane x column rectangle), attributed
  thread, stored value for writes.
- Sync objects (named barrier, mbarrier lifetime, warp/warpgroup collective,
  a thread's cp.async group waits) with logical `Generation`s: typed
  `Contribution`s (`Blocking`, `Arrival`, `Exited`, `AsyncCompletion`,
  `CompleteTx`), releases (`Resume` events), completion event, evidence.
  Collective instances have an `Entry` and an `Exit` generation around the
  op's effects.
- `AsyncOp`: issuer, issue event, effects, completion, tentative `tracking`
  generations (an mbarrier phase, a wait collective, a wait-group).
- `Terminal`: `Completed`, `Stuck` (each blocked thread's wait condition and
  state) or `Aborted` (partial graph). `Provenance`: launch, targets,
  `Assumption`s, per-instruction kind and source span.
- `EventGraph::validate` checks the representation invariants (every typed
  edge runs forward in trace order, so the relation is acyclic);
  `EventGraph::dump` is the deterministic `volta-graph 1` text form
  (`volta analyze --dump-graph FILE`).

## Crate: volta_analysis

**Path**: `crates/volta_analysis/`

### ID Types

Strongly-typed IDs (`#[id_type]` from `id_collections`), each declared next
to its subsystem:

- `InstrId` (`lowered.rs`), `ThreadId` (`eval/mod.rs`), `ParamId` and
  `RegId` = `RegClass` + `RegIndex` (`symbols.rs`; class: Pred,
  Bits8/16/32/64/128); the expression ids live in `volta_expr`
- `types.rs` holds `ScalarTypeExt` (width/kind helpers over the AST's
  `ScalarType`), not IDs

### Lowering (`lowering.rs`, `lowered.rs`)

Converts AST to linear instruction format:

- `LoweredProgram` - `IdVec<InstrId, LoweredInstr>` + `SymbolTable` + `SourceMap`
- `LoweredInstr` variants: `LoadParam`, `Load`, `Store`, `Mov`, `BinOp`, `UnaryOp`, `Fma`, `Mad`, `MulWide`, `MulHi`, `Setp`, `Selp`, `Cvt`, `Bra`, `Ret`, `Exit`, `BarSync`, `BarWarpSync`, `ShflSync`, `Ldmatrix`, `Mma`, `WmmaLoad/Store/Mma`, `Activemask`, `Trap`, etc.
- `SymbolTable` - Register/param/label name → ID resolution; assigns addresses to shared/local/module-global variables
- `SourceMap` - Maps lowered elements back to source spans
- The nvcc callseq idiom for `call __symexpf` (the paper's symbolic-exp hook) collapses to `UnaryOp::Exp` at lowering time
- The mbarrier retry loop `L: mbarrier.{try,test}_wait.parity p, [addr], ph; @!p bra L;` collapses to one blocking `MbarrierWaitParity` (`match_mbarrier_wait_loop`; the scheduler can block a thread, not spin it); a wait outside that exact three-statement window is a lowering error
- `define_instr_kinds!` generates the profiling table from one variant
  list: `KIND_COUNT`, `KIND_NAMES`, `kind_index()` (dense index for the
  interpreter's fixed-size counters), `kind_name()`

### Special Registers (`symbols.rs`)

`SpecialRegKind`: `TidX/Y/Z`, `NtidX/Y/Z`, `CtaidX/Y/Z`, `LaneId`, `WarpId`, etc.
The cluster registers are hardcoded for one CTA per cluster: `%cluster_ctaid`/
`%cluster_ctarank` are 0, `%cluster_nctaid`/`%cluster_nctarank` are 1, and
`%clusterid`/`%nclusterid` equal `%ctaid`/`%nctaid`, and `%is_explicit_cluster` is
false (an implicit 1x1x1 cluster).

### Evaluator (`eval/`)

The interpreter from the paper (per-thread round-robin symbolic execution):

- `eval/interp.rs` - `Interpreter`: scheduler (run a thread until it blocks or exits), instruction evaluation into the arena, barrier firing per the paper's Sync rule, deadlock detection, structured-CTA concreteness checks. Every sync (CTA barrier and warp group alike) deliberately uses the paper's Sync' rule for *firing*: exited threads count as arrived; tensor-core ops are the one deliberate exception (it would fire with returned threads, but the ISA makes exited-lane tensor ops whole-op UB, so Volta rejects them loudly instead). The interpreter runs one candidate schedule and performs **no** data-race or async-hazard checking (the former χ detector, `eval/race.rs`, was removed; graph-based verification replaces it)
- `eval/arithm.rs` - arithmetic evaluation as a second `impl Interpreter`: binary/unary ops, comparisons, `cvt`, the `ex2`/`lg2` base-conversion folds, and integer/width canonicalization of operands and of values crossing a register or memory width
- `eval/async_bulk.rs` - `cp.async.bulk{.tensor}` evaluation as another `impl Interpreter`: the TMA tensor copy and the plain bulk copy (global to shared, mbarrier-completed); the data lands eagerly at issue and the copy's `complete_tx` is applied then
- `eval/cluster_launch_control.rs` - `clusterlaunchcontrol.try_cancel`/`query_cancel` under the *never-steal* assumption: no cancel request ever succeeds, so every response is the declined one (encoded as 16 zero bytes, written like a `cp.async.bulk` destination - async proxy, 16-byte `complete_tx`); `is_canceled` always decodes `false`, any other value is rejected as unmodeled, and the ISA's UB cases (`get_first_ctaid` of a declined response, a new request after a decline was observed) are `EvalError::ClusterLaunchControlMisuse`; `.multicast::cluster::all` is rejected (it writes other CTAs' shared memory)
- `mapa.shared::cluster` assumes every cluster holds exactly one CTA: rank 0 maps an address to itself, any other concrete rank is `EvalError::MapaRankOutsideCluster`, and the generic (spaceless) form is rejected at lowering
- `eval/value.rs` - `Value::{Scalar, Pair}` (`Pair` = packed f16 halves in a 32-bit register) and per-thread `RegFile`
- `eval/memory.rs` - byte-addressed granule memory; 4-byte reads combine two 2-byte granules into a `Pair`, 2-byte accesses split `Pair` granules; program writes are `dirty` (the output footprint)
- `eval/warp.rs` - warp-cooperative ops (`bar.warp.sync`, `shfl.sync`, `ldmatrix`, `mma.sync`, `wmma.*`, the `.sync.aligned` `wgmma.fence`/`commit_group`/`wait_group`, whose register-hazard state stays per-thread): block until all *live* mask lanes converge at the pc (exited lanes count as arrived), execute via the `tensor_core.rs` fragment tables with exact per-lane access attribution; a shfl source lane that exited yields `Undefined` data, while the tensor-core ops reject exited lanes loudly (the ISA defines them as UB "if any thread in the warp has exited")
- `eval/warpgroup.rs` - `wgmma.mma_async`: a rendezvous of the full 128-thread warpgroup (exited threads count as arrived), computed eagerly at issue; each member's wgmma-groups record the op (`WgmmaOpId`) until its `wgmma.wait_group` releases it (a warp's wait covers the groups it committed itself). In the graph each member has a share (an async op); the warpgroup op completes as a whole, so a member warp's wait tracks every share of the instances it releases
- `eval/config.rs` - `AnalysisConfig`: launch dims, positional `ParamValue`s (int/float/symbolic-float/array-pointer), `ArrayDef`s (`Input`/`Output`/`InputOutput`/`IndexInput`), module-global values, dynamic shared size
- `eval/error.rs` - `EvalError`: the execution's own errors (`NotConcrete`, `OutOfBounds`, `UndefinedOutput`, `TrapReached`, the wgmma register hazards, etc.); data races and async hazards are not `EvalError`s but graph check failures, and a deadlock is the stuck terminal state the graph records

Key semantics: input-array symbols materialize lazily on first read; reads of
never-written registers/shared bytes yield `Undefined` (an error only if it
reaches an output or a concreteness point) - the paper's race example and
nvcc's `selp` accumulator-init idiom both rely on this.

### Analysis stage (`analysis.rs`)

- `analyze(module, kernel_name, config) -> Result<AnalysisResult, AnalysisError>`:
  lowering plus one candidate execution, no verdict. `AnalysisResult` holds
  the arena, the event graph (always; partial on abort), stats, op counts,
  and the symbolic outputs only when the execution completed and its outputs
  read back (`symbolic_outputs()` / `into_parts()`; else `OutputsUnavailable`:
  `Aborted`, `Stuck`, `Extraction`).
- `eval/record.rs` records the graph at the interpreter's effect and sync
  points (`AccessOrigin` tags async effects); its `Recording` bookkeeping is
  never read by execution.
- `write_op_counts(out, label, counts)` - the profile-table formatter `volta`
  prints

### Logging (`logging.rs`)

Gated by the `logging` feature (`volta_analysis` and `volta_equivalence`,
both passed through by `volta_cli`); without it the macros
are no-op stubs. Wired at the decision points: barrier/warp-group fires
(trace), deadlock (warn), launch config and completion stats (info) in
`volta_analysis`; VC session recycles (info) and fraction-equality
escalation (debug) in `volta_equivalence`. `cargo run -p volta_cli
--features logging -- --log-level info analyze ...` narrates a run.

## Crate: volta_graph_check

**Path**: `crates/volta_graph_check/`

Exactly the six checks of the Volta v2 design's data-race freedom check (§1.3
of the design document), one module each, each callable on an `EventGraph` in
isolation with explicitly passed certificates, each with its algorithm and
contract (PASS/FAIL/UNKNOWN meaning) in its module docs. Every check returns
`PropertyResult<E, V> = Pass(evidence) | Fail(witnesses) | Unknown(unresolved)`;
none turns an unsupported case into `Pass`. Depends only on `volta_graph`.

| # | `Property`          | Algorithm | Module                                |
|---|---------------------|-----------|---------------------------------------|
| 1 | `NamedBarrierEpoch` | 1         | `barrier_epoch.rs`                    |
| 2 | `MbarrierEpoch`     | 1         | `barrier_epoch.rs`                    |
| 3 | `MemoryConflict`    | 2         | `memory_conflict.rs`                  |
| 4 | `ProxyOrder`        | 3         | `proxy_order.rs`                      |
| 5 | `TensorOrder`       | 4 (+ 5)   | `tensor_order.rs`, `sync_search.rs`   |
| 6 | `ResourceLifetime`  | 6         | `resource_lifetime.rs`                |

- `relation.rs` - the typed edges `E = E_PO ∪ E_causal ∪ E_pipeline ∪ E_sync`
  and their projections, never used untyped: `IndependentGraph` (`G0`: program
  order, causal, every thread join, no mbarrier completion join) and
  `ValidatedGraph` (`G_HB` = Algorithm 4's `D`: `G0` plus the mbarrier
  completion joins), built only from both barrier-epoch certificates
  (`assuming_epochs` for isolated tests). Closure queries are a vector-clock
  sweep in trace order (an async effect reaches what an observer of its
  completion reaches); `successors()` gives `D` explicitly for Algorithm 5.
- `pipeline.rs` - `E_pipeline` (graph-construction step 5): same-thread
  `tcgen05.mma` chains on one accumulator, edges between accumulator effects
  only, with rule, roles and covered cells. No projection contains it.
- `domain.rs` - the memory domains: `M` (ordinary global/shared effects, async
  ones and shared-memory `tcgen05` operands included; Algorithms 2-3) and `A`
  (Tensor Memory effects of `tcgen05` ops; Algorithms 4 and 6).
- `barrier_epoch.rs` - Weft's separation criterion over `G0`: every
  synchronization `s` of generation `k` reaches (or is) the program
  predecessor of every operation `v` of `k + 1`; returns the first
  VIOLATION(s, v); a pass issues `NamedBarrierEpochs` / `MbarrierEpochs`.
- `memory_conflict.rs` - every overlapping pair of `M` with a write ordered in
  `G_HB`; `Fail` lists all of `B` (a per-byte dominance forest finds each
  unordered pair once, at its lowest byte); no benign equal-store exception;
  atomics are outside the contract (`Unknown`); a pass issues
  `MemoryConflictFree`.
- `proxy_order.rs` - every ordered cross-proxy pair needs a covering fence:
  an explicit `fence.proxy.async` on either side's thread, or the implicit fence
  of a validated completion observation (async -> generic). UNPROVEDPROXYORDER
  is `Unknown`, never `Fail`.
- `tensor_order.rs` / `sync_search.rs` - conflicting TMEM pairs of distinct ops,
  oriented by issue: pipelined, or a `D` path from issue to issue through a
  source-thread `tcgen05.fence::before_thread_sync` (or tracking
  `tcgen05.commit`) then a target-thread `::after_thread_sync`.
- `resource_lifetime.rs` - TMEM allocations: each use covered by its
  allocation, each allocation freed exactly once, then phase 1 (use reaches
  its dealloc) and phase 2 (alloc reaches the use).
- `suite.rs` - `check_graph(graph) -> GraphReport` runs them in
  `Property::ALL` order (a topological order of `Property::prerequisites`; a
  check whose prerequisites failed is `Unknown`); `GraphReport::conclusion()`:
  `Verified` (a completed trace and all six checks passing; nothing else is
  consulted) / `Rejected { failed, deadlock }` / `Unknown`. A stuck trace is
  the trace generator's deadlock diagnostic, an aborted one is inconclusive.

## Crate: volta_pipeline

**Path**: `crates/volta_pipeline/`

The integration point: `verify_kernel(module, kernel, config)` (analysis stage
+ the graph branch's six checks),
`check_equivalence` (the equivalence branch over symbolic outputs only; a
claimed difference is a refutation only once the numeric oracle separates it,
else `Unproven`), and `decide(equivalence, kernels) -> Decision { verdict,
evidence, assumptions }`: ACCEPT needs a complete (unsampled) equivalence proof
and every kernel `Verified`; any refutation, failed check or deadlock is REJECT;
anything else is UNKNOWN. Tests:
`aggregation_tests.rs` (real kernels through both branches) and
`architecture_tests.rs` (the stage/branch boundaries).

## Crate: volta_equivalence

**Path**: `crates/volta_equivalence/`

Everything after VC extraction: takes two `SymbolicOutputs` and decides them
element by element. Depends only on `volta_expr`, so it checks expressions
from any producer - in memory, from a `.vcdump`, or from `.vexpr` text.
`equiv::CanonValueEquality` implements the interpreter's `ValueEquality`
hook.

### Output checking (`check.rs`)

- `paired_elements(ref, opt, arrays)` - pairs the two outputs' written
  elements for each array the caller names (both sides must have each
  named array with identical index sets; unnamed arrays are not compared
  - FlashAttention's optimized-only `l`/`m` exports rely on this; an
  empty list is an error). Callers supply the list explicitly: the CLI
  requires it on the command line (`--check-array`).
  `sampled_elements(paired, sample)` flattens the paired footprints to
  each array's sampled prefix - the one definition of *which* elements
  get checked
- `check_output_equivalence_with(ref, opt, arrays, options)` - the per-element
  check, one shared `EquivSession` per solve iteration.
  `EquivCheckOptions`: `sample`, `verify_numeric` (f64 oracle per
  element; iteration 1 only), `recycle_terms`, `iterations`
  (`NonZeroUsize`, default 1: re-solve the same sampled elements N
  times, fresh session each - cold-start timings, memory bounded since
  each session drops before the next; the verdict comes from iteration 1
  and later iterations must agree, else `IterationDisagreement` - a
  free determinism check). Returns a report with the outcome,
  checked/total element counts, `check_iters: Vec<Duration>` (each
  iteration's summed `EquivSession::check` durations only - pairing and
  the oracle excluded; `check_time()` = iteration 1's), `element_checks:
  Vec<ElementCheckTime>` (iteration 1's per-element check durations in
  `sampled_elements` order - the same measurements `check_iters[0]`
  sums, recorded outside the timed spans, so carrying them is free), `pair_time`
  (the `paired_elements` call), and `verify_time` (the oracle's total
  time, `Some` iff `verify_numeric`).
- `check_output_equivalence(ref, opt, arrays)` - the Default-options wrapper
  (all elements, no oracle, one iteration)

### VC dumps (`vc_dump.rs`)

- `VcDump { reference, optimized }` (two `SymbolicOutputs`, wire-identical
  to the former `VcSnapshot`s) - serde-serializable arena + output footprint, the
  payload of `volta compare --dump-vcs`/`--from-dump`; `validate()` checks
  every id (in bounds and children-before-parents) so a corrupt dump errors
  instead of panicking. The arena's serde impls are plain derives over
  `IdVec` via `id_collections`'s `serde` feature (wire-identical to `Vec`,
  serialized in place - no clone of GiB-scale arenas at dump time).
- the one `.vcdump` on-disk format implementation:
  `write_vc_dump(path, &VcDump)` / `read_vc_dump(path)`, layered over
  `write_vc_dump_to(&mut impl Write, ..)` / `read_vc_dump_bytes(&[u8])`
  (to hash the exact byte stream on write through a tee writer, or
  fingerprint raw file bytes before decoding).
  `VOLTAVCD` magic
  + u16 major/minor header (a reader accepts its own major with minor <=
  its own), bincode fixint payload with decode allocations capped at
  payload size, `validate()` on load.

### Decision procedure (`canon/`, `equiv.rs`, `numeric.rs`)

The paper's canonicalizer, in Rust:

- `canon/` - expressions canonicalize to interned `Σ c·monomial·e^{poly}`
  rationals in one memoized bottom-up pass per `Session` (both kernels, all
  VC elements share intern tables). Exact i128 rational coefficients;
  `e^a·e^b` fuses at term multiplication; max/min flatten into sorted atoms;
  ops outside the fragment (sqrt/log/bitwise/comparisons/select/symbolic
  array reads) become opaque `Atom::Uninterp` atoms over an `UninterpOp`
  enum - sound, incomplete. Fraction equality goes id-compare →
  monomial-quotient (softmax rescaling) → cross-multiplication under a term
  budget. Two load-bearing invariants: single-use chain intermediates stay
  *transient* owned vectors (interning everything retains O(K²) per
  accumulator), and polys sort by *descending* TermId so chain unwinding
  appends in O(1).
- `equiv.rs` - thin wrapper: `EquivSession` (reuse across elements;
  recycles its intern tables past a configurable term bound -
  `with_recycle_terms`, default `DEFAULT_RECYCLE_TERMS` = 4M) and one-shot
  `check_equivalent`. Memory scale: exp-heavy attention terms run 2-4 KB
  each, so one warm FlashAttention output row retains several GiB; small
  bounds trade re-canonicalization time for bounded memory.
- `numeric.rs` - the f64 oracle: seeded random inputs, memoized DAG eval;
  `verify_verdict` confirms EQUIV/DIFF claims (`volta compare
  --verify-numeric`). Agreement at random points ⇒ equality almost surely
  for this fragment (the paper's own Schwartz-Zippel argument).

## Crate: volta_bench

**Path**: `crates/volta_bench/`

Only end-to-end tests: no library, no binary, dev-dependencies only. Each suite
in `tests/` runs PTX kernels from `tests/ptx/` through
`volta_pipeline::verify_kernel` (`common::check` / `common::run_kernel`):

- `accepted_tests.rs` - race-free kernels: the graph check must conclude
  `Verified`, then the rendered
  symbolic outputs must match the kernel's `.out` file exactly
  (`VOLTA_BLESS=1` rewrites them).
- one suite per check whose witnesses PTX kernels exercise, each asserting on
  that check's typed witness only: `memory_conflict_tests.rs` (Algorithm 2:
  conflict kind, byte, each side's thread, access mode and async op),
  `tensor_order_tests.rs` (Algorithm 4: the Tensor Memory cell and sides),
  `resource_lifetime_tests.rs` (Algorithm 6: the use freed while unordered).
- `rejected_tests.rs` - execution errors (`EvalError`, lowering errors, the
  wgmma register hazards) and deadlocks (the trace generator's diagnostic,
  `GraphReport::deadlock`).
- `graph_tests.rs` - the event graph the analysis stage records, no checker.
- `negative_equivalence_tests.rs` - kernel pairs differing in one semantic
  detail, each `Verified`, must not be proved equivalent.

## Crate: volta_cli

**Path**: `crates/volta_cli/`

Commands:

- `volta parse <file>` - Check syntax
- `volta analyze <file> -k <kernel> -b 32,4 -g 1,2 --array name:base:width:len:kind --param ptr:name ...` - Run the analysis stage and the graph branch: print output expressions (+ a per-instruction-kind profile; `--no-profile` to skip), every graph check's verdict (with its algorithm), the trace's deadlock and the first failure; `GRAPH VERIFICATION: VERIFIED|REJECTED|UNKNOWN` (exit 0/1/2); `--emit-exprs FILE` writes the outputs as `.vexpr` text, `--dump-graph FILE` the event graph
- `volta compare <ref.ptx> <opt.ptx> --kernel1 .. --kernel2 .. --check-array out` - Two-kernel
  equivalence check (launch flags shared with `analyze` via a flattened
  `LaunchArgs`; `--block2`/`--grid2` override the optimized kernel's dims).
  `--check-array NAME` (repeatable, required) names the output arrays to
  check - the explicit `paired_elements` list, checked against the
  declared config before execution and by `paired_elements` after.
  `--iterations N` (default 1), `--dump-vcs`/`--from-dump` (the
  `volta_equivalence::vc_dump` format). `--exprs` reads FILE1/
  FILE2 as `.vexpr` files instead (e.g. from `analyze --emit-exprs`): no PTX,
  no symbolic execution. With kernel inputs both branches run and `decide`
  prints `VERDICT: ACCEPT|REJECT|UNKNOWN` with its evidence and assumptions
  (exit 0/1/2; a sampled check is never ACCEPT); expression inputs
  (`--exprs`, `--from-dump`) run the equivalence branch only and exit 0 only
  when every checked element is proved equivalent.
- `volta verify <file> <spec>` - one kernel against a spec, through both
  branches and `decide` (exit 0/1/2).

Every run writes a `volta_common::run_log` file (`--log-dir`/
`--no-log-file`).

## Data Flow

```
PTX Source
    │
    ▼
Lexer (lex.rs) ──► Tokenizes source
    │
    ▼
Parser (parse.rs) ──► Builds AST
    │
    ▼
Instruction Parser (instr_parse.rs) ──► Strongly-typed ParsedInstruction
    │
    ▼
Lowering (lowering.rs) ──► LoweredProgram (resolved RegIds, InstrIds)
    │
    ▼
Evaluator (eval/interp.rs) ──► Symbolic execution with N threads
    │                           (one candidate schedule, warp/tensor-core ops)
    ▼
AnalysisResult ──► SymbolicOutputs (volta_expr) + EventGraph (volta_graph) + statistics
    │                 (no verdict; outputs optionally via .vcdump or .vexpr files)
    ├──────────────────────────────┐
    ▼                              ▼
volta_equivalence (canon/)     volta_graph_check (check_graph)
  per-element VC checking        the six checks (Algorithms 1-6), in order
  (+ numeric.rs oracle)
    └──────────────┬───────────────┘
                   ▼
volta_pipeline::decide ──► ACCEPT / REJECT / UNKNOWN (+ evidence, assumptions)
```

## Key Design Decisions

### 1. Symbolic Execution over Concrete Values

All values are `Expr` (symbolic expressions). This allows analyzing behavior for arbitrary thread indices and detecting races without enumerating all inputs.

### 2. Concrete Addresses for Race Detection

Memory addresses must be concrete (`u64`) for race detection. Thread indices are concrete (specific block configuration). Symbolic address accesses produce a `NotConcrete` error.

### 3. Race Detection Is Not Part of the Evaluator

The paper's χ-context detector (Section 4.2) used to run inside the interpreter. It was removed: the interpreter records a typed event graph of its one candidate schedule, and `volta_graph_check` verifies it downstream with the six checks of the Volta v2 design (memory conflicts through the typed `G_HB` projection, never untyped reachability). A kernel is VERIFIED when its trace completed and all six checks pass on it; no further schedule argument is consulted.

### 4. Round-Robin Scheduling

Simple, deterministic interleaving: the candidate execution. The six checks judge the event graph of this one execution (see 3).

### 5. Strongly-Typed IDs

Newtype pattern for IDs (`RegId`, `InstrId`, `ThreadId`) prevents mixing at compile time. Uses `IdVec<K, V>` for type-safe indexed collections.

### 6. Two-Phase Instruction Parsing

1. Lexer/Parser → generic `Instruction { op: String, operands }`
2. Instruction Parser → strongly-typed `ParsedInstruction` variants

Enables robust modifier validation and better error messages.

### 7. Separate Memory Spaces

Global, shared, local, param memories are separate `Memory` instances, matching PTX memory model.

## Adding a New Instruction

1. **Frontend**: Add `InstrKind` variant in `instr.rs`, add to trie
2. **Instruction Parsing**: Add `ParsedInstruction` variant, parser function
   in `instr_parse.rs` (use `expect_operands` for exact-arity operand lists)
3. **Lowering**: Add `LoweredInstr` variant, lowering case
4. **Evaluation**: Add evaluation case in `eval/interp.rs`

## Tooling

```sh
just check # run linters
just test  # run tests
```
