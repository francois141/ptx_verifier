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
├── volta_graph_check/ # Graph property checkers (one per property) and their suite
├── volta_analysis/   # Abstract interpreter (PTX -> expressions + event graph)
├── volta_equivalence/ # Equivalence checking of expressions (decision procedure, VC dumps)
├── volta_pipeline/   # Analysis -> {equivalence, graph} branches -> ACCEPT/REJECT/UNKNOWN
├── volta_z3/         # Z3 comparison backend (SMT-LIB2 via linked libz3)
├── volta_bench/      # Paper-evaluation benchmark harness
└── volta_cli/        # Command-line interface
```

### Dependency Graph

Direct dependencies of each crate:

```
volta_cli         → volta_pipeline, volta_z3, volta_equivalence, volta_analysis, volta_graph_check, volta_graph, volta_expr, volta_frontend, volta_common
volta_bench       → volta_pipeline, volta_z3, volta_equivalence, volta_analysis, volta_graph_check, volta_expr, volta_frontend, volta_common
volta_pipeline    → volta_analysis, volta_equivalence, volta_graph_check, volta_graph, volta_expr, volta_frontend
volta_z3          → volta_equivalence, volta_expr
volta_equivalence → volta_expr
volta_analysis    → volta_graph, volta_expr, volta_frontend, volta_common
volta_graph_check → volta_graph, volta_expr
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
dev-dependency `volta_spec` only), while PTX-to-verdict end-to-end tests live in
`volta_analysis/tests/` (dev-dependencies `volta_equivalence` and
`volta_graph_check`: `common::check` runs the stage and `check_graph`, and race
and deadlock tests assert on the failed property's typed witness).

## Crate: volta_common

**Path**: `crates/volta_common/`

- `Span` - Source location (low + high byte offset)
- `FileCache` - Caches file content to make sure we always use a consistent version of each file
- `Locate<E>` - Error wrapper with optional location info (span + file path)
- `report_error` - Produces an error message from a title, message, span, and file content. Extracts out and includes the code snippet at the given span in the given file content
- `run_log::RunLog` - Per-invocation log file (`<unix-seconds>-<pid>-<command>.log` under `--log-dir`, default `volta-logs/`), shared by the `volta` and `volta-bench` binaries; `tee` mirrors an `env_logger` target into it under the binaries' `logging` features

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
consumers (the decision procedure, Z3, the oracle). Depends on no other
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

`ValueEquality`: the memory-conflict checker's query for a benign same-value
store, passed explicitly to the graph branch (`SymbolicFacts`) so neither the
interpreter nor the checkers depend on a decision procedure;
`volta_equivalence::CanonValueEquality` implements it.

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
analysis and consumed by graph property checkers; depends only on
`volta_expr` (stored values are `ExprId`s of the analysis's arena). The
crate-level docs in `lib.rs` are the contract.

- Events (`EventId` = trace position) with an `ExecContext`: `Thread(t)`
  (program order of issuance), `Async(op)` (an async op's effect or
  completion, in no program order), `Generation(g)` (a generation's
  completion). Kinds: `Access`, `Contribute`, `WaitStart`, `Resume`,
  `GenerationComplete`, `AsyncIssue`, `AsyncComplete`, `GroupCommit`, `Fence`,
  `ObjectInit`/`ObjectInval`, `TmemAlloc`/`TmemDealloc`, `Exit`.
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
- `eval/error.rs` - `EvalError`: the execution's own errors (`NotConcrete`, `OutOfBounds`, `UndefinedOutput`, `TrapReached`, the wgmma register hazards, etc.); data races, async hazards and deadlocks are not `EvalError`s but graph property failures

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
- `write_op_counts(out, label, counts)` - the one profile-table formatter,
  used by both `volta` and `volta-bench`

### Logging (`logging.rs`)

Gated by the `logging` feature (`volta_analysis` and `volta_equivalence`,
both passed through by `volta_cli`/`volta_bench`); without it the macros
are no-op stubs. Wired at the decision points: barrier/warp-group fires
(trace), deadlock (warn), launch config and completion stats (info) in
`volta_analysis`; VC session recycles (info) and fraction-equality
escalation (debug) in `volta_equivalence`. `cargo run -p volta_cli
--features logging -- --log-level info analyze ...` narrates a run.

## Crate: volta_graph_check

**Path**: `crates/volta_graph_check/`

One checker per property, each callable on an `EventGraph` in isolation with
explicitly passed certificates, each with its contract (property, scope, uses,
prerequisites, PASS/FAIL/UNKNOWN meaning) in its module docs. Every checker
returns `PropertyResult<E, V> = Pass(evidence) | Fail(witnesses) |
Unknown(unresolved)`; none turns an unsupported case into `Pass`. Depends only
on `volta_graph` and `volta_expr`.

- `hb.rs` - happens-before over *admitted* typed edges only (vector-clock sweep
  in trace order): program order; contribution -> generation -> release for
  validated generations; async effects ordered after their issue and before
  the releases observing their validated completion (never into the issuer's
  program order); exited-thread arrival only under the Sync' assumption;
  `CompleteTx` orders nothing. A derived view: it certifies nothing.
- `well_formed.rs` (1) - representation invariants, terminal state, ordinary
  effects only.
- `barrier.rs` (3) - generation stability: Weft (PLDI'15) Fig. 4/Theorem 1 for
  named barriers; Volta's mbarrier adaptation (A1-A3, no theorem: failures are
  `Unknown`); collectives; emits the `SyncCertificate`.
- `async_completion.rs` (4) - each op's completion association re-derived from
  its instruction's mechanism (a commit is never completion); a warp syncing
  past an unwaited `tcgen05.ld/st` fails; emits the `CompletionCertificate`.
- `pipeline.rs` (6) - same-issuer `tcgen05.mma` chains on one accumulator
  (the only certified pipeline order); emits the `PipelineCertificate`.
- `proxy.rs` (5) - a generic write read by the async proxy needs a covering
  `fence.proxy.async` (writer's or reader's) ordered between them.
- `race.rs` (7) - memory-conflict freedom: W-R, W-W and R-W (buffer reuse) per
  byte / TMEM cell, FastTrack-style; ordered only through admitted edges or a
  certified pipeline pair; benign equal stores via the explicit
  `SymbolicFacts { arena, value_equality }`; atomics/reductions are
  unresolved, never judged by non-atomic rules. `Fail` only when unordered
  through every candidate edge.
- `lifetime.rs` (8) - TMEM alloc/dealloc and mbarrier init/inval lifetimes
  (T1/T2/M1/M2, each lifting an interpreter-trace check to every schedule);
  leaks and never-observed async ops at completion are unresolved.
- `progress.rs` (2) - stuck = `Fail` (deadlock); aborted = `Unknown`;
  completed passes only through validated generations and completions.
- `suite.rs` - `check_graph(graph, facts) -> GraphReport` runs them in
  `Property::ALL` order (a topological order of `Property::prerequisites`);
  `GraphReport::conclusion()`: `Verified` / `Rejected` / `Unknown`.
- `scope.rs` - `ProofScope`: `ScheduleIndependent` (ordinary effects,
  CTA/named barriers, warp collectives, cp.async group waits) or
  `CandidateOnly { reasons }` (async ops, mbarrier phases) - a candidate-only
  pass is never a verification.

## Crate: volta_pipeline

**Path**: `crates/volta_pipeline/`

The integration point: `verify_kernel` (analysis stage + graph branch),
`check_equivalence` (the equivalence branch over symbolic outputs only; a
claimed difference is a refutation only once the numeric oracle separates it,
else `Unproven`), and `decide(equivalence, kernels) -> Decision { verdict,
evidence, assumptions }`: ACCEPT needs a complete (unsampled) equivalence proof
and every kernel `Verified`; any refutation or failed property is REJECT;
anything else, a candidate-only pass included, is UNKNOWN. Tests:
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
  empty list is an error). Callers supply the list explicitly: the bench
  harness derives it from the reference config's declared output arrays;
  the CLI requires it on the command line (`--check-array`).
  Shared by the decision procedure and `volta_z3` so both backends check
  exactly the same elements. `sampled_elements(paired, sample)` flattens
  the paired footprints to each array's sampled prefix - the one
  definition of *which* elements get checked, used by both backends and
  the bench harness's Z3 re-solve loop
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
  sums, recorded outside the timed spans, so carrying them is free; the
  bench harness's `decision_elements`), `pair_time`
  (the `paired_elements` call), and `verify_time` (the oracle's total
  time, `Some` iff `verify_numeric`).
- `check_output_equivalence(ref, opt, arrays)` - the Default-options wrapper
  (all elements, no oracle, one iteration)

### VC dumps (`vc_dump.rs`)

- `VcDump { reference, optimized }` (two `SymbolicOutputs`, wire-identical
  to the former `VcSnapshot`s) - serde-serializable arena + output footprint, the
  payload of `volta compare --dump-vcs`/`--from-dump` and of volta-bench's
  per-benchmark VC files; `validate()` checks
  every id (in bounds and children-before-parents) so a corrupt dump errors
  instead of panicking. The arena's serde impls are plain derives over
  `IdVec` via `id_collections`'s `serde` feature (wire-identical to `Vec`,
  serialized in place - no clone of GiB-scale arenas at dump time).
