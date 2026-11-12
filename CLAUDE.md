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
├── frontend/         # One analysis per accelerator
│   ├── volta_ptx_analysis/ # PTX frontend (lexer, parser) and abstract interpreter (PTX -> expressions + event graph)
│   ├── volta_amd_analysis/ # AMD kernel analysis
│   └── volta_trainium_analysis/ # Trainium (NKI) kernel analysis
├── backend/          # The two solvers
│   ├── volta_equivalence/ # Equivalence checking of expressions (decision procedure, VC dumps)
│   └── volta_lean/   # Lean proofs of extracted obligations (acceptance check, agent tools over MCP, Claude Code prover)
├── volta_pipeline/   # Analysis -> {equivalence, graph} branches -> ACCEPT/REJECT/UNKNOWN; every end-to-end PTX test
├── volta_viz/        # Event-graph viewer (run store -> one self-contained HTML page)
└── volta_cli/        # Command-line interface
```

### Dependency Graph

Direct dependencies of each crate:

```
volta_cli          → volta_pipeline, volta_equivalence, volta_ptx_analysis, volta_graph_check, volta_graph, volta_viz, volta_spec, volta_expr, volta_common
volta_viz          → volta_graph_check, volta_graph, volta_expr
volta_lean         → volta_common
volta_pipeline     → volta_ptx_analysis, volta_amd_analysis, volta_trainium_analysis, volta_equivalence, volta_graph_check, volta_graph, volta_spec, volta_expr, volta_common (+ dev: volta_viz)
volta_equivalence  → volta_expr, volta_common (+ dev: volta_spec)
volta_spec         → volta_expr, volta_common
volta_ptx_analysis → volta_graph, volta_expr, volta_common
volta_amd_analysis → volta_graph, volta_expr
volta_trainium_analysis → volta_graph, volta_expr
volta_graph_check  → volta_graph, volta_common
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
the stage. Tests follow the
split: `volta_equivalence`'s are spec-to-spec (`tests/spec_equivalence_tests.rs`
over the `.spec` files in `tests/specs/`, and `tests/spec_identity_tests.rs`:
one test per `tests/specs/equivalent/<case>_{lhs,rhs}.spec` identity;
dev-dependency `volta_spec` only), while every kernel-driven test is end-to-end in
`volta_pipeline/tests/`, one test target per ISA (`ptx_tests`, `amd_tests`,
`trainium_tests`: `tests/<isa>/main.rs`, its suites as modules beside its kernels, each
kernel in its outcome folder: `success/`, `check_failure/` (a graph check rejects it),
`execution_error/` (lowering or execution rejects it, or it deadlocks), and PTX's
`negative_equivalence/` and `soundness/`): `common::check` runs
`volta_pipeline::verify_kernel`, race and deadlock tests assert on the failed
property's typed witness, and every kernel run expected to complete must
conclude `Verified` (not merely unrejected) before its symbolic outputs are
compared with the kernel's `.out` file
(`VOLTA_BLESS=1` rewrites them). The analysis crates keep only their inline unit
tests of internals.

## Crate: volta_common

**Path**: `crates/volta_common/`

- `span::Span` - Source location (`start..end` byte offsets, built with `Span::new`)
- `FileCache` - Caches file content to make sure we always use a consistent version of each file
- `Locate<E>` - Error wrapper with optional location info (span + file path)
- `report_error` - Produces an error message from a title, message, span, and file content. Extracts out and includes the code snippet at the given span in the given file content
- `report::position` - A byte offset's 1-based line, column (in characters) and line text: `report_error`'s `path:line:column` header and `volta_py`'s error messages
- `logging` - The `debug`/`info`/`trace`/`warn` macros every crate logs through: `log`'s own under the `logging` feature, else a stand-in that compiles its arguments in a dead branch, so log-only values still count as used
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
in one call (every element; `ExtractError` names the failed stage). A `sum`/`max`
range is `start..end` over `IndexExpr`s of dims and enclosing variables
(`sum(s in 0..t + 1, ...)`, a scan's causal sum); the memo keys each reduction on the
variables its body and range read, an empty range is the identity, and a non-empty
one below 0 is `SpecError::NegativeRangeStart`. `array NAME[...] index;` declares an
index array (`ast::Elements::Indices`): integers the caller gives, row-major
(`instantiate_with_indices`, `extract_expressions_from_spec_with_indices`;
`SpecEnv::indices`), read only inside subscripts (`IndexExpr::Read`, a gather's
`data[p, index[0, i]]`); one read as a value is `SpecError::IndexArrayAsValue`, a
subscript reading another array `NotAnIndexArray`.

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
  recorded), mode, `OrderingKind` (`Ordinary`; NKI also records `Reduction(op)`, a
  read-modify-write that commutes with reductions of the same `ReductionOp`, built from
  `Effect::Reduce`), proxy, canonical
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
  `Assumption`s, per-instruction kind and source span. `SingleWorkgroupAnalyzed` records
  the selected AMD workgroup's coordinates without claiming cross-workgroup verification.
  `ThreadUnit` says what a graph thread is: a CTA thread, an AMD wave, or one NKI
  instruction (`Instruction`, `block_dim` the instruction count), ordered after another
  by its `Dependency` object's one generation (`GraphBuilder::signal`, an `Arrival`
  release completing it at once; each later instruction `resume`s from it), under the
  ordering policy's `Assumption`s (`NkiReadAfterWriteOrder` and `NkiWriteAfterReadOrder`
  always; `NkiWriteAfterWriteOrder`, `NkiHazardsByPlacedAddress` and
  `NkiNoReorderInProgramOrder` as the policy adds them).
- `EventGraph::validate` checks the representation invariants (every typed
  edge runs forward in trace order, so the relation is acyclic);
  `EventGraph::dump` is the deterministic `volta-graph 1` text form
  (`volta analyze --dump-graph FILE`).

## Crate: volta_ptx_analysis

**Path**: `crates/frontend/volta_ptx_analysis/`

