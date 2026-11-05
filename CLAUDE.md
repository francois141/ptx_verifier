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
  - Describe lasting roles and invariants, not temporary development status such as "scaffold", "empty", or "not implemented yet".
  - Only document non-obvious invariants, assumptions, or design decisions.
  - Do not split long comments into multiple blocks to bypass this limit.
- READMEs: every crate has a `README.md` explaining it. A change to a crate's API, behavior, structure or tests updates that crate's README in the same commit, along with the crate's section of this file.

## Crate Structure

```
crates/
├── volta_common/     # Base utilities (spans, file caching, error reporting, run logs)
├── volta_expr/       # Expression language (arena, SymbolicOutputs, .vexpr text format)
├── volta_spec/       # Specs (.spec language -> mathematical form -> SymbolicOutputs)
├── volta_graph/      # Typed event graph of one candidate execution (model, builder, invariants, dump)
├── volta_graph_check/ # The seven graph checks of the Volta v2 design (Algorithms 1-7), allocation order and permit, mbarrier release order, and their suite
├── volta_ptx_analysis/ # PTX frontend (lexer, parser) and abstract interpreter (PTX -> expressions + event graph)
├── volta_amd_analysis/ # AMD kernel analysis
├── volta_trainium_analysis/ # Trainium (NKI) kernel analysis
├── volta_equivalence/ # Equivalence checking of expressions (decision procedure, VC dumps)
├── volta_pipeline/   # Analysis -> {equivalence, graph} branches -> ACCEPT/REJECT/UNKNOWN; every end-to-end PTX test
├── volta_viz/        # Event-graph viewer (run store -> one self-contained HTML page)
└── volta_cli/        # Command-line interface
```

### Dependency Graph

Direct dependencies of each crate:

```
volta_cli          → volta_pipeline, volta_equivalence, volta_ptx_analysis, volta_graph_check, volta_graph, volta_viz, volta_spec, volta_expr, volta_common
volta_viz          → volta_graph_check, volta_graph, volta_expr
volta_pipeline     → volta_ptx_analysis, volta_equivalence, volta_graph_check, volta_graph, volta_expr (+ dev: volta_amd_analysis, volta_trainium_analysis, volta_spec, volta_viz)
volta_equivalence  → volta_expr (+ dev: volta_spec)
volta_spec         → volta_expr, volta_common
volta_ptx_analysis → volta_graph, volta_expr, volta_common
volta_amd_analysis → volta_expr (+ dev: volta_spec)
volta_trainium_analysis → volta_expr
volta_graph_check  → volta_graph
volta_graph        → volta_expr
volta_expr         → (nothing)
volta_common       → (nothing)
```

`volta_ptx_analysis` (the producer) and `volta_equivalence` (the consumer) share
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
`volta_pipeline/tests/` (kernels under `tests/ptx/`): `common::check` runs
`volta_pipeline::verify_kernel`, race and deadlock tests assert on the failed
property's typed witness, and every kernel run expected to complete must
conclude `Verified` (not merely unrejected) before its symbolic outputs are
compared with the kernel's `.out` file
(`VOLTA_BLESS=1` rewrites them). `volta_ptx_analysis` keeps only its inline unit
tests of internals.

## Crate: volta_common

**Path**: `crates/volta_common/`

- `Span` - Source location (low + high byte offset)
- `FileCache` - Caches file content to make sure we always use a consistent version of each file
- `Locate<E>` - Error wrapper with optional location info (span + file path)
- `report_error` - Produces an error message from a title, message, span, and file content. Extracts out and includes the code snippet at the given span in the given file content
- `run_log::RunLog` - Per-invocation log file (`<unix-seconds>-<pid>-<command>.log` under `--log-dir`, default `volta-logs/`), written by the `volta` binary; `tee` mirrors an `env_logger` target into it under its `logging` feature

The pattern is to create an error kind type, and then an alias for `Locate` of that error kind. `locate_span` can be used to tag a `Locate` with a span if it does not already have one. `locate_path` can be used to tag a `Locate` with a path if it does not already have one.

## Crate: volta_expr

**Path**: `crates/volta_expr/`

The expression language shared by producers (the interpreter, `volta_spec`) and
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
(`AnalysisResult::symbolic_outputs`, `volta_spec::unfold`'s result, both sides of a
`VcDump`, the checker's input). `validate()` bounds-checks every id;
`element(array, index)` looks one up.

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

### Lean challenges (`lean.rs`)

`to_lean(candidate, baseline, arrays, claim, namespace)`: a Lean 4 / Mathlib module
of one `def <array>_<index> : Prop` per paired element, `Claim::Equal` (`c = b`) or
`Claim::Within(tol)` (`|c - b| ≤ tol`, exact). A prover proves the definitions in
its own module, so it never writes a statement. Values are `ℝ` (input element `a[i]`
is the variable `a_i`; params and machine symbols are `ℝ` variables too, all universally
quantified; two inputs with one Lean name are an error), comparisons are
`Prop`s, literals are exact and ascribed `ℝ`, and non-leaf real nodes used twice are
`let`-bound. Bitwise ops, `rem`, infinities, symbolic reads and undefined values are
errors (`LeanError`).

## Crate: volta_spec

**Path**: `crates/volta_spec/`

The textual `.spec` language and the mathematical form it denotes:
`parse_spec` (`lex.rs`, `parse.rs`) produces a `ParsedSpec` (`ast.rs`) with
named dims; `instantiate` gives the dims values; `spec.rs` holds the result.

Mathematical specs: an output array as a formula over other arrays
(`OutputSpec`, `SpecExpr`, `Shape`, `SpecEnv`), unfolded by `unfold` into a
`SymbolicOutputs` with the arena's own constructors, so a kernel checks
against a spec exactly like against a second kernel (`volta verify`).
`extract_expressions_from_spec(source, dims)` runs parse, instantiate and unfold
in one call (every element; `ExtractError` names the failed stage).

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
  `::after_thread_sync`, the tensor-map release and acquire of a map),
  `ObjectInit`/`ObjectInval`, `TmemAlloc`/`TmemDealloc`/`TmemRelinquish`,
  `Exit`.
- `MemAccess`: space (`Global`/`Shared`/`Tensor`; local memory is not
  recorded), mode, `OrderingKind` (only `Ordinary` produced), proxy, canonical
  `Footprint` (byte range, or TMEM lane x column rectangle), attributed
  thread, stored value for writes.