- the one `.vcdump` on-disk format implementation:
  `write_vc_dump(path, &VcDump)` / `read_vc_dump(path)`, layered over
  `write_vc_dump_to(&mut impl Write, ..)` / `read_vc_dump_bytes(&[u8])`
  so volta-bench can hash the exact byte stream on write (through a tee
  writer) and fingerprint-check raw file bytes before decoding on solve.
  `VOLTAVCD` magic
  + u16 major/minor header (a reader accepts its own major with minor <=
  its own), bincode fixint payload with decode allocations capped at
  payload size, `validate()` on load. Shared by `volta_cli` and
  `volta_bench`, so a dump written by either tool loads in both.

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
  `verify_verdict` confirms EQUIV/DIFF claims (volta-bench
  `--verify-numeric`). Agreement at random points ⇒ equality almost surely
  for this fragment (the paper's own Schwartz-Zippel argument).

## Crate: volta_z3

**Path**: `crates/volta_z3/`

Z3 comparison backend for the same verification conditions: generates
SMT-LIB2 text and evaluates it through libz3's C API (`ffi.rs`, a
hand-written eight-function binding - no `z3-sys`/bindgen; building
requires `libz3-dev`). Each query runs in a **worker subprocess** (the
binary re-invokes itself via `std::process::Command`; thread-safe, no
separate executable) killed on timeout expiry: z3 4.8.12 does not
reliably honor its soft timeout or `Z3_interrupt` in the quantifier
loop the exp-axiom mode provokes (measured), so a hard kill is the only
real bound - which also gives per-element crash containment. Contract:
any binary that evaluates queries through this crate calls
`volta_z3::init_worker()` as the first statement of `main` (loudly
checked via a handshake). A capability/timing comparison point against
`canon`, not a replacement.