Every module but `frontend` is private: `lib.rs` re-exports the whole API (`analyze`,
`AnalysisResult`, `AnalysisParts`, `AnalysisError`, `write_op_counts`, the
`AnalysisConfig` types, `EvalError`, `ClcMisuse`, `OutputsUnavailable`,
`Stats`, `ThreadId`, `LowerError`), so rustc flags any code it does not
reach. Other crates import from the root (`volta_ptx_analysis::AnalysisConfig`).

### Frontend (`frontend/`)

The one public module (`volta_ptx_analysis::frontend::{parse, ast, ...}`): PTX
text to a typed AST. It imports nothing else of the crate, nor `volta_expr`
or `volta_graph`.

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

### Logging (`volta_common::logging`)

Gated by the `logging` feature (`volta_ptx_analysis`, `volta_equivalence`,
`volta_graph_check` and `volta_pipeline`, each turning on `volta_common/logging`,
all passed through by `volta_cli`); without it the macros log nothing. Wired at the decision points:
barrier/warp-group fires (trace), deadlock (warn), launch config and
completion stats (info) in `volta_ptx_analysis`; VC session recycles (info) and
fraction-equality escalation (debug) in `volta_equivalence`; the stages at
info, tagged `[analysis]`/`[graph]`/`[equivalence]`: graph extraction and
the equivalence branch in `volta_pipeline`, each of the ten checks (start,
verdict, duration) in `check_graph`. `cargo run -p volta_cli
--features logging -- --log-level info analyze ...` narrates a run.

## Crate: volta_amd_analysis

**Path**: `crates/frontend/volta_amd_analysis/`

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
The internal `initialize_waves` maps a supported descriptor and `WorkgroupLaunch` inputs
to initial registers, including the selected workgroup's concrete X/Y/Z IDs. Grid dimensions
must be nonzero and contain that ID. It accepts full waves in 1D, 2D, and 3D workgroups, matching
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
Unsupported instructions return `EvalError`. `WaveState::exec` is the wave's concrete mask of
active lanes, the same in every workgroup. A 64-bit scalar move or operation may write it,
as may the `saveexec` and `wrexec` operations (`ExecOp64`, sharing `scalar_op64`); `v_cmpx`
is rejected. Vector, memory and LDS instructions run in
the active lanes only, a comparison or carry mask has a clear bit for each inactive lane, and
a DS read's destinations complete only in the lanes that ran it.
Integer and bitwise operations require concrete words because
symbolic values are floats and do not represent bit patterns, so integer arithmetic and
sign-mask tricks on symbolic values are rejected; floating-point arithmetic and transfers,
including lane exchanges, remain supported. A select between two different constant words
under a symbolic condition is rejected (`AmbiguousSelect`).
Negated select sources use floating-point semantics, so they are not ambiguous.
F32 e64 comparisons, e64 selects, f32 FMA and three-source f32 operations accept absolute-value
and negation input modifiers on any source; these operate on mathematical expressions.
E64 comparisons write VCC or an SGPR pair.
Scalar and vector NOT require concrete words. Accumulator writes accept VGPRs, SGPRs and inline constants.
Packed f32 add, multiply and FMA share component selection and negation handling;
each register holds one real expression, and either selector reads the same inline constant.
An f64 register pair holds one real expression or two concrete words that encode one. Reading
a half as a word, or a pair whose halves no longer match, is rejected; conversions keep the
exact real. F64 arithmetic, comparisons and conversions share one source reader and modifiers.
F32 conversions read a concrete word as a signed or an unsigned integer, and truncate a concrete
float toward zero, clamping it to the i32 or u32 range.
Packed moves select one word from each source and reuse the 64-bit move execution,
preserving concrete words and symbolic expressions unchanged. An inline constant must use the
low-word selector, because the high word of its 64-bit source is not established.
Comparison masks in VCC or SGPR pairs retain per-lane predicates for selects;
scalar instructions reject symbolic masks (`SymbolicSgpr`).
Negated f32 comparisons use the opposite ordered comparison because NaN is excluded.
Kernel tests in `volta_pipeline/tests/amd/accepted_tests.rs` run each assembly fixture
`volta_pipeline/tests/amd/success/<name>.s` through `analyze` (`common::amd::check_run`)
and, once its graph concludes `Verified`, compare its symbolic outputs with `<name>.out`
beside it (`VOLTA_BLESS=1` rewrites it).
The `scalar_ops` fixture checks signed arithmetic, 64-bit comparisons and uniform loop branches.
The `vector_int_ops` fixture checks multiplication, bit counts, 64-bit and packed moves,
and signed 64-bit comparisons against a literal bound. `compare64_ops` checks every 64-bit integer comparison
in both encodings, and `scalar_alu_ops` the scalar ALU, comparison and branch families.
The `packed_float_ops` fixture checks paired arithmetic, selectors, negation and destination
overlap against independently derived expressions.
The `f64_ops` fixture checks f64 arithmetic, modifiers, constants, conversions, comparisons and
moves.
`convert_ops` checks the f32 conversions in both signednesses: words with the sign bit set,
truncation toward zero, and clamping at each bound of the result's range.
`exec_ops` checks each kind of instruction under a partial EXEC mask; its other kernels check a
load that stays pending in lanes another completion skips and rejection of a grid whose
workgroups differ in EXEC, and `amd/graph_tests.rs` counts its active lanes' LDS accesses.
`saveexec_ops` checks every `saveexec` and `wrexec` opcode and a compiler-masked branch.
Rejection tests (`amd/rejected_tests.rs`, over `amd/execution_error/` and the failing
kernels of mixed `success/` files) assert the specific lowering or execution error instead
of comparing outputs.
`volta_pipeline/tests/amd/lean_tests.rs` writes the sigmoid fixture's outputs against
`amd/success/sigmoid.spec` as the Lean challenge
`target/lean/sigmoid.lean` (`just extract-lean`): within `1/1000`, since the
kernel's large-input branch rescales by f32(e^-64), and over the reals the exact equality
is false there.
Do not add unit tests or `tests.rs` modules: cover execution behavior
through compiled fixtures in `amd/accepted_tests.rs` and `amd/rejected_tests.rs`.
See the crate README for ISA references, test commands, and fixture regeneration,
including the pinned CK Tile forward-attention instance in `ck_fmha.hip` and RMSNorm instance
in `ck_rmsnorm2d.hip`, and CK's fp32 average-pooling instance in `ck_avgpool2d.hip`.