- Sync objects (named barrier, mbarrier lifetime, warp/warpgroup collective,
  a thread's cp.async group waits) with logical `Generation`s: typed
  `Contribution`s (`Blocking`, `Arrival`, `Exited`, `AsyncCompletion`,
  `CompleteTx`, `ExpectTx`; an `Arrival`'s `ArrivalOrdering` says whether it
  is the thread's release or an async-tracked arrive-on), releases (`Resume`
  events), completion event, evidence.
  Collective instances have an `Entry` and an `Exit` generation around the
  op's effects; their `MemberOrdering` is `Synchronizing` only for
  `bar.warp.sync`, else `ExecutionOnly` (`tcgen05.alloc` included): the
  members' contributions join nothing, only tracked async completions do. An mbarrier lifetime starts with an `MbarrierPreInit`
  generation, completed at init with no contributions: an odd-parity wait on
  the fresh object (the ISA's "immediately preceding phase") resumes from it.
- `AsyncOp`: issuer, issue event, effects, completion, tentative `tracking`
  generations (an mbarrier phase, a wait collective, a wait-group).
- `Terminal`: `Completed`, `Stuck` (each blocked thread's wait condition and
  state) or `Aborted` (partial graph; its `AbortCause` is `Unsupported` for
  behavior the producer does not model, else `Error`). `Provenance`: launch, targets,
  `Assumption`s, per-instruction kind and source span.
- `EventGraph::validate` checks the representation invariants (every typed
  edge runs forward in trace order, so the relation is acyclic);
  `EventGraph::dump` is the deterministic `volta-graph 1` text form
  (`volta analyze --dump-graph FILE`).

## Crate: volta_ptx_analysis

**Path**: `crates/volta_ptx_analysis/`

Every module but `frontend` is private: `lib.rs` re-exports the whole API (`analyze`,
`AnalysisResult`, `AnalysisParts`, `AnalysisError`, `write_op_counts`, the
`AnalysisConfig` types, `EvalError`, `ClcMisuse`, `OutputsUnavailable`,
`Stats`, `ThreadId`, `LowerError`), so rustc flags any code it does not
reach. Other crates import from the root (`volta_ptx_analysis::AnalysisConfig`).

### Frontend (`frontend/`)

The one public module (`volta_ptx_analysis::frontend::{parse, ast, ...}`): PTX
text to a typed AST. It imports nothing else of the crate, nor `volta_expr`
or `volta_graph` (`architecture_tests.rs` enforces it).

#### Lexer (`lex.rs`)

Tokenizes PTX source. Key methods: `next()`, `peek()`, `expect(kind)`.

#### Parser (`parse.rs`)

Pratt parser producing AST. Entry point: `parse_module()`.
Unknown directive names are rejected with a located `InvalidDirective`.

#### AST (`ast.rs`)

- `Module` - Top-level: version, target, address_size, directives
- `Function` - Kernel/device function with params and body
- `Instruction` - Generic instruction: the trie already resolves the mnemonic to a typed `InstrKind` at parse time (`InstructionOp::Unparsed { kind, modifiers, operands }`)
- `ScalarType` - Pred, Signed/Unsigned/Float/Bits with width

#### Instruction Parsing (`instr.rs`, `instr_parse.rs`)

- `InstrTrie` - O(n) lookup for PTX mnemonics → `InstrKind`
- `ParsedInstruction` - Strongly-typed enum (~105 instruction variants, defined in `ast.rs`)
- Converts generic `Instruction` to typed variants with validated modifiers
- `ret` and `ret.uni` require exactly zero operands.
- `mbarrier.arrive` takes two or three operands.
- `exit`, `brkpt`, and `trap` require zero operands and accept no modifiers.

### ID Types

Strongly-typed IDs (`#[id_type]` from `id_collections`), each declared next
to its subsystem:

- `InstrId` (`ir/mod.rs`), `ThreadId` (`eval/mod.rs`), `ParamId` and
  `RegId` = `RegClass` + `RegIndex` (`ir/symbols.rs`; class: Pred,
  Bits8/16/32/64/128); the expression ids live in `volta_expr`
- `ir/types.rs` holds `ScalarTypeExt` (width/kind helpers over the AST's
  `ScalarType`), not IDs

### Lowering (`lower/`) and the IR (`ir/`)

Converts AST to linear instruction format: the IR in `ir/` (`mod.rs`,
`symbols.rs`, `source_map.rs`, `types.rs`, `tensor_map.rs`, `mma.rs`), the only contract
between `lower/` and `eval/` (neither imports the other; `ir/` reaches `lower/`
only for the `LowerError` of `SymbolTable`'s declarations). `lower/` is split by
instruction family, each file depending only on `context` and `error`:

- `lower/mod.rs` - `lower_function`, declaration collection, the statement
  walk and the `ParsedInstruction` dispatch (one call or expression per arm);
  `context.rs` - `LoweringContext` (the program under construction), operand
  resolution, type checks and `unsupported`; `error.rs` - `LowerError`;
  `idioms.rs` - the multi-statement idioms below
- one file per family: `arith.rs` (arithmetic, logic/shift/bit-field ops,
  setp/selp, `cvt`), `memory.rs` (mov, ld/st, params, cvta/mapa, `cp.async`),
  `control.rs` (`bra`, `call`, `bar`, `fence`), `warp.rs` (shfl/elect/redux,
  bar.warp.sync, ldmatrix/stmatrix, `mma.sync`, wmma),
  `mbarrier.rs`, `tma.rs` (tensormap objects, `cp.async.bulk{.tensor}`),
  `tcgen05.rs`, `clc.rs`; tests in `lower/tests.rs`
- `LoweredProgram` - `IdVec<InstrId, LoweredInstr>` + `SymbolTable` + `SourceMap`
- `LoweredInstr` variants: `LoadParam`, `Load`, `Store`, `Mov`, `BinOp`, `UnaryOp`, `Fma`, `Mad`, `MulWide`, `MulHi`, `Setp`, `Selp`, `Cvt`, `Bra`, `Ret`, `Exit`, `BarSync`, `BarWarpSync`, `ShflSync`, `Ldmatrix`, `Mma`, `WmmaLoad/Store/Mma`, `Trap`, etc.
- `SymbolTable` - Register/param/label name → ID resolution; assigns addresses to shared/local/module-global variables
- `SourceMap` - Maps each lowered instruction back to its source span
- The nvcc callseq idiom for `call __symexpf` (the paper's symbolic-exp hook) collapses to `UnaryOp::Exp` at lowering time
- The mbarrier retry loop `L: mbarrier.{try,test}_wait.parity p, [addr], ph; @!p bra L;` collapses to one blocking `MbarrierWaitParity` (`match_mbarrier_wait_loop`; the scheduler can block a thread, not spin it); a wait outside that exact three-statement window is a lowering error
- An immediate `mbarrier.init`/`mbarrier.arrive` count outside `ir::MBARRIER_COUNT_RANGE` (`[1, 2^20 - 1]`) is a lowering error; a register one aborts the run (`EvalError::MbarrierCountOutOfRange`)
- `mbarrier.inval` is unsupported for now (after its state-space check): mbarrier operations other than `init` (a write of the 8-byte object) are not memory accesses of the event graph and no check orders an object's other operations before its invalidation, so a late `arrive` racing with the reuse of its bytes would go unnoticed
- `activemask` is unsupported for now: the interpreter does not model warp divergence, so inside a divergent branch it would report the other side's lanes as active too and hide, e.g., two sides each electing a leader that stores to the same address
- `wgmma` is unsupported for now: every form (`mma_async{.sp}`, `fence`, `commit_group`, `wait_group`) is a lowering error, though the frontend still parses it
- `define_instr_kinds!` generates the profiling table from one variant
  list: `KIND_COUNT`, `KIND_NAMES`, `kind_index()` (dense index for the
  interpreter's fixed-size counters), `kind_name()`

### Special Registers (`ir/symbols.rs`)

`SpecialRegKind`: `TidX/Y/Z`, `NtidX/Y/Z`, `CtaidX/Y/Z`, `LaneId`, `WarpId`, etc.
The cluster registers are hardcoded for one CTA per cluster: `%cluster_ctaid`/
`%cluster_ctarank` are 0, `%cluster_nctaid`/`%cluster_nctarank` are 1, and
`%clusterid`/`%nclusterid` equal `%ctaid`/`%nctaid`, and `%is_explicit_cluster` is
false (an implicit 1x1x1 cluster).

### Evaluator (`eval/`)

The interpreter from the paper (per-thread round-robin symbolic execution):

- `eval/interp.rs` - `Interpreter`: its state, `new`/`run`/`finish`, single-instruction evaluation into the arena (`step`), operand/register and memory access, structured-CTA concreteness checks
- `eval/schedule.rs` - the scheduler: run a ready thread until it blocks or exits, then fire a complete group (warp rendezvous, mbarrier phase, named barrier per the paper's Sync rule); when nothing can fire, `Interpreter::run` ends `Stuck` (deadlock). A named barrier id's first arrival pins its count for the whole run (register ids included); a later arrival naming another count aborts it with `EvalError::BarrierMismatch`, so the result is inconclusive. A warp executes an `.aligned` barrier (every `bar.*`, and `barrier.*.aligned`) as one collective: its lanes arriving at two such instructions wait at two barriers, so the generation cannot fire (a deadlock); different warps may arrive from their own instructions, and an unaligned `barrier.*` from any. Every sync (CTA barrier and warp group alike) deliberately uses the paper's Sync' rule for *firing*: exited threads count as arrived; tensor-core ops are the one deliberate exception (it would fire with returned threads, but the ISA makes exited-lane tensor ops whole-op UB, so Volta rejects them loudly instead). The interpreter runs one candidate schedule and performs **no** data-race or async-hazard checking (the former χ detector, `eval/race.rs`, was removed; graph-based verification replaces it)
- `eval/arithm.rs` - arithmetic evaluation as a second `impl Interpreter`: binary/unary ops, comparisons, `cvt`, the `ex2`/`lg2` base-conversion folds, the packed-pair/quad bitwise ops and `shf`, and integer/width canonicalization of operands and of values crossing a register or memory width
- `eval/cp_async.rs` - non-bulk `cp.async`: the pending copy and its landing at a completion point
- `eval/tcgen05.rs` - `tcgen05.mma` evaluation over the descriptors `eval/tcgen05_mma.rs` decodes
- `eval/tensormap_replace.rs` - `tensormap.replace` evaluation (fields kept in `eval/tensor_map_table.rs`); the graph records each replace as a write of the whole opaque 128-byte object; `fence.proxy.tensormap::generic.release`/`.acquire [map]` and `tensormap.cp_fenceproxy`'s trailing release are graph fences
- `eval/async_bulk.rs` - `cp.async.bulk{.tensor}` evaluation as another `impl Interpreter`: the TMA tensor copy and the plain bulk copy (global to shared, mbarrier-completed); the data lands eagerly at issue and the copy's `complete_tx` is applied then; the TMA copy also reads its 128-byte tensor map, an effect of the copy through the tensor-map proxy (`Proxy::TensorMap`)
- `eval/cluster_launch_control.rs` - `clusterlaunchcontrol.try_cancel`/`query_cancel` under the *never-steal* assumption: no cancel request ever succeeds, so every response is the declined one (encoded as 16 zero bytes, written like a `cp.async.bulk` destination - async proxy, 16-byte `complete_tx`); `is_canceled` always decodes `false`, any other value is rejected as unmodeled, and the ISA's UB cases (`get_first_ctaid` of a declined response, a new request after a decline was observed) are `EvalError::ClusterLaunchControlMisuse`; `.multicast::cluster::all` is rejected (it writes other CTAs' shared memory)
- `mapa.shared::cluster` assumes every cluster holds exactly one CTA: rank 0 maps an address to itself, any other concrete rank is `EvalError::MapaRankOutsideCluster`, and the generic (spaceless) form is rejected at lowering
- `eval/value.rs` - `Value::{Scalar, Pair}` (`Pair` = packed f16 halves in a 32-bit register) and per-thread `RegFile`
- `eval/memory.rs` - byte-addressed granule memory; 4-byte reads combine two 2-byte granules into a `Pair`, 2-byte accesses split `Pair` granules; program writes are `dirty` (the output footprint)
- `eval/warp.rs` - warp-cooperative ops (`bar.warp.sync`, `shfl.sync`, `ldmatrix`, `mma.sync`, `wmma.*`, the warp-scoped `tcgen05` ops, `tensormap.cp_fenceproxy`, which copies the map once per warp as its leader and, being `.aligned`, rejects exited lanes): block until all *live* mask lanes converge at the pc (exited lanes count as arrived), execute via the `eval/fragments.rs` tables with exact per-lane access attribution; a shfl source lane that exited yields `Undefined` data, while the tensor-core ops reject exited lanes loudly (the ISA defines them as UB "if any thread in the warp has exited")
- `eval/error.rs` - `EvalError`: the execution's own errors (`NotConcrete`, `OutOfBounds`, `UninitializedMemory`, `UndefinedOutput`, `TrapReached`, etc.); data races and async hazards are not `EvalError`s but graph check failures, and a deadlock is the stuck terminal state the graph records

Key semantics: input-array symbols materialize lazily on first read; a read of a
never-written register yields `Undefined` (an error only if it reaches an output
or a concreteness point) - nvcc's `selp` accumulator-init idiom relies on this. A
read of never-written memory is an error: local memory aborts at the read, while
shared and global bytes (outside the inputs) and Tensor Memory cells read
`Undefined` and the run aborts with the first such read
(`UninitializedMemory`/`Tcgen05UninitializedRead`) once every thread exited, so a
read racing a later write (the paper's race example) keeps its race witness in
the complete graph. An `mbarrier.init` of a live object (UB without
`mbarrier.inval`) ends the run the same way (`MbarrierReinit`), so a re-init
racing another thread's use of the object keeps its witness.

### Analysis stage (`analysis.rs`, `config.rs`)

- `config.rs` - `AnalysisConfig`: launch dims, positional `ParamValue`s (int/float/symbolic-float/array-pointer), `ArrayDef`s (`Input`/`Output`/`InputOutput`/`IndexInput`), module-global values, dynamic shared size
- `launch_file.rs` - `LaunchFile::from_json`: the JSON launch file (`volta analyze --config FILE`) to the kernel it names + a validated `AnalysisConfig`; arrays by `dtype`/`shape`, auto-laid out on 64 KiB boundaries unless given a `base`; params `{"int"|"float"|"sym"|"ptr": ...}` with an optional reader-only `name`; unknown keys are errors
- No behavior depends on the module's `.target` directive (recorded in the
  graph's `Provenance` only): every kernel is analyzed and checked as on
  Blackwell, so the proxy-order check always runs
- `analyze(module, kernel_name, config) -> Result<AnalysisResult, AnalysisError>`:
  lowering plus one candidate execution, no verdict. `AnalysisResult` holds
  the arena, the event graph (always; partial on abort), stats, op counts,
  and the symbolic outputs only when the execution completed and its outputs
  read back (`symbolic_outputs()` / `into_parts()`; else `OutputsUnavailable`:
  `Aborted`, `Stuck`, `Extraction`). `arena()` reaches the arena the graph's
  stored values live in either way.
- `eval/record.rs` records the graph at the interpreter's effect and sync
  points (`AccessOrigin` tags async effects); its `Recording` bookkeeping is
  never read by execution.
- `write_op_counts(out, label, counts)` - the profile-table formatter `volta`
  prints

### Logging (`logging.rs`)

Gated by the `logging` feature (`volta_ptx_analysis`, `volta_equivalence`,
`volta_graph_check` and `volta_pipeline`, all passed through by `volta_cli`);
without it the macros are no-op stubs. Wired at the decision points:
barrier/warp-group fires (trace), deadlock (warn), launch config and
completion stats (info) in `volta_ptx_analysis`; VC session recycles (info) and
fraction-equality escalation (debug) in `volta_equivalence`; the stages at
info, tagged `[analysis]`/`[graph]`/`[equivalence]`: graph extraction and
the equivalence branch in `volta_pipeline`, each of the ten checks (start,
verdict, duration) in `check_graph`. `cargo run -p volta_cli
--features logging -- --log-level info analyze ...` narrates a run.

## Crate: volta_amd_analysis

**Path**: `crates/volta_amd_analysis/`

AMD kernel analysis. The module layout separates assembly syntax (`frontend`),
lowering (`lower`), the instruction representation (`ir`), and symbolic execution (`eval`).
The frontend is public; the root re-exports `lower_kernel`, `LowerError`, and the
IR types. `frontend::parse::parse_kernel(source, name)` extracts the target,
operand syntax, and numeric descriptor settings, rejecting empty comma-separated
operands and duplicate settings.
`lower_kernel(&kernel)` validates supported gfx950 instruction forms and preserves
physical register identities, explicit waits, and launch metadata. Unsupported
targets, instructions, or operand forms produce `LowerError`.
The target directive requires exactly one quoted string, rejecting unbalanced
or extra quotes and extra string arguments.
`WaveRegisters` stores one wave's register values as `volta_expr` expressions.
The internal `initialize_wave` maps a supported descriptor and `WaveLaunch` inputs
to initial registers. It accepts full waves in 1D, 2D, and 3D workgroups, matching
[AMD's X/Y/Z launch interface](https://releases.llvm.org/21.1.0/docs/AMDGPUUsage.html#initial-kernel-execution-state),
and rejects unsupported launch layouts. `execute_scalar` handles wave-wide loads from
kernel arguments or global inputs, up to sixteen words, for XNACK-disabled execution.
`KernargBuffer` holds read-only argument bytes; global inputs retain their symbolic
values. Pending scalar destinations reject reads and writes until a zero LGKM wait.
`execute_lane` evaluates an instruction for a caller-selected active lane.
`ds_bpermute_b32` gathers source register values across the wave before changing any
of its destinations; results use the existing LGKM completion tracking.
`ArrayDef` marks each global-memory array `Input` or `Output(OutputType)`. Inputs
are read-only and outputs cannot be loaded. Global and buffer stores interpret
`F32` outputs as mathematical reals and require concrete words for `U32` outputs;
invalid values abort at the store. `analyze` returns a completed run's written
output elements as `SymbolicOutputs` and none for an aborted run.
Unsupported instructions return `EvalError`. All lanes stay active; EXEC-changing
instructions are rejected. Integer and bitwise operations require concrete words because
symbolic values are floats and do not represent bit patterns, so integer arithmetic and
sign-mask tricks on symbolic values are rejected; floating-point arithmetic and transfers,
including lane exchanges, remain supported. A select between two different constant words
under a symbolic condition is rejected (`AmbiguousSelect`).
Negated select sources use floating-point semantics, so they are not ambiguous.
F32 e64 comparisons, e64 selects, f32 FMA and three-source f32 operations accept absolute-value
and negation input modifiers on any source; these operate on mathematical expressions.
E64 comparisons write VCC or an SGPR pair.
Packed f32 add, multiply and FMA share component selection and negation handling;
each register holds one real expression, and either selector reads the same inline constant.
An f64 register pair holds one real expression or two concrete words that encode one. Reading
a half as a word, or a pair whose halves no longer match, is rejected; conversions keep the
exact real. F64 arithmetic, comparisons and conversions share one source reader and modifiers.
Packed moves select one word from each source and reuse the 64-bit move execution,
preserving concrete words and symbolic expressions unchanged. An inline constant must use the
low-word selector, because the high word of its 64-bit source is not established.
Comparison masks in VCC or SGPR pairs retain per-lane predicates for selects;
scalar instructions reject symbolic masks (`SymbolicSgpr`).
Negated f32 comparisons use the opposite ordered comparison because NaN is excluded.
Kernel tests in `tests/kernels.rs` run each assembly fixture
`tests/fixtures/<name>.s` through `analyze` (`tests/common::check_run`) and compare
its symbolic outputs with `tests/fixtures/<name>.out` (`VOLTA_BLESS=1` rewrites it).
The `scalar_ops` fixture checks signed arithmetic, 64-bit comparisons and uniform loop branches.
The `vector_int_ops` fixture checks multiplication, bit counts, 64-bit and packed moves,
and signed 64-bit comparisons against a literal bound. `compare64_ops` checks every 64-bit integer comparison
in both encodings, and `scalar_alu_ops` the scalar ALU, comparison and branch families.
The `packed_float_ops` fixture checks paired arithmetic, selectors, negation and destination
overlap against independently derived expressions.
The `f64_ops` fixture checks f64 arithmetic, modifiers, constants, conversions, comparisons and
moves.
Rejection fixtures assert the specific lowering or execution error instead of
comparing outputs.
`tests/lean_tests.rs` writes the sigmoid fixture's outputs against
`tests/fixtures/sigmoid.spec` (dev-dependency `volta_spec`) as the Lean challenge
`target/lean/sigmoid.lean` (`just extract-lean`): within `1/1000`, since the
kernel's large-input branch rescales by f32(e^-64), and over the reals the exact equality
is false there.
Do not add unit tests or `tests.rs` modules: cover execution behavior
through compiled fixtures in `tests/kernels.rs`.
See the crate README for ISA references, test commands, and fixture regeneration,
including the pinned CK Tile forward-attention instance in `ck_fmha.hip`.

## Crate: volta_trainium_analysis

**Path**: `crates/volta_trainium_analysis/`

AWS Trainium kernel analysis. Its input is an NKI kernel (a `@nki.jit` Python
function over `nki.language`/`nki.isa`); the stages mirror the other analyses:
parsing (`frontend`, public), lowering (`lower`, `ir`) and symbolic execution
(`eval`).

Lowering accepts ten `nki.isa` instructions - `dma_copy`, `tensor_copy`,
`tensor_tensor`, `tensor_scalar`, `activation`, `activation_reduce`,
`tensor_reduce`, `reciprocal`, `nc_matmul` and `nc_transpose` - and resolves
their `nki.language` operands by searching `ArithOp::ALL` (`nl.add`,
`nl.subtract`, `nl.multiply`, `nl.maximum`) and `ActivationFunc::ALL`
(`nl.sigmoid`, `nl.relu`, `nl.square`, `nl.rsqrt`, `nl.exp`) for a variant whose
`name()` matches, so a new function reaches lowering by joining that array and
needs no arm of its own; any other member is a lowering error. Binary ops take
NKI's operand order (`data1 op data2`, `data op operand`). `tensor_reduce` is
`LoweredInstr::Reduce`, a per-partition fold into `dst[p, 0]` seeded with the
first element (shared with `activation_reduce` as `Interpreter::fold`); its
`axis` (an `ast::Operand::Int` or `Ints`) must be the free axis, `1` or `(1,)`.
`reciprocal` lowers to an `Activation` of `ActivationFunc::Reciprocal`, which
is outside `ALL` so `activation(op=nl.reciprocal)` stays an error.

A kernel's outputs are the arguments it writes and the tensor it returns: a
final `return t` of an HBM tensor it allocates with `nl.ndarray(...,
buffer=nl.shared_hbm)` (any rank), its output array named `t`. Returning an
argument or a tile is a lowering error. `ir::Initial` records what a tensor's
unwritten elements hold: an argument's are input symbols, while a tile's or an
allocated HBM tensor's are uninitialized, so reading one is `UninitializedRead`.

A `tensor_scalar` operand is a float literal or a `[partitions, 1]` tile whose
single free element broadcasts across the destination's free axis; its second
`(op, operand)` pair is optional and both keywords must appear together.
`activation_reduce` folds `reduce_op` over each partition of its activated
result into `reduce_res[p, 0]`, seeded with the partition's first element rather
than an identity, so a non-additive `reduce_op` is correct too. A float literal
is an `ast::Scalar`, a newtype whose constructor rejects non-finite values, so
it is `Eq` and converts infallibly - through `Real::from_f64` and not an exact
rational, since only f64-round-tripping reals print as decimals.

A kernel is parsed for one call: `parse_kernel(source, name, shapes)` takes each
parameter's shape, as `@nki.jit` specializes a kernel per call (a missing,
unknown, repeated or empty one is `ParseError::ParamShape`), and lowering takes
parameter shapes from the parsed `ast::Param`s. The parser runs the kernel's
Python as NKI's tracer does: a `Trace` (every tensor declared and its extents,
list storage, the statements emitted, per-helper call counts) and a `Frame` per
call (its module, locals, the names it assigns, its tile prefix). Names bind and
rebind as in Python, to tensors, integers, tuples and lists (`Value::List` is an
index into the trace's storage, so lists are shared); a name a function assigns
is local throughout it; only a tensor's name must be unique. `d, n = q.shape`,
`+`/`*`/`//`, `nl.tile_size.{pmax, gemm_stationary_fmax, gemm_moving_fmax}`,
`list`/`tuple` and item reads and writes evaluate there, `t.shape` is a tuple, and
an `assert` (a chain of `==`/`!=`/`<`/`<=`/`>`/`>=`, tuples by `==`/`!=` only) is
checked and leaves no statement; a false one is a parse error.
`asserted_shapes(source, name)` reads a kernel's literal `assert p.shape ==
(...)`s as its shapes, for `volta_pipeline`'s NKI frontend, which has no caller.

Modules are read whole but functions lazily: the lexer tokenizes all of Python
(strings, every bracket, `\` continuations), making what the subset lacks an
`Unsupported` token, and `python::parse` keeps each `def` as a `FunctionSource` of
tokens, parsed only when reached, so the samples' file parses although v10's
classes use far more Python. A module's globals are imports, `from` imports,
functions and classes (never read; using one is an error).
`parse_kernel_with_modules(source, modules, name, shapes)` takes the imported
modules' sources by name. A helper call (a statement, an assignment's value or a
`return`'s, at most 32 deep) runs the helper's body in a new frame, with defaults,
keyword arguments and a final `return`'s value; its tiles take the prefix
`name[call].` (`softmax_isa[0].row_max`), and its errors are `ParseError::InCall`,
lines in the helper's module.

A `for` over `nl.affine_range(count)` is unrolled at resolution rather than
lowered: the interpreter has no program counter, and the integer-expression
machinery is `parse.rs`'s. It binds the loop variable to each index, folds the
body's arithmetic and emits the body once per index; the tiles an iteration
declares take its index as a suffix (`x` becomes `x.0`, a name Python cannot
write), so each iteration owns its own, while other names rebind as in Python (the
loop variable keeps its last value). The count is any compile-time integer; a
`for` over a tuple or list unrolls the same way.

A subscript is a rectangular region, one slice per dimension, and only slices:
an integer index would drop its dimension. `lower/` resolves each bound against
the tensor's shape - an omitted bound is that edge - keeping shapes its own
concern. `dma_copy` and `tensor_copy` therefore take `TensorRegion` operands; a
whole tensor is a zero `start` with the tensor's own shape, which `.ir` renders
as the bare name, so only a true sub-rectangle prints bounds.

`tests/fixtures/add.py` adds two 16 x 16 HBM tensors through SBUF tiles
(`dma_copy` in, `tensor_tensor` add, `dma_copy` out).
`tests/fixtures/gemm_relu.py` computes `relu(a_t.T @ b)`, its `activation`
reading the `nc_matmul`'s PSUM tile directly. `tests/fixtures/rms_norm.py`
normalizes each partition of a 4 x 8 tensor by `rsqrt(mean(x^2) + eps)` through
`activation_reduce` and two `tensor_scalar`s, the second broadcasting a
`[4, 1]` tile. `tests/fixtures/tiled_copy.py` copies an 8 x 4 tensor
through SBUF one `(4, 4)` tile of rows at a time, over an unrolled
`nl.affine_range(2)`. `tests/fixtures/returned_output.py` multiplies two 2 x 4
tensors into a `kernel_out` it allocates and returns.
`tests/fixtures/call_shapes.py` opens like the attention kernels (shape
unpacking, an alias, chained and `<=`/`>=` asserts, `nl.tile_size.pmax`) and adds
2 x 4 tensors one `(rows, cols // 2)` tile at a time; `tests/kernels.rs` passes
each fixture's call shapes. `tests/fixtures/softmax.py` is `softmax_isa`'s body
inline over a 2 x 3 tile, checked against `softmax.spec`. `tests/fixtures/matmul.spec` and `gemm_relu.spec` state those
kernels' math over their own array names (`a_t` being A transposed);
`volta_pipeline`'s `trainium_equivalence_tests.rs` checks the kernels against them,
and `softmax` against the softmax of `-x` (a reversed `subtract`) as a negative test.
`tests/fixtures/attention.spec` is the NKI attention samples' reference, their
`numpy_attention` in their layout (`q`, `k`, `v` as `[D, N]`, `kernel_out` as `[N, D]`).
`tests/fixtures/nki_samples/` vendors the samples' `attention_kernels.py` and
`attention_kernel_utils.py` unmodified (nki-samples `ef43bf3`, MIT-0);
`attn_fwd_v2.ast`/`.ir` snapshot v2 at 128 x 128 (`common::check_lowering`, no
`.out`), and `trainium_equivalence_tests.rs` proves v2 equal to `attention.spec`
on its first output row (all 16,384 outputs in an ignored test) and refutes it
against attention with `q` and `k` swapped. `tests/fixtures/helper_call.py` calls
`helpers.py`'s `row_sums` twice (`common::check_importing`); both modules hold
unreached code (a class, `if`, f-strings) that is never parsed.

## Crate: volta_graph_check

**Path**: `crates/volta_graph_check/`

The seven checks of the Volta v2 design's data-race freedom check (§1.3 of the
design document), then three beyond it (allocation order and allocation permit,
PTX ISA rules, and mbarrier release order), one
module each, each callable on an `EventGraph` in
isolation with explicitly passed certificates, each with its algorithm and
contract (PASS/FAIL/UNKNOWN meaning) in its module docs. Every check returns
`PropertyResult<E, V> = Pass(evidence) | Fail(witnesses) | Unknown(unresolved)`;
none turns an unsupported case into `Pass`. Depends only on `volta_graph`.

| #  | `Property`             | Algorithm   | Module                                |
|----|------------------------|-------------|---------------------------------------|
| 1  | `NamedBarrierEpoch`    | 1           | `barrier_epoch.rs`                    |
| 2  | `MbarrierEpoch`        | 1           | `barrier_epoch.rs`                    |
| 3  | `MbarrierOrdering`     | 2           | `mbarrier_ordering.rs`                |
| 4  | `MemoryConflict`       | 3           | `memory_conflict.rs`                  |
| 5  | `ProxyOrder`           | 4           | `proxy_order.rs`                      |
| 6  | `TensorOrder`          | 5 (+ 6)     | `tensor_order.rs`, `sync_search.rs`   |
| 7  | `ResourceLifetime`     | 7           | `resource_lifetime.rs`                |
| 8  | `AllocationOrder`      | ISA rule    | `allocation_order.rs`                 |
| 9  | `AllocationPermit`     | ISA rule    | `allocation_permit.rs`                |
| 10 | `MbarrierReleaseOrder` | phase chain | `mbarrier_release_order.rs`           |

- `relation.rs` - the typed edges `E = E_PO ∪ E_causal ∪ E_pipeline ∪ E_sync`
  and their projections, never used untyped: `IndependentGraph` (`G0`: program
  order, causal, every thread join except an `ExecutionOnly` collective's, no
  mbarrier completion join) and
  `ValidatedGraph` (`G_HB` = Algorithm 5's `D`: `G0` plus the mbarrier
  completion joins), built only from both barrier-epoch certificates and the mbarrier ordering certificate
  (`assuming_epochs` for isolated tests). `G0` is execution order, `G_HB`
  memory order: in `G_HB` an async arrive-on (`ArrivalOrdering::AsyncTracked`:
  `tcgen05.commit`, `cp.async.mbarrier.arrive`) joins nothing and an async
  completion carries only its op's effects, not what preceded the issue (the
  PTX ISA orders them only with their own instruction's memory operations);
  nor does an exited thread join (Sync' counts it as arrived for firing only:
  a barrier orders only its participating threads' accesses).
  Closure queries are a vector-clock sweep in trace order (an async effect
  reaches what an observer of its completion reaches); `successors()` gives
  `D` explicitly for Algorithm 6, with no edge into a completion.
- `pipeline.rs` - `E_pipeline` (graph-construction step 5), the PTX ISA 9.4
  implicitly pipelined pairs (9.7.18.6.2): same-thread `tcgen05.mma` chains on
  one accumulator (edges between accumulator effects only), and same-warp
  `tcgen05.st`->`ld`, `st`->`st`, `ld`->`st` pairs whose earlier op's
  `tcgen05.wait` releases the later op's issuer before its issue. Edges keep
  rule, roles and covered cells. No projection contains it.
- `domain.rs` - the memory domains: `M` (ordinary global/shared effects, async
  ones and shared-memory `tcgen05` operands included; Algorithms 2-3) and `A`
  (Tensor Memory effects of `tcgen05` ops; Algorithms 5 and 7).
- `barrier_epoch.rs` - Weft's separation criterion over `G0`: every
  synchronization `s` of generation `k` reaches (or is) the program
  predecessor of every contribution `v` of `k + 1` (an mbarrier's pre-init
  generation is its `k = -1`, and its `mbarrier.init` one of that generation's
  synchronizations; an async copy's `complete_tx` is a contribution that
  begins at the copy's issue, since it can land any time after it, and is no
  synchronization); an mbarrier wait of `k + 1` instead needs one
  release of `k` to reach its predecessor (phase `k` complete when it
  starts), the separation rule applying only when `k` released no thread;
  returns the first VIOLATION(s, v); a pass issues `NamedBarrierEpochs` /
  `MbarrierEpochs`.
- `mbarrier_ordering.rs` - the design's sufficient mbarrier ordering check over
  `G0`: per phase the updates `(d, t)` (`arrive(c)` = `(c, 0)`, `expect_tx(q)` =
  `(0, q)`, `arrive.expect_tx(q)` = `(1, q)`, `complete_tx(q)` and a tracked
  completion = `(0, -q)`); a completed phase must balance (`D = n_k`, `T = 0`,
  else `Fail` with a `PhaseBalanceViolation`), an open phase is certified only
  while `D < n_k`, and every announcement (`t > 0`) needs an arrival of its phase
  it reaches in `G0+` or is combined with; an unprotected announcement is
  `Unknown` (the phase can complete before it is announced), as the design
  leaves it; a pass issues `MbarrierOrdering`.
- `memory_conflict.rs` - every overlapping pair of `M` with a write ordered in
  `G_HB`; `Fail` lists all of `B` (a per-byte dominance forest finds each
  unordered pair once, at its lowest byte); no benign equal-store exception;
  atomics are outside the contract (`Unknown`); a pass issues
  `MemoryConflictFree`.
- `proxy_order.rs` - every ordered cross-proxy pair needs a covering fence:
  an explicit `fence.proxy.async` on either side's thread, or the implicit fence
  of a validated completion observation (async -> generic). A generic write
  before a TMA's tensor-map-proxy read of its map needs the PTX ISA's pair: a
  release on the writer's thread after the write, ordered in `G_HB` before an
  acquire of that map on the copy's thread before the copy. An uncovered pair
  is a `Fail` (a cross-proxy race, typed `ProxyOrderViolation`, naming the
  `MissingFence`), not the design's `Unknown`.
- `tensor_order.rs` / `sync_search.rs` - conflicting TMEM pairs of distinct ops,
  oriented by issue: pipelined, or a `D` path to the target's issue through a
  source-thread `tcgen05.fence::before_thread_sync` (or tracking
  `tcgen05.commit`) then a target-thread `::after_thread_sync`. The path starts
  at the source's issue only for a pair the ISA pipelines within one warp
  (`pipeline::pipelinable`); any other pair's starts at the source's completion,
  so it passes a release observing it (an MMA's commit is its before fence).
- `resource_lifetime.rs` - TMEM allocations: each use covered by its
  allocation, each allocation freed exactly once, then phase 1 (use reaches
  its dealloc) and phase 2 (alloc reaches the use).
- `allocation_order.rs` - the PTX ISA's `tcgen05.alloc` rule ("the number of
  columns allocated should not increase between any two allocations in the
  execution order"): the allocations must be totally ordered in `G_HB` (each
  reaches the next in trace order; an unordered pair fails even at equal sizes,
  since the columns the trace assigns hold for its order only), and their column
  counts non-increasing along that order. The interpreter's allocator enforces
  the same bound on the one order it executes.
- `allocation_permit.rs` - the PTX ISA's `tcgen05.relinquish_alloc_permit` rule
  (no CTA may `tcgen05.alloc` after any of its warps relinquished the permit):
  every allocation must reach every relinquish (`TmemRelinquish`, recorded once
  per warp on its leader) in `G_HB`. The interpreter rejects an allocation after
  a relinquish on the one order it executes (`Tcgen05AllocAfterRelinquish`).
- `mbarrier_release_order.rs` - each mbarrier lifetime's waits observe its
  phases one after another, over `G0`: the phases that released a thread must
  run 0, 1, 2, ... (parities 0, 1, 0, 1, ...), optionally starting one earlier
  at the pre-init phase (the CUTLASS producer's first parity-1 wait on a fresh
  `empty` barrier), and every release of a phase must reach every release of
  the next (one phase's waiters need no order among themselves). It gives the epoch check's completion rule a witness for every
  wait: a phase that released no thread leaves it only the separation rule,
  which an async copy's `complete_tx` escapes. No prerequisites, no
  certificate.
- `suite.rs` - `check_graph(graph) -> GraphReport` runs them in
  `Property::ALL` order (a topological order of `Property::prerequisites`; a
  check whose prerequisites failed is `Unknown`); `GraphReport::conclusion()`:
  `Verified` (a completed trace and all ten checks passing; nothing else is
  consulted) / `Rejected { failed, deadlock }` / `Unknown`. A stuck trace is
  the trace generator's deadlock diagnostic, an aborted one is inconclusive.

## Crate: volta_pipeline

**Path**: `crates/volta_pipeline/`

The integration point: `verify_kernel(module, kernel, config)` (analysis stage
+ the graph branch's ten checks),
`check_equivalence` (the equivalence branch over symbolic outputs only; a
claimed difference is a refutation only once the numeric oracle separates it,
else `Unproven`), and `decide(equivalence, kernels) -> Decision { verdict,
evidence, assumptions }`: ACCEPT needs a complete (unsampled) equivalence proof
and every kernel `Verified`; any refutation, failed check or deadlock is REJECT;
anything else is UNKNOWN. Tests:
`aggregation_tests.rs` (real kernels through both branches),
`architecture_tests.rs` (the stage/branch boundaries),
`amd_equivalence_tests.rs` (compiled AMD matmul, MFMA matmul, CK GEMM, CK attention,
and softmax against their formulas, accounting for CK's column-major B and softmax at
several workgroup sizes; negative tests swap matmul inputs or attention's query and key,
or change the softmax row width), and `trainium_equivalence_tests.rs` (the NKI `matmul`, 
`gemm_relu` and `softmax` fixtures against the `.spec` files beside them, with `gemm_relu` 
against the unclamped product and `softmax` against the softmax of `-x` as negative tests,
and the NKI samples' `attn_fwd_v2` against `attention.spec`, on its first row by default,
with `q` and `k` swapped as a negative test).
These check functional equivalence only. `just amd` and `just trainium` run them 
alongside the analysis crate's snapshot tests.

### End-to-end tests (`tests/`)

Every PTX-driven test of the workspace. Besides the two above, each suite runs
PTX kernels from `tests/ptx/` through `verify_kernel` (`common::check` /
`common::run_kernel`):

- `accepted_tests.rs` - race-free kernels: the graph check must conclude
  `Verified`, then the rendered
  symbolic outputs must match the kernel's `.out` file exactly
  (`VOLTA_BLESS=1` rewrites them).
- one suite per check whose witnesses PTX kernels exercise, each asserting on
  that check's typed witness only: `mbarrier_epoch_tests.rs` (Algorithm 1 over
  mbarrier phases: the unseparated synchronization and operation),
  `mbarrier_ordering_tests.rs` (Algorithm 2: the announcement no arrival of its
  phase is ordered after, as the `Unknown`'s events, and the accepted twin),
  `memory_conflict_tests.rs` (Algorithm 3:
  conflict kind, byte, each side's thread, access mode and async op),
  `proxy_order_tests.rs` (Algorithm 4: the uncovered generic write and
  tensor-map read, and the missing fence),
  `tensor_order_tests.rs` (Algorithm 5: the Tensor Memory cell and sides),
  `resource_lifetime_tests.rs` (Algorithm 7: the use freed while unordered, or
  the allocation never freed), `allocation_order_tests.rs` (the unordered pair
  of allocations, by thread), `allocation_permit_tests.rs` (the allocation not
  ordered before a relinquish, and the relinquish, by thread),
  `mbarrier_release_order_tests.rs` (the first release after phase 0: its
  phase and thread).
- `rejected_tests.rs` - execution errors (`EvalError`, lowering errors) and
  deadlocks (the trace generator's diagnostic, `GraphReport::deadlock`).
- `graph_tests.rs` - the event graph the analysis stage records, no checker.
- `negative_equivalence_tests.rs` - kernel pairs differing in one semantic
  detail, each `Verified`, must not be proved equivalent.
- `false_positive_tests.rs` - kernels Volta still verifies although they race or
  are undefined (`tests/ptx/false_positive/`); each fails until Volta stops
  concluding `Verified` on it.
- `soundness_tests.rs` - soundness regressions; the unknown-directive case
  requires a located `InvalidDirective` and verifies empty/known-pragma controls.
  The return case requires a zero-operand arity error for `ret 123;` and
  `ret.uni 123;`, and verifies their operand-free forms.
  The exit cases verify plain `exit;` and require an unexpected-modifier error for
  `exit.not_a_modifier;` and a zero-operand arity error for `exit 123;`.
  The `brkpt` cases check the same errors and verify plain `brkpt;`.
  The `trap` cases require validation errors, while plain `trap;` reaches the
  expected `TrapReached` runtime abort.
  The `mbarrier` count cases require an `init` count of 0 or `2^20` and an
  `arrive` count of 0 to be rejected before any graph verdict, and the
  trailing-operand case a lowering error for a four-operand `mbarrier.arrive`.

Every suite reaches the analysis through `common` (`verify`, `analyze_only`,
`check`, `run_kernel`), whose `parse` returns a `Ptx` (module + source text +
test file name). With `VOLTA_VIZ_DIR` set, each of them records the run into
that `volta_viz` store, keyed `<suite>/<test>[~<n>]` (libtest names each test's
thread after it; `n` counts the test's runs).

## Crate: volta_equivalence

**Path**: `crates/volta_equivalence/`

Everything after VC extraction: takes two `SymbolicOutputs` and decides them
element by element. Depends only on `volta_expr`, so it checks expressions
from any producer - in memory, from a `.vcdump`, or from `.vexpr` text.

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

## Crate: volta_viz

**Path**: `crates/volta_viz/`

The event-graph viewer; depends only on `volta_graph`, `volta_graph_check`
(findings, pipeline edges) and `volta_expr` (stored values). `write_run(dir,
&Run)` stores one run (`Outcome::Executed { graph, arena, report }` or
`NotStarted { cause, error }`, `cause` being `Unsupported` when lowering failed)
as a `volta-viz 1` JSON document plus a `.meta.json` summary. A run's status is
race-free, race-condition (a memory-conflict, proxy-order or tensor-order
failure), check-failed, deadlock, unsupported, unknown, error, or unchecked (no
graph check run).
`write_page(dir, out)` inlines `viewer/{page.html,style.css,app.js}` and every
stored run into one self-contained HTML page. Documents are compact
(events are rows of indices into interned string and detail-pair tables, each
async op is `[issue, completion, effects...]`) and embedded as inert
`<script type="application/json">` blocks the page parses only when a run is
opened. The page lays each run out as a space-time diagram: a lane per thread,
per issuing thread's async ops and per sync object, rows by longest-path
layering over program order and the typed edges, the checks' witnesses and a
stuck trace's blocked threads ringed, and the PTX source behind every pc.
Around the diagram: an overview of every run (statuses, suites) while none is
open, a step ruler, an overview map while zoomed in, a legend that highlights
or steps through one event kind, and keyboard navigation (`?` lists the keys).

## Crate: volta_cli

**Path**: `crates/volta_cli/`

Commands:

- `volta parse <file>` - Check syntax
- `volta analyze <file> -k <kernel> -b 32,4 -g 1,2 --array name:base:width:len:kind --param ptr:name ...` - Run the analysis stage and the graph branch: print output expressions (+ a per-instruction-kind profile; `--no-profile` to skip), every graph check's verdict (with its algorithm), the trace's deadlock and the first failure; `GRAPH VERIFICATION: VERIFIED|REJECTED|UNKNOWN` (exit 0/1/2); `--emit-exprs FILE` writes the outputs as `.vexpr` text, `--dump-graph FILE` the event graph; `--config FILE` (any command taking launch flags) replaces the launch flags with a JSON launch file, whose `"kernel"` is the default `--kernel`
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
- `volta viz <store> -o <page>.html` - the `volta_viz` page over a run store.

Every run writes a `volta_common::run_log` file (`--log-dir`/
`--no-log-file`).

## Data Flow

```
PTX Source
    │
    ▼
Lexer (frontend/lex.rs) ──► Tokenizes source
    │
    ▼
Parser (frontend/parse.rs) ──► Builds AST
    │
    ▼
Instruction Parser (frontend/instr_parse.rs) ──► Strongly-typed ParsedInstruction
    │
    ▼
Lowering (lower/) ──► LoweredProgram (resolved RegIds, InstrIds)
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
  per-element VC checking        the ten checks (Algorithms 1-7,
  (+ numeric.rs oracle)          allocation order and permit,
                                 mbarrier release order), in order
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

The paper's χ-context detector (Section 4.2) used to run inside the interpreter. It was removed: the interpreter records a typed event graph of its one candidate schedule, and `volta_graph_check` verifies it downstream with the seven checks of the Volta v2 design and the allocation-order, allocation-permit and mbarrier release-order checks (memory conflicts through the typed `G_HB` projection, never untyped reachability). A kernel is VERIFIED when its trace completed and all ten checks pass on it; no further schedule argument is consulted.

### 4. Round-Robin Scheduling

Simple, deterministic interleaving: the candidate execution. The ten checks judge the event graph of this one execution (see 3).

### 5. Strongly-Typed IDs

Newtype pattern for IDs (`RegId`, `InstrId`, `ThreadId`) prevents mixing at compile time. Uses `IdVec<K, V>` for type-safe indexed collections.

### 6. Two-Phase Instruction Parsing

1. Lexer/Parser → generic `Instruction { op: String, operands }`
2. Instruction Parser → strongly-typed `ParsedInstruction` variants

Enables robust modifier validation and better error messages.

### 7. Separate Memory Spaces

Global, shared, local, param memories are separate `Memory` instances, matching PTX memory model.

## Adding a New Instruction

1. **Frontend**: Add `InstrKind` variant in `frontend/instr.rs`, add to trie
2. **Instruction Parsing**: Add `ParsedInstruction` variant, parser function
   in `frontend/instr_parse.rs` (use `expect_operands` for exact-arity operand lists)
3. **Lowering**: Add `LoweredInstr` variant, a `lower_*` function in its
   family's `lower/` file, and its arm in `lower/mod.rs`'s dispatch
4. **Evaluation**: Add evaluation case in `eval/interp.rs`

## Tooling

```sh
just check # run linters
just test  # run tests
just viz   # record every volta_pipeline test run, write target/volta-viz/volta-graphs.html
just loc   # count the lines of code, per crate and per language
just extract-lean # write the AMD sigmoid Lean challenge, target/lean/sigmoid.lean
```