Two `ExpMode`s reproduce the paper's section 6.5 baselines: the default
`PowerBounded` (`(^ e a)`, bounded free `e`; attention VCs come back
`unknown`) and `AdditionAxiom` (uninterpreted `uexp` plus
`forall x y. uexp(x) uexp(y) = uexp(x+y)`; attention VCs run until the
budget kills them, reported `Timeout` - Table 8's "with axiom" column,
10-minute budget in the paper).

- `translate.rs` - a *direct semantic image* of the fragment
  (arithmetic + `Exp` + `Max`/`Min`; everything else `Unsupported`):
  every node maps to its defining SMT term and ALL algebraic reasoning
  is left to the solver, so timings measure Z3, not the translator
  (`max`/`min` are `ite` case splits, not opaque atoms; no
  canonicalization, no structural short-circuit). The translation owns
  fidelity/transport only: exact rational literals straight from
  `RealConst` (same reading as `canon`/`numeric`; the infinities are
  loud `Unsupported`), user symbols as an injection of the
  typed `SymbolRef` namespaces (`|p!name|` params, `|e!array[i]|`
  elements - a param named `t0`/`e` cannot capture generated names),
  memoized `let`-bound DAG sharing (query text linear in the arena;
  deeply nested `let`s are fine for z3, `define-fun` chains are not -
  measured), `stacker`-guarded recursion for deep accumulator spines,
  linear `let`-chain assembly, and the exp base as a strictly-bounded
  free constant (a definite rational base proved false equivalences).
  Inherited SMT semantic: division is underspecified at zero, so
  `x/x = 1` is falsifiable - unlike canon's field model (moot on the
  corpus: division only occurs inside exp-laden VCs).