## Crate: volta_trainium_analysis

**Path**: `crates/frontend/volta_trainium_analysis/`

AWS Trainium kernel analysis. Its input is an NKI kernel (a `@nki.jit` Python
function over `nki.language`/`nki.isa`); the stages mirror the other analyses:
parsing (`frontend`, public), lowering (`lower`, `ir`) and symbolic execution
(`eval`).

Lowering accepts fourteen `nki.isa` instructions - `dma_copy`, `tensor_copy`,
`memset` (`LoweredInstr::Memset`), `tensor_tensor`, `tensor_scalar`, `tensor_scalar_reduce`,
`activation`, `activation_reduce`, `tensor_reduce`, `tensor_tensor_scan`, `reciprocal`, `nc_matmul`,
`nc_transpose` and `dma_transpose` (`axes=(1, 0)` only, the same `Transpose`) - drops
an `engine=` naming `nisa.engine.vector`, `scalar`, `gpsimd` or `unknown` (or the older
`nisa.vector_engine`, `scalar_engine`, `gpsimd_engine`), and resolves
their `nki.language` operands by searching `ArithOp::ALL` (`nl.add`,
`nl.subtract`, `nl.multiply`, `nl.maximum`) and `ActivationFunc::ALL`
(`nl.sigmoid`, `nl.relu`, `nl.square`, `nl.rsqrt`, `nl.exp`) for a variant whose
`name()` matches, so a new function reaches lowering by joining that array and
needs no arm of its own; any other member is a lowering error. Binary ops take
NKI's operand order (`data1 op data2`, `data op operand`). `tensor_reduce` is
`LoweredInstr::Reduce`: its `axis` (an `ast::Operand::Int` or `Ints`) must be the
data region's trailing free axes (`1`, `(1,)`, `[3, 4]`), and each `dst` element, the
other dimensions, folds one run of consecutive elements of each partition's free
view, seeded with its first (shared with `ir::Reduction` as `Interpreter::fold`);
reducing every free axis leaves `dst[p, 0]`. `negate=True` (an `ast::Operand::Bool`)
negates the result (`ir::Sign`).
`reciprocal` lowers to an `Activation` of `ActivationFunc::Reciprocal`, which
is outside `ALL` so `activation(op=nl.reciprocal)` stays an error.
`tensor_tensor_scan` is `LoweredInstr::Scan`, the docs' recurrence along each partition
of matrix regions, `dst[p, i] = op1(op0(data0[p, i], dst[p, i - 1]), data1[p, i])` from
`initial` (a literal or a `[partitions, 1]` tile), `reverse0`/`reverse1` swapping an op's
operands (`ir::Order`).
`tensor_copy(dst, data.indirect(index, num_elem=count))` (`ast::Operand::Indirect`, only
as `tensor_copy`'s `src`) is `LoweredInstr::Gather`, tensor indirection: `dst[p, i] =
data[p, offset]` for `count` columns (default the index's size, at most 16 per index
column), `index` an SBUF matrix of `data`'s partitions, whole 16-partition groups, and
not on `gpsimd` (`StatementError::IndirectEngine`). The docs read offset `i` from
`index[i % 16, i // 16]`, the tutorial from the rows of each partition's group; a gather
is defined only where they agree (else `EvalError::IndirectReadings`), and an offset must
be a concrete integer below `data`'s free size (`EvalError::IndirectOffset`).

`nc_matmul`'s `accumulate=` is `ir::Accumulation`: `False` overwrites `dst`, `True` adds
to it (an unwritten element is an `UninitializedRead`), and `None`, the default,
overwrites an element's first write and adds to later ones.

`nl.ndarray(..., address=(partition, offset))` places an on-chip tile (`ast::Address`,
`Tensor::address`): its partitions from `partition`, its free elements row-major from byte
`offset` at their dtype's size (`float32` 4, `bfloat16`/`float16` 2; the dtype must be
known), within 128 partitions of `sbuf_fmax_bytes` (SBUF) or 16 KiB (PSUM, eight 2 KiB
banks). A kernel places all its on-chip tiles or none (`LowerError::MixedAllocation`).
Placed tiles may overlap (v10's `v_psum_t` and `qk_psum`): `eval/alias.rs` pairs the
overlapping tiles, a write through one clobbers the other's elements covering its bytes,
and reading a clobbered element is `EvalError::ClobberedRead`. This is program order; the
graph branch takes the compiler to order accesses through overlapping tiles by address
(`OrderingPolicy::BASELINE`'s `PlacedTiles::ByAddress`), which the docs do not state.

A kernel's outputs are the arguments it writes and the tensor it returns: a
final `return t` of an HBM tensor it allocates with `nl.ndarray(...,
buffer=nl.shared_hbm)` (any rank), its output array named `t`. Returning an
argument or a tile is a lowering error. `ir::Initial` records what a tensor's
unwritten elements hold: an argument's are input symbols, while a tile's or an
allocated HBM tensor's are uninitialized, so reading one is `UninitializedRead`;
`Initial::Integers` holds the integers a call gives an argument (`KernelCall::contents`,
`ast::Param::contents`), as PTX's `IndexInput` with chosen values: a gather's offsets.

A `tensor_scalar` operand is a float literal or a `[partitions, 1]` tile whose
single free element broadcasts across the destination's free axis; its second
`(op, operand)` pair is optional and both keywords must appear together.
`LoweredInstr::Activation` is `func(data * scale + bias)`, `scale` and `bias` optional
`ScalarOperand`s, with an optional `ir::Reduction`: each `reduce_res[p, 0]` the fold
of `reduce_op` over partition `p` of the result, seeded with its first element rather
than an identity, so a non-additive `reduce_op` is correct too. `activation` takes
one with `reduce_op`, `reduce_res` and `reduce_cmd=nisa.reduce_cmd.reset_reduce`
together (the other `reduce_cmd`s carry an accumulator across instructions and are
errors); `activation_reduce` is that instruction, as the NKI docs
define it, and `tensor_scalar_reduce` is a one-step `TensorScalar` with a
`Reduction`. A tile's `dtype` is not modelled: values are reals, so v7 to v8a's
`nl.bfloat16` scores are checked without their rounding. A float literal
is an `ast::Scalar`, a newtype whose constructor rejects non-finite values, so
it is `Eq` and converts infallibly - through `Real::from_f64` and not an exact
rational, since only f64-round-tripping reals print as decimals.

A kernel is parsed for one call: `parse_kernel(source, name, shapes)` takes each
parameter's shape, as `@nki.jit` specializes a kernel per call (a missing,
unknown, repeated or empty one is `ParseError::ParamShape`), and lowering takes
parameter shapes from the parsed `ast::Param`s. A `KernelCall`
(`parse_kernel_for_call`) also gives parameter dtypes by `nki.language` name, needed
only where a kernel compares or sizes one (v10's allocator), the values of the
parameters that are not tensors (`constants`, each a `Constant`; one without a value
or shape takes its default), and the `TileSizes`. `nisa` operands are by keyword, but
`POSITIONAL` lets `dma_copy`, `tensor_copy`, `nc_matmul` and `nc_transpose` take their
leading ones by position, in their docs' order. The parser
runs the kernel's Python as NKI's tracer does: a `Trace` (every tensor declared, its
extents and dtype, list and object storage, the classes instantiated, the
statements emitted, per-helper call counts) and a `Frame` per call (its module,
locals, the names it assigns, its tile prefix, the name its caller binds its value
to). Names bind and rebind as in Python, to tensors, signed integers, tuples, lists,
`None` and objects (`Value::List` and `Value::Object` index the trace's storage, so
both are shared); a name a function assigns is local throughout it; a tile name
declared again takes a version suffix (`x~1`), so every tensor's name is unique.
`d, n = q.shape`, `+`/`-`/`*`/`//`/`%`/`&`, unary `-`/`~` and `op=` (Python's
rounding), `/` (true division to an f64, of integers within 2^53 or floats), `nl.tile_size.{pmax, gemm_stationary_fmax, gemm_moving_fmax,
sbuf_fmax_bytes}` (`TileSizes::HARDWARE` by default; `sbuf_fmax_bytes`, a tile's
largest SBUF free size in bytes, is a Trn2 partition's 192 KiB, a value the docs do not state), `list`/`tuple`/`len`, item reads and writes
and tuple or list slices evaluate there, and `t.shape` is a tuple. Comparisons are
values (integers ordered and chained; tuples, bools, floats, `None`, objects by
identity and dtypes, `q.dtype` by the call's, by `==`/`!=`), as are `and`/`or`/`not`
over Python's truth of a bool, integer or `None`. An `assert` (its message unread)
is checked and leaves no statement (its message, any expression, skipped); a false one
is a parse error. An
`if`/`elif`/`else` runs its taken branch, a `return` (bare: `None`) may come
anywhere (`Flow`), and `with nl.no_reorder():` runs its body, the instructions
being in program order anyway.
`asserted_shapes(source, name)` reads a kernel's literal `assert p.shape ==
(...)`s as its shapes, for `volta_pipeline`'s NKI frontend, which has no caller.

Modules are read whole but functions lazily: the lexer tokenizes all of Python
(strings, every bracket, `\` continuations), making what the subset lacks an
`Unsupported` token, and `python::parse` keeps each `def` as a `FunctionSource` of
tokens, and each `class` as a `ClassSource`, parsed only when reached, so code no
kernel reaches may use any Python; an `if __name__ == "...":` driver block is skipped
unread. A module's globals are imports, `from` imports,
functions and classes. `parse_kernel_with_modules(source, modules, name, shapes)`
takes the imported modules' sources by name. A call of a helper or a method (at most
32 deep) runs its body in a new frame, with defaults (evaluated in its module),
keyword arguments and its `return`'s value; its tiles take the prefix `name[call].`
(`softmax_isa[0].row_max`, `Allocator.tile[0].x`), except that a tensor declared by
`return nl.ndarray(...)` takes the name its caller binds it to, and its errors are
`ParseError::InCall`, lines in the helper's module. A class (base `nl.NKIObject` or
none) is read on first instantiation into a `ClassDef`, its body's attributes
evaluated; calling it makes an object, run through `__init__` if it has one. An
attribute reads the object's own, else the class's, else a bound `Value::Method`, and
`obj.name = value` sets the object's own (a tensor call there declares `name`). v1's tile-returning `nki.language` calls (`load`,
`matmul` with `transpose_x=True`, `max`/`sum` over trailing free axes, `exp`,
`reciprocal`, `transpose`, and `store`) are rewritten by `tile_call`/`store` into a
tile declaration named after the target (PSUM for `matmul` and `transpose`) and
the one `nki.isa` instruction it lowers to; `load`/`store` require HBM
(`Declared::place`). `True`/`False` are `Value::Bool`. `nl.zeros` is an on-chip tile
(`buffer` defaulting to `nl.sbuf`) plus a `memset` to zero. `nl.broadcast_to(x, shape)`
(numpy's rule, partitions included) is a `tensor_copy` into a new SBUF tile from an
`ast::Operand::Broadcast`, which lowering reads through a pattern stepping 0 along each
repeated dimension (`StatementError::BroadcastShape` otherwise). A region's `.shape`
and `.dtype` are values, as a tensor's are. `tensor_call` declares the tensor of any of these calls under
the name the caller gives, binding nothing: an assignment binds its target, and
`items.append(call)` a new list item, the tile named `items[k]`. `range([start,]
stop)` unrolls like `nl.affine_range`; list literals evaluate to new lists.

A `for` over `nl.affine_range(count)` (or `sequential_range`, `static_range`: each
unrolls in program order) is unrolled at resolution rather than
lowered: the interpreter has no program counter, and the integer-expression
machinery is `parse.rs`'s. It binds the loop variable to each index, folds the
body's arithmetic and emits the body once per index; the tiles an iteration
declares take its index as a suffix (`x` becomes `x.0`, a name Python cannot
write), so each iteration owns its own, while other names rebind as in Python (the
loop variable keeps its last value). The count is any compile-time integer; a
`for` over a tuple or list unrolls the same way. Each instruction keeps its
`ast::Origin` (`LoweredKernel::origins`): its enclosing `LoopIteration`s (a `LoopId` per
execution of a `for`, its `LoopKind`, the index), outermost first across helper calls,
and which `nl.no_reorder()` block encloses it (`Reordering::Forbidden { block }`, a
`NoReorderId` per execution of the outermost block), rendered after it in `.ast`
and `.ir`; `ir::Mover` tells a DMA copy or transpose (`.ir`'s `dma`, `dma_transpose`)
from a compute engine's (`mov`, `transpose`). `success/loop_origins.py` covers
every loop kind, an inner loop entered twice and `no_reorder` across a helper call.
`footprints(kernel)` (`eval/footprint.rs`) gives each instruction's `Access`es, reads
then writes: a `Mode` (`Read`, `Write`, `Accumulate(Reducer)`: an adding `nc_matmul`'s
`Matmul`, or `Elementwise(op)` for a `tensor_tensor` whose `dst` is one of its operands'
regions under an associative `op`, mamba's `acc = acc + x`), its
tensor, a `Location` and merged runs. Placed tiles share their memory's location, by byte
(`partition * PARTITION_STRIDE + byte`); any other tensor is its own, by element offset.
A gather reads its whole `data` and `index` regions. The race fixtures' `.footprints`
snapshot them, as do those of `sequential_carried`, `affine_matmul_accumulate`,
`placed_tiles`, `access_patterns`, `indirect` and `loop_origins`.
`record_graph(kernel, policy)` (`eval/record.rs`) is the kernel's event graph: a graph
thread per instruction, its `footprints` as accesses (an accumulation the policy exempts a
`Reduction` effect, any other a read then a write; each `Location` a disjoint range, HBM in
`Global`, SBUF and PSUM in `Shared`), and
a `Dependency` edge wherever the `OrderingPolicy` says the Neuron compiler orders two
instructions. The docs say only that it synchronizes "based on data dependencies", so a
policy is four choices, each recorded as an `Assumption`. Every policy orders read after
write (`NkiReadAfterWriteOrder`: after the latest earlier writer of what it reads) and write
after read (`NkiWriteAfterReadOrder`: after every earlier reader of what it writes), unless
the two are in different iterations of one `affine_range`. There, as the `affine_range` docs
exempt "associative reductions", `nc_matmul` accumulations commute instead
(`NkiMatmulAccumulationsCommute`, every policy): each is a `Reduction(Add)`, a later access
follows every reduction since the last ordinary write, and a read of a partial sum inside
the loop still races (R8). `Reductions::Associative` (`NkiAssociativeReductionsCommute`)
extends this to `tensor_tensor` accumulations. `OrderingPolicy::BASELINE`, the
pipeline's, tracks them by address (`PlacedTiles::ByAddress`, `NkiHazardsByPlacedAddress`:
through the bytes `address=` tiles share, as the compiler must for its own reuse of on-chip
memory across tensors, and as v10, AWS's direct-allocation sample, relies on) and orders
nothing more. `WriteAfterWrite::Ordered` (`NkiWriteAfterWriteOrder`) also orders a write
after the latest earlier writer; `PlacedTiles::ByTensor` tracks hazards per tensor only,
recording no placement assumption; `NoReorder::ProgramOrder`
(`NkiNoReorderInProgramOrder`) orders each `no_reorder` block's instructions in program
order, as the API page says it does, though the scheduling guide leaves open whether its
edges are semaphores or scheduling hints; a block orders nothing against code outside it.
`OrderingPolicy::ALL` is the sixteen combinations.
`check_failure/` holds kernels that race under `BASELINE` (R0 `back_to_back_dmas` and its
`sequential_overwrite` twin, ordered by write after write; R1 `affine_overwrite` and
`affine_carried`, racing under every policy; `affine_vector_sum`, mamba's accumulation,
race free under `Reductions::Associative`; R8 `affine_matmul_partial_read`, reading a PSUM
accumulator inside the loop, racing under every policy; R0 and R1 inside a `no_reorder`
block, race free once blocks run in program order, and a rewrite across a block's
boundary, ordered by write after write), each naming what would make it race free;
`success/sequential_carried`, `affine_carried`'s twin in a `sequential_range`, and
`success/affine_matmul_accumulate`, the docs' matmul reduction, are race free; `trainium/accepted_tests.rs` runs them in program order,
`trainium/graph_tests.rs` checks their conflicting instruction pairs.

A subscript is a rectangular region: per dimension an `ast::Subscript`, a slice or
an integer index that drops the dimension (numpy's rule; `nl.ds(start, size)` is
`start:start + size`), trailing dimensions
omitted meaning whole; an empty slice or an out-of-range index is an error.
`ast::resolve_region` resolves one against a shape for the parser (an `nl.load`
tile's shape is the region's kept extents) and for `lower/` (`Scope::region`,
`Scope::tile` for an on-chip one, which must slice its partition dimension). Every
instruction operand is an `ir::TensorRegion` - full-rank `start` and `shape`, an
indexed dimension of extent 1, and each dimension's `Selection` for `.ir` - and
every shape rule compares kept shapes (indexed dimensions dropped); a broadcast
operand or reduction result needs one element per partition (`t[:, 0:1]` or
`t[:, 0]`), and matmul, transpose and an instruction's reduction a kept shape of
exactly two dimensions. An operand may instead be `t.ap(pattern, offset=0)`
(`ast::Operand::Pattern`), as `torch.as_strided`: its `[step, count]` pairs are the
view's dimensions, element `local` at position `offset + sum(step * local)` of `t`'s
row-major layout. A `TensorRegion`'s `ir::Layout` is a `Rectangle` (`start`,
`selections`) or that `Pattern`, and `TensorRegion::element` maps either; a view must
stay within `t`, and on a tile its first pair is the partitions, stepping the free
size, with every other element in its starting partition
(`StatementError::AccessPattern`, a `PatternProblem`); `ap`'s dynamic and `dtype`
parameters are rejected. A tile (`ast::TileShape`) has partitions and one or more free
dimensions; instructions evaluate each tile region through its `[partitions, free]`
view (`TensorRegion::tile_extents`/`tile_index`, other dimensions flattened
row-major), and copies pair elements in row-major order. A whole tensor is a zero
`start` with the tensor's own shape, which `.ir` renders as the bare name. The
interpreter computes an instruction's writes (`Write`, by tensor index) before
applying any, so overlapping regions of one tile read old values. Region start
restrictions of the hardware (partition offsets) are not checked. v3 to v8a and v10
parse, lower and run unmodified at `[128, 512]`.

The fixtures live in `volta_pipeline/tests/trainium/` (paths below are relative to it):
`success/` for the kernels `trainium/accepted_tests.rs` runs, `check_failure/` for the race
fixtures `trainium/graph_tests.rs` rejects, `execution_error/` for the `*_errors.py` kernels
`trainium/rejected_tests.rs` expects to fail.
`success/add.py` adds two 16 x 16 HBM tensors through SBUF tiles
(`dma_copy` in, `tensor_tensor` add, `dma_copy` out).
`success/gemm_relu.py` computes `relu(a_t.T @ b)`, its `activation`
reading the `nc_matmul`'s PSUM tile directly. `success/rms_norm.py`
normalizes each partition of a 4 x 8 tensor by `rsqrt(mean(x^2) + eps)` through
`activation_reduce` and two `tensor_scalar`s, the second broadcasting a
`[4, 1]` tile. `success/tiled_copy.py` copies an 8 x 4 tensor
through SBUF one `(4, 4)` tile of rows at a time, over an unrolled
`nl.affine_range(2)`. `success/returned_output.py` multiplies two 2 x 4
tensors into a `kernel_out` it allocates and returns.
`success/call_shapes.py` opens like the attention kernels (shape
unpacking, an alias, chained and `<=`/`>=` asserts, `nl.tile_size.pmax`) and adds
2 x 4 tensors one `(rows, cols // 2)` tile at a time; `trainium/accepted_tests.rs` passes
each fixture's call shapes. `success/softmax.py` is `softmax_isa`'s body
inline over a 2 x 3 tile, checked against `softmax.spec`. `success/matmul.spec` and `gemm_relu.spec` state those
kernels' math over their own array names (`a_t` being A transposed);
`volta_pipeline`'s `trainium/equivalence_tests.rs` checks the kernels against them,
and `softmax` against the softmax of `-x` (a reversed `subtract`) as a negative test.
`success/attention.spec` is the NKI attention samples' reference, their
`numpy_attention` in their layout (`q`, `k`, `v` as `[D, N]`, `kernel_out` as `[N, D]`).
`success/nki_samples/` vendors the samples' `attention_kernels.py` and
`attention_kernel_utils.py` unmodified (nki-samples `ef43bf3`, MIT-0), and the other
tutorials' kernel files likewise, each with a `.spec` of its reference
(`tensor_addition_nki_kernels.py`, `tensor_addition.spec`;
`matrix_multiplication_nki_kernels.py`, `matrix_multiplication.spec`;
`transpose2d_nki_kernels.py`, `transpose2d.spec`, its arrays viewed in three dimensions;
`average_pool2d_nki_kernels.py`, `average_pool2d.spec`; `mamba_nki_kernels.py`,
`mamba.spec`, its scan unrolled into causal sums; `tensor_indirection_nki_kernels.py`,
`tensor_indirection.spec`, its offsets an index array);
`attn_fwd_v2.ast`/`.ir` snapshot v2 at 128 x 128 (`common::trainium::check_lowering`, no
`.out`), and `trainium/equivalence_tests.rs` proves v2 equal to `attention.spec`
on its first output row (all 16,384 outputs in an ignored test) and refutes it
against attention with `q` and `k` swapped; v1 likewise, and v1 against v2 kernel to
kernel. `success/language_api.py` covers the tile-returning API on 2 x 2
inputs. `success/accumulate.py` accumulates `matmul.py`'s product over two
contraction chunks into `nl.zeros` (its `.expected` is `matmul.expected`).
`success/regions_softmax.py` and `regions_matmul.py` compute `softmax.py`'s
and `matmul.py`'s math with every operand of every instruction a region of a wider
tile (their `.expected` files are those fixtures').
`success/subscripts_softmax.py` and `subscripts_matmul.py` compute the same math
through integer and partial subscripts, 3-D tiles and 3-D/4-D HBM tensors, as v3 and v4
stage theirs (again `softmax.expected` and `matmul.expected`).
`success/fused_softmax.py` is softmax as v8 fuses it, over two column chunks:
`tensor_scalar_reduce` maxima, `tensor_reduce` with `negate=True`, and `activation`
with a `bias` and a `reset_reduce` sum (a hand-written `.expected`; `volta_pipeline`
proves it equal to `softmax.spec`).
`success/pipelined_scale.py` doubles a tensor as v10 schedules its work: an
allocator class sizing tiles from the call's `bfloat16` dtype, a buffers object, and
guarded stages software-pipelined over `range(0, count + 2)` in `nl.no_reorder()`
(`common::trainium::check_call`; a hand-written `.expected`).
`success/placed_tiles.py` is `matmul.py`'s product transposed with every tile
placed, a PSUM tile over the dead accumulator, `accumulate=(i != 0)` run twice (so
`accumulate=False` must overwrite), `engine=` and `dma_transpose` (a hand-written
`.expected`); `placement_errors.py`'s kernels must fail: `ClobberedRead` at the one
column a `bfloat16` tile overwrote, `accumulate=True` into unwritten PSUM,
`MixedAllocation`, and a tile past the end of PSUM.
`success/access_patterns.py` reads a strided HBM view, sums a 3-D tile over
`axis=(2,)` and copies out through a tile view with an offset (a hand-written
`.expected`); `pattern_errors.py`'s kernels must fail to lower, one per
`PatternProblem` a tile or HBM view can hit and a `tensor_reduce` over a leading axis.
`success/scan.py` scans a 2 x 3 tile with a broadcast row, from a tile and, both
ops reversed, from `1.0`, and applies `activation`'s `scale` (a hand-written `.expected`);
a test widens its parsed broadcast past its row's shape (`BroadcastShape`).
`success/indirect.py` gathers three columns, one offset repeated, over two
16-partition groups on `nisa.engine.scalar` from a call's `contents` (an `.expected`
computed from `a[p, idx[i]]`); `indirect_errors.py`'s kernels must fail, one per
`IndirectReadings`/`IndirectOffset` case and lowering's indirection errors.
`success/helper_call.py` calls
`helpers.py`'s `row_sums` twice (`common::trainium::check_importing`); both modules hold
unreached code (a conditional expression, a dict, f-strings) that is never parsed.

## Crate: volta_graph_check

**Path**: `crates/volta_graph_check/`

The seven checks of the Volta v2 design's data-race freedom check (§1.3 of the
design document), then three beyond it (allocation order and allocation permit,
PTX ISA rules, and mbarrier release order), one
module each, each callable on an `EventGraph` in
isolation with explicitly passed certificates, each with its algorithm and
contract (PASS/FAIL/UNKNOWN meaning) in its module docs. Every check returns
`PropertyResult<E, V> = Pass(evidence) | Fail(witnesses) | Unknown(unresolved)`;
none turns an unsupported case into `Pass`. Depends only on `volta_graph` (and
`volta_common`, for its logging macros).

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
- `domain.rs` - the memory domains: `M` (non-atomic global/shared effects, reductions and async
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
  unordered pair once, at its lowest byte); no benign equal-store exception; two
  reductions with one `ReductionOp` commute and are never a pair, while a reduction is a
  write to any other effect; atomics are outside the contract (`Unknown`); a pass issues
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
and every kernel `Verified` (a kernel whose interpreter records no graph,
`GraphBranch::NotRecorded`, is at best UNKNOWN); any refutation, failed check or
deadlock is REJECT; anything else is UNKNOWN. Tests:
`ptx/aggregation_tests.rs` (real kernels through both branches),
`amd/equivalence_tests.rs` (compiled AMD matmul, MFMA matmul, CK GEMM, CK attention,
and softmax against their formulas, accounting for CK's column-major B and softmax at
several workgroup sizes; negative tests swap matmul inputs or attention's query and key,
or change the softmax row width). CK attention checks two batches and two heads on grid
(2, 1, 2), all 16,384 outputs with exact per-workgroup footprints, and rejects a wrong Q head
stride. Workgroups run separately; cross-workgroup races are not checked.
CK GEMM's main-loop tests check all 1,600 outputs at M=N=40, K=192 and refute swapped inputs.
CK RMSNorm checks every output of both rows of a 2 x 1,024 tensor and of a padded 1,000-element
row against `row_rms_norm.spec`, and refutes a wrong epsilon; `amd/graph_tests.rs` requires
exactly one LDS write per wave.
CK average pooling checks every output against `avg_pool2d_nhwc.spec` (a `padded` input) for
unpadded, padded, dilated and two-workgroup launches, each workgroup writing exactly its own
outputs, with arguments built as CK's host code builds them (`ck_avgpool2d_params`). It
refutes the undivided sum and padding on the other side. A launch whose output is larger than
its input must be rejected: CK's output buffer bound drops four of its nine stores, and
`check_against_spec` reports those outputs as never written (`IndexSetMismatch`). The
`volta solve` launch files `examples/lean/avgpool2d_amd*.json`, `fmha_amd*.json`,
`gemm_amd.json` and `gemm_sigmoid_amd.json` are snapshots of the argument builders' labelled
parameters (`ck_avgpool2d_params`, `ck_fmha_params`, `ck_gemm_params`), rendered by
`common::amd::Launch` (`VOLTA_BLESS=1` rewrites them).
`trainium/equivalence_tests.rs` checks that an NKI kernel proved equal to its spec whose
graph verifies is ACCEPT through `solve` and `decide`, citing `NkiReadAfterWriteOrder`,
`NkiWriteAfterReadOrder` and `NkiHazardsByPlacedAddress`, and
that `check_failure/back_to_back_dmas.py` is rejected through the frontend; it checks the NKI `matmul`, 
`gemm_relu` and `softmax` fixtures against the `.spec` files beside them, with `gemm_relu` 
against the unclamped product and `softmax` against the softmax of `-x` as negative tests,
and the NKI samples' `attn_fwd_v1` and `attn_fwd_v2` against `attention.spec` and each
other, on their first row by default, with `q` and `k` swapped as a negative test;
the tiled `attn_fwd_v3` to `attn_fwd_v8a` and `attn_fwd_v10` from the file, each in its
upstream input dtype (`bfloat16` for v10, else `float32`), v3 to v8a with their `assert
seqlen_q >= 512` stated as `>= FMAX_MOVING` - checked to change nothing at hardware tile
sizes - each proved equal to the spec, and to the version before it (v8a for v10),
everywhere at four reduced `TileSizes` (the last wrapping v10's QK matmuls around its
seven PSUM banks), refuted with `q` and `k` swapped, and unmodified at `[128, 512]`
on one row of each of the four query tiles in one ignored test, about 5 minutes and 12 GB,
mostly the spec's unfolding and the eight kernels' runs (upstream's seqlen 4096 for v10
is out of reach); `fused_softmax` against
`softmax.spec`; the tensor addition tutorial's `nki_tensor_add`, unmodified, against
`tensor_addition.spec` at its driver's 256 x 1024, refuted against a subtraction; the
matrix multiplication tutorial's five kernels against `matrix_multiplication.spec`,
`nki_matmul_basic_` at its asserted 64 x 512 x 128 and the four tiled ones, each also
against the one before, at two reduced `TileSizes` and once with the fully optimized
kernel's meta-parameters given as `Constant`s, refuted against a doubled product; the
transpose2d tutorial's kernel, `shape2D` a `Constant::Ints`, against `transpose2d.spec`
at its drivers' 5 x (3 x 4) and 5 x (37 x 44), refuted against the identity; the
average_pool2d tutorial's kernel, its `.ap()` view summed over `axis=[3, 4]`, against
`average_pool2d.spec` with 2 x 2 and 4 x 4 windows, refuted against the unscaled sum
and against overlapping windows; the fused_mamba tutorial's `mamba_v1` to `mamba_v3`
against `mamba.spec` and each other at 2 x 128 x 8 x 2 with `pmax` 64 and
`gemm_moving_fmax` 4, v3's `seq_len_fsize = 512` stated as that tile size (checked to
change nothing at hardware sizes) so it carries its scan across two sequence tiles,
refuted against a decay one step too long, a scan without its recurrence and, for v3,
its scan restarted each tile; the tensor_indirection tutorial's kernel, its offsets a
call's `contents`, against `tensor_indirection.spec` (an index array) at its driver's
128 x 64 x 32 for four offset vectors and at 16 x 8 x 16 and 48 x 20 x 48, refuted
against one moved offset and the ungathered `data[:, i]`.
AMD output checks require the same run's graph to conclude `Verified`: snapshots,
equivalence comparisons, the Lean challenge, and the grid tests' individual workgroup runs.
`amd/graph_tests.rs` checks LDS reuse and pending-read races, and requires the snapshot helper
to reject a completed kernel with an LDS race. `just amd` runs the accepted, rejected and
equivalence suites; the full `amd_tests` target also runs graph, grid and Lean tests.
`trainium/graph_tests.rs` checks NKI graphs under `BASELINE` unless a test names another
policy: fixtures whose tiles are written once or rewritten after their readers, and the
attention samples v1 to v10, verify; each race fixture in `trainium/check_failure/` fails
`MemoryConflict` with exactly its expected instruction pairs; writes with no read between
them verify once write after write is ordered; with hazards tracked per tensor only, v10's
races all pair `v_psum_t`, transposed before its `no_reorder` block, with `qk_psum` over the
same PSUM bytes inside it (R2/R3); `nc_matmul` accumulations across `affine_range`
iterations (the tiled matmul tutorials) verify under every policy, `tensor_tensor` ones
(mamba) under `Reductions::Associative`, while a read of a partial sum and the other
`affine_range` fixtures race under every policy. A table test checks every NKI fixture and
sample under all sixteen policies against `trainium/ordering_policies.txt` (`VOLTA_BLESS=1`
rewrites it). `just trainium` runs its accepted, rejected and
equivalence suites.

### End-to-end tests (`tests/`)

Every kernel-driven test of the workspace, in three test targets, `ptx_tests`,
`amd_tests` and `trainium_tests` (`tests/<isa>/main.rs`, one module per suite). The AMD and
NKI suites are those above; `common::amd` and `common::trainium` hold their helpers. Each
PTX suite, a module of `tests/ptx/`, runs
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
that `volta_viz` store, keyed `<suite>/<test>[~<n>]`, the suite being the ISA and the
test's module (`ptx_accepted_tests`; libtest names each test's thread after its path; `n`
counts the test's runs).

## Crate: volta_equivalence

**Path**: `crates/backend/volta_equivalence/`

`tests/specs/matmul_transposed.spec` stores B as `[N, K]` for `B[j, k]`, including rectangular operands.
`attention_batch_head.spec` selects one batch/head from global BHSD inputs and returns its local output slice.

Everything after VC extraction: takes two `SymbolicOutputs` and decides them
element by element. Depends only on `volta_expr` (and `volta_common`, for its
logging macros), so it checks expressions
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

## Crate: volta_lean

**Path**: `crates/backend/volta_lean/`

Lean proofs of a `challenge.lean` (`extract_lean`'s module, taken as text, so the crate
depends only on `volta_common`; `volta_py`'s `prove_lean` composes the two). Every module
is private; `lib.rs` re-exports the API.

- `Toolchain::of(project)` - `lean`, `leanchecker`, `LEAN_PATH` and library sources of a
  Lake project with Mathlib built (`project`, else `$VOLTA_LEAN_PROJECT`), from `lake env`
- `Workspace::open(directory, challenge, project)` compiles the challenge from Volta's
  text into a private build directory (removed on drop); `check()` -> `LeanCheck`
  refuses imports beyond `challenge`/Mathlib and anything that runs code while compiling,
  then needs every `VoltaProofs.<name>` to have type exactly `VoltaChallenge.<name>` with
  only `propext`/`Classical.choice`/`Quot.sound` (the embedded `check_proof.lean`, run as
  `lean --run`) and `leanchecker` to replay it. `WorkspaceConfig` reopens a workspace in
  another process (the MCP server's).
- `Tool::ALL` - the agent's only actions (`read_challenge`, `read_proof`, `write_proof`,
  the one write, with a `per_statement` template, `check_proof`, `search_library`);
  `serve`/`serve_stdio` serve them as a stdio JSON-RPC MCP server
- `ClaudeCode` - a `claude -p` session with no built-in tools, only Volta's, started by
  the caller's `ToolServer` command (a Python extension cannot exec itself); it refuses a
  session whose tools are not exactly those, writes `transcript.jsonl` and logs `[lean]`
  lines. `find_claude` locates the binary.
- `prove(challenge, directory, project, agent, server, observer)` -> `LeanProof`: the verdict
  is the final check's, never the agent's. Each step is a `Progress`, logged as `[lean] ...`
  and handed to `observer` (`volta_py`'s `prove_lean(verbose=True)` prints them).
  `check_lean_proof` runs the check alone.

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