- `ffi.rs` - `init_worker` (the host-binary hook that turns the
  re-invoked process into a solver worker), `eval_smtlib2` (spawns the
  worker, writes the query to its stdin, enforces the hard deadline via
  kill; inside the worker: fresh context per query, no-op error handler
  so z3 API errors surface as `(error ...)` text instead of aborting,
  soft timeout via the process-global `timeout` param) and `z3_version`.
  The worker times the libz3 evaluation itself (empty-script warmup
  first, so z3's lazy per-context frontend setup stays outside the
  span) and reports it in-band (a `t:<nanoseconds>` line after the
  handshake); `eval_smtlib2` returns it as
  `EvalOutcome::Output { text, solve }`. Solver time is measured there
  because the worker's fixed scaffolding - process
  spawn/exec/link/pipes ~1.6ms plus z3 context create/destroy and
  frontend setup ~9ms (all measured) - is several times an entire
  polynomial-fragment solve; an outer timer measures scaffolding, not
  z3.
- `lib.rs` - per-element querying (`check_equivalent`; every element is
  a genuine solver query - no structural short-circuit, so identical
  sides cost a full spawn+solve, which is the point), verdict
  parsing, `Z3Counts`, `check_output_equivalence` over
  `volta_equivalence::check::paired_elements` (the same element pairing as the decision
  procedure), and the regression tests for every invariant above.
  Reported solve time (`Z3CheckResult::solve`) is the in-worker
  measurement - process spawn and translation excluded; Timeout
  verdicts report the budget itself rather than a measurement (the
  paper's convention for timeout rows), under either delivery
  mechanism (hard kill or z3's in-band soft cancel).

## Crate: volta_bench

**Path**: `crates/volta_bench/`

Reproduces the paper's evaluation over `kernels/` (the `.cu` + `.ptx` for
every benchmark in the paper, organized by table/section).
Benchmark definitions with full launch/param configs live in
`src/benchmarks/*.rs`. Run with `cargo run --release -p volta_bench --
category <reduction|matmul|attention|causal|conv|agent|tilelang|race>
[--sample N] [--verify-numeric] [--recycle-terms N] [--iterations N]
[--z3] [--z3-timeout N] [--out-dir DIR]` (also `all`, `single <name>`,
`list`, and the phase-decoupled `generate`/`solve` below; release mode
matters: ~20x, and the binary prints loud stderr
warnings at startup for a debug build or, under the `logging` feature,
a `--log-level` of info+ - both corrupt timings).

One pipeline per benchmark (`src/runner.rs`): **VC generation**
(`--iterations` timed runs of lowering + both symbolic executions +
`paired_elements`; kernel files are read and parsed once, outside the
timed loop; only the last generation's outputs are kept - each
iteration drops its predecessor, peak memory = one generation - and
every iteration is fingerprint-checked against iteration 1: same
outcome kind, per-array footprints, and expression identities (arena
node count + per-element `ExprId`s - fresh deterministic arenas make id
equality a strong check at zero cost); rejections compare by rejection
kind only, since diagnostic text may embed schedule-dependent details -
verdict kinds are the contract; a mismatch fails the benchmark loudly), then
the dump written once from the last generation (timed as
`dump_write_secs`), then **decision solve** (`--iterations` runs via
`volta_equivalence::check_output_equivalence_with` - fresh session per iteration,
verdict from iteration 1, later iterations must agree), then the
optional **Z3 solve** (`--z3`; `src/z3_phase.rs`) over the exact same
`volta_equivalence::check::sampled_elements` list. Race-check benchmarks stop after
generation (no dump/solve/Z3). Every timed phase defaults to
`--iterations` 10; tables print medians (the convention: median is the
headline number - iteration 1 includes process/allocator warmup, the
median absorbs it), and the harness warns per benchmark when a phase's
CV (sample sd/mean) exceeds 0.10 (`runner::NOISY_CV_THRESHOLD`).

The Z3 phase (columns appear in the tables only under `--z3`) solves
with `ExpMode::PowerBounded`, plus a `+exp-axiom` sub-run
(`ExpMode::AdditionAxiom`) when the VCs contain `Exp` nodes. Solve
columns cover the deciding work only, so they are comparable:
decision = summed `EquivSession::check` (pairing and the optional
numeric oracle excluded), Z3 = in-worker libz3 solve time (worker
spawn/exec and translation excluded; timeout elements count the full
budget). One Z3 carve-out: elements whose iteration-1 outcome is
timeout/unsupported/error are solved once, their iteration-1 time
charged to every iteration's total (re-solving a timeout would multiply
its budget); Z3 verdict counts and per-element results always come from
iteration 1. A Z3 phase *failure* (not an unknown/timeout verdict -
those are data) fails the benchmark (`Z3PhaseOutcome::Failed`). Paper
Table 8 reproduction: `--sample 1 --z3 --z3-timeout 600 all`.

The pipeline's halves also run separately, calling the same phase
functions (no duplicated pipeline): `generate <all|category <c>|single
<name>>` runs the generation half only (`generate_inner`: fingerprint
check, dump write) and records each dump in `vcs/manifest.json`
(`src/manifest.rs`: benchmark name, timestamp, `vc_fingerprint` = FNV-1a
of the exact dump bytes as written - hashed through a tee writer, no
second in-memory copy - plus informational per-array element counts;
read-modify-write per dump with the read just before the atomic
temp+rename write, so partial regenerations keep other entries; single
writer per out-dir assumed) - race-check benchmarks reach their real
verdicts here, so the race table comes from a `generate` run (`RACE`
for a failed graph property that is a race, `OK` only when graph
verification is `Verified`, `UNKNOWN` (`ActualOutcome::Unverified`) when
nothing failed but verification is incomplete; every generation record
carries `graph_verification`);
equivalence benchmarks report `GEN` (`ActualOutcome::VcsGenerated`), a
failed dump/manifest write fails them (the dump is the product), and any
failure leaving no fresh dump also deletes the benchmark's stale dump +
manifest entry so a later `solve` errs on the missing dump instead of
silently solving pre-failure VCs. `solve <target> [--backend
decision|z3|both]` (`src/solve.rs`) replays the solve phase(s) from the
dumps via `check_equivalence`/`run_z3_phase`: each dump's raw bytes are
fingerprint-checked against the manifest *before* decoding (catches any
content difference from what the last successful `generate` recorded,
including same-shape expression drift; deliberately does not check
currency with the source tree - regenerated-together stale sets pass by
design; missing manifest = warning only), then decoded through the
shared validated reader (`dump_load_secs` recorded, excluded from solve
timings); a missing dump or a fingerprint/name disagreement is a
per-benchmark failure naming `generate` (with `dump_path` still set
whenever the file exists), race benchmarks are skipped with a note, and
`--backend z3` yields no decision verdict (`ActualOutcome::Z3Only`:
passing = the phase completed *and* z3 refuted nothing - a
`not_equivalent` count > 0, plain or `+exp-axiom`, fails the row as `Z3
DIFF`, since nothing else rules it and even a spurious refutation -
volta_z3's division-at-zero divergence - must surface;
unknown/timeout/unsupported stay non-failing data). `--sample` applies
to `solve`; `--verify-numeric`/`--recycle-terms` act on its decision
phase and `--z3-timeout` on its z3 phase (each noted-and-ignored under a
backend without that phase, and by `generate`); `--z3` is one-shot-only
and both new subcommands reject it. Records split accordingly:
`generate` records carry gen fields only, `solve` records carry solve
fields plus `dump_load_secs`, and the header adds `backend` +
`vcs_from_dumps`. Paper workflow: `generate all`, then `--recycle-terms
0 solve all`, `solve all --sample 1`, `solve all --sample 1 --backend z3
--z3-timeout 600` (Table 8; Table 7 is static, from `generate`).

Output files under `--out-dir` (default `bench-out/`, gitignored):
`vcs/<sanitized-name>.vcdump` per equivalence benchmark (written via the
shared `volta_equivalence::vc_dump` module, so `volta compare --from-dump` replays
them; overwritten on rerun; a run whose benchmark names collide under
sanitization is rejected up front naming both offenders -
`results::check_slug_collisions`, corpus-guarded by a test; race-check
benchmarks are skipped with a console note) and
`results/<unix-seconds>-<pid>-<command>.json` for every run command,
one schema (built in `src/results.rs`): header
(argv/timestamp/iterations/sample/recycle-terms/`z3` flag + timeout +
the carve-out convention) and per-benchmark records - status/detail/
passed, element counts, per-phase stats (`vc_gen_*` and `solve_*`: full
`*_iters_secs` array + median/min/mean/cv), `dump_write_secs`,
`verify_numeric_secs` (oracle time, `Some` iff the flag),
`decision_elements` (iteration 1's per-element decision times, from
`EquivCheckReport::element_checks`), a `z3` section (null without
`--z3`; else `solve_*` stats + verdict `counts` + iteration-1
`elements` as `{array, index, outcome, detail, solve_secs}`, an `axiom`
sub-section of the same shape or null, and `error`), instruction/sync
counters, and `dump_path` - kept on failures that occur after the dump
was written. `--json <path>` additionally writes the same document to
an explicit path. Results files are written before any console report
prints (`all`/`category` tables and `single`'s result block alike), and
report printing tolerates a broken stdout pipe (`| head`), so
the files always land. Every run writes a `volta_common::run_log` file
(`--log-dir`/`--no-log-file`).
Memory: full-element attention wants tens of GiB warm - on small machines
run one category at a time under `ulimit -v` with `--recycle-terms 250000`
(bounded at ~5 GiB, slower VCs).

## Crate: volta_cli

**Path**: `crates/volta_cli/`

Commands:

- `volta parse <file>` - Check syntax
- `volta analyze <file> -k <kernel> -b 32,4 -g 1,2 --array name:base:width:len:kind --param ptr:name ...` - Run the analysis stage and the graph branch: print output expressions (+ a per-instruction-kind profile; `--no-profile` to skip), every graph property's verdict, the proof scope and the first failure; `GRAPH VERIFICATION: VERIFIED|REJECTED|UNKNOWN` (exit 0/1/2); `--emit-exprs FILE` writes the outputs as `.vexpr` text, `--dump-graph FILE` the event graph
- `volta compare <ref.ptx> <opt.ptx> --kernel1 .. --kernel2 .. --check-array out` - Two-kernel
  equivalence check (launch flags shared with `analyze` via a flattened
  `LaunchArgs`; `--block2`/`--grid2` override the optimized kernel's dims).
  `--check-array NAME` (repeatable, required) names the output arrays to
  check - the explicit `paired_elements` list, checked against the
  declared config before execution and by `paired_elements` after.
  `--backend decision|z3`, `--iterations N` (decision backend only,
  default 1), `--dump-vcs`/
  `--from-dump` (the shared `volta_equivalence::vc_dump` format - volta-bench's
  `bench-out/vcs/*.vcdump` files replay here too). `--exprs` reads FILE1/
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
  per-element VC checking        one checker per property, dependency order
  (+ numeric.rs oracle)          (+ ProofScope)
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

The paper's χ-context detector (Section 4.2) used to run inside the interpreter. It was removed: the interpreter records a typed event graph of its one candidate schedule, and `volta_graph_check` verifies it downstream, one checker per property (memory conflicts through typed happens-before, never untyped reachability). Passing every property implies schedule independence only in the `ProofScope::ScheduleIndependent` fragment; elsewhere it is a candidate-execution fact, reported as UNKNOWN.

### 4. Round-Robin Scheduling

Simple, deterministic interleaving: the candidate execution. A conflict unordered through every candidate edge proves a race; absence of one proves nothing on its own (see 3).

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
