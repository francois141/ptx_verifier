# volta_ptx_analysis

The analysis stage: an abstract interpreter for PTX kernels. It takes a parsed
module, a kernel name and a launch configuration, symbolically executes **one
CTA** under **one deterministic schedule**, and returns:

- the **symbolic outputs**: every written output element as an expression over
  the inputs (`volta_expr::SymbolicOutputs`), and
- the **event graph** of that execution (`volta_graph::EventGraph`): every
  memory effect, synchronization and async operation, in trace order.

It gives no verdict. It runs no race check and no equivalence check. The
pipeline sends the outputs to `volta_equivalence` and the graph to
`volta_graph_check`.

```rust
let result = volta_ptx_analysis::analyze(&module, Some("kernel"), config)?;
let graph = result.graph();                 // always present (partial on abort)
let outputs = result.symbolic_outputs()?;   // only if the run completed
```

`analyze_lowered(&program, config, provenance)` runs the same interpreter on a
`LoweredProgram` supplied by a caller, returning `Result<AnalysisResult, EvalError>`.
The caller must supply well-formed IR, establish that it preserves the source
semantics, provide matching launch and instruction provenance, and call
`SymbolTable::finalize_shared_layout` before running. This entry point uses the
existing interpreter's semantics; it does not validate another frontend's
translation. The interpreter itself remains private.

## Frontend (`frontend/`)

`frontend/` turns PTX source text into a typed AST. It is the one public module
(`volta_ptx_analysis::frontend::{parse, ast, ...}`), and it imports nothing else of
the crate.

```
PTX text ──lex.rs──► tokens ──parse.rs──► ast::Module ──instr_parse.rs──► ParsedInstruction
                                          (directives,                    (~105 typed variants,
                                           functions, generic              validated modifiers
                                           instructions)                   and operands)
```

### Stages

1. **Lexer** (`lex.rs`): turns source into tokens. The parser drives it with
   `next()`, `peek()` and `expect(kind)`. `ascii.rs` is a vendored copy of
   std's unstable ASCII-character module, so the frontend builds on stable.
2. **Parser** (`parse.rs`): a Pratt parser producing `ast::Module`: version,
   target, address size, module-level variables, and functions (kernels and
   device functions) with their parameters and bodies. The entry point is
   `parse_module()`. Unknown directive names produce a located `InvalidDirective`
   instead of being silently accepted as generic directives.
3. **Mnemonic resolution** (`instr.rs`): `InstrTrie` maps a dotted mnemonic
   such as `cp.async.bulk.tensor.2d.shared::cluster.global.mbarrier...` to an
   `InstrKind` in one pass over the characters. The parser stores each
   instruction as `InstructionOp::Unparsed { kind, modifiers, operands }`.
4. **Typed instruction parsing** (`instr_parse.rs`): converts an `Unparsed`
   instruction into a strongly typed `ParsedInstruction` (defined in `ast.rs`).
   It checks the modifiers allowed for that kind, operand arity
   (`expect_operands`) and operand shapes, so the later stages never parse
   strings. Both `ret` and `ret.uni` require exactly zero operands.
   `exit`, `brkpt`, and `trap` require zero operands and accept no modifiers.
   `mbarrier.arrive` takes two or three operands.

### Key AST types (`ast.rs`)

- `Module`: top level (version, target, address size, directives).
- `Function`: a kernel or device function with params and body statements.
- `Instruction`: a generic instruction (predicate guard, op, operands).
- `ParsedInstruction`: the typed form, one variant per supported instruction
  family.
- `ScalarType`: `Pred`, or `Signed`/`Unsigned`/`Float`/`Bits` with a width.

The frontend accepts more than the analysis supports. For example, `wgmma`
parses, and lowering rejects it.

### Adding an instruction

Add an `InstrKind` variant and its trie entry (`frontend/instr.rs`), then a
`ParsedInstruction` variant and its parser function (`frontend/instr_parse.rs`).
Then lower it (`lower/`) and evaluate it (`eval/`).

## Pipeline inside the crate

```
PTX text ──frontend/──► ast::Function ──lower/──► LoweredProgram ──eval/──► Interpreter::run ──► AnalysisResult
                          (ir/: linear IR,          (round-robin          { arena, graph,
                           resolved ids)             symbolic execution,    outputs?, stats }
                                                     eval/record.rs builds
                                                     the event graph)
```

### 1. Lowering (`lower/` to `ir/`)

Lowering turns the typed AST into a linear program `LoweredProgram =
IdVec<InstrId, LoweredInstr> + SymbolTable + SourceMap`. Registers become
`RegId`s (class + index), labels become `InstrId`s, and shared/local/global
variables get concrete addresses. `ir/` is the only contract between `lower/`
and `eval/`; neither imports the other. Lowering is split by instruction family
(`arith`, `memory`, `control`, `warp`, `mbarrier`, `tma`, `tcgen05`, `clc`),
and the dispatch is in `lower/mod.rs`. Multi-statement idioms collapse here
(`idioms.rs`): the nvcc `__symexpf` call sequence becomes `UnaryOp::Exp`, and
the `mbarrier.try_wait` retry loop becomes one blocking `MbarrierWaitParity`.
Features Volta does not model (`wgmma`, `activemask`, `mbarrier.inval`, ...)
are rejected as `LowerError`s. An immediate `mbarrier.init` or `mbarrier.arrive`
count outside `[1, 2^20 - 1]` is an invalid operand; a register count outside it
aborts the run with `EvalError::MbarrierCountOutOfRange`.

### 2. Evaluation (`eval/`)

`Interpreter` holds one register file per thread, byte-addressed memories
(global, shared, local, param), Tensor Memory, mbarrier and tensor-map tables,
and an `ExprArena` all values live in. Every value is a symbolic expression.
Inputs become `InputElement` symbols the first time they are read, and
constants fold eagerly.

- **Scheduling** (`schedule.rs`): run one ready thread until it blocks or
  exits, then fire whatever group is complete (a warp rendezvous, an mbarrier
  phase, a named barrier) and wake its waiters. If nothing can run or fire, the
  run ends **stuck** (deadlock). Exited threads count as arrived (Sync').
- **Concreteness**: addresses, branch conditions and sync parameters must be
  concrete, i.e. depend only on thread ids and concrete parameters. Otherwise the
  run fails with `NotConcrete`. Only CTA 0 runs; it stands for the grid.
- **Families**: `arithm.rs` (ALU, `cvt`, width canonicalization), `warp.rs`
  (`shfl`, `ldmatrix`, `mma.sync`, `wmma`, warp-scoped `tcgen05`),
  `cp_async.rs`, `async_bulk.rs` (TMA, `cp.async.bulk`), `mbarrier.rs`,
  `tcgen05.rs` + `tcgen05_mma.rs`, `tensormap_replace.rs`,
  `cluster_launch_control.rs` (under the never-steal assumption).
- **Errors** (`error.rs`): `EvalError` covers things the execution itself
  cannot continue past: out-of-bounds, uninitialized reads reaching an output,
  `trap`, barrier count mismatches, and so on. Data races are **not**
  `EvalError`s. They are found later by the graph checks.

### 3. Recording the event graph (`eval/record.rs`)

The interpreter calls a `record_*` hook at each effect and sync point. Each
hook translates the event into `volta_graph::GraphBuilder` calls. A small
`Recording` struct holds producer-side bookkeeping: the forming generation of
each named barrier, warp op and mbarrier, the MMAs awaiting a commit, and the
`tcgen05.ld/st` awaiting a wait. Execution never reads any of it, so recording
cannot change behavior.

| hook                                         | records |
|----------------------------------------------|---------|
| `record_mem_access`, `record_tmem_*`         | a `MemAccess` (thread event, or an async op's effect via `AccessOrigin::Async`) |
| `record_barrier_arrival` / `_fire`           | named-barrier generation: contributions, exited arrivals, completion, resumes |
| `record_warp_op_arrival` / `_entry`, `record_collective_exit` | the `Entry` and `Exit` generations around each warp op |
| `record_mbarrier_init` / `_arrival` / `_expect_tx` / `_complete_tx` / `_progress` | an mbarrier lifetime, its pre-init phase, its phases and their contributions |
| `record_mbarrier_wait` / `_wake`             | `WaitStart`, and `Resume` into the latest completed phase |
| `record_async_issue`, `record_tracked_by_mbarrier`, `record_mma_commit`, `record_tcgen05_wait`, `record_group_wait` | async ops and the generations tracking their completion |
| `record_exit`                                | `Exit` |

See `crates/volta_graph/README.md` for the full graph model and a worked
example.

### 4. Result (`analysis.rs`)

`AnalysisResult` always holds the arena, the graph, `Stats` and per-kind
op counts. Symbolic outputs are present only if every thread exited and
every output element read back. Otherwise `OutputsUnavailable` says why
(`Aborted`, `Stuck`, `Extraction`). `Provenance` records the launch, target
and the modeling `Assumption`s the run made.

## Configuration (`config.rs`)

`AnalysisConfig`: block/grid dims, positional `ParamValue`s (int, float,
symbolic float, array pointer), `ArrayDef`s (`Input`, `Output`, `InputOutput`,
`IndexInput`), module-global values and dynamic shared size. `validate()`
rejects ambiguous configs. Symbol identity comes only from config names, never
from PTX register names.

`launch_file.rs`: `LaunchFile::from_json` reads a JSON launch file (`volta
analyze --config`) into the kernel it names and a validated
`AnalysisConfig`. Arrays take a `dtype` and a `shape` and are laid
out on 64 KiB boundaries unless given a `base`; params are `{"int": N}`,
`{"float": X}`, `{"sym": name}` or `{"ptr": array}` with an optional `name`
label; unknown keys are errors. The module docs give the full format.

## Module layout

Every module but `frontend` is private. `lib.rs` re-exports the public API (`analyze`,
`analyze_lowered`, `AnalysisResult`, `AnalysisConfig`, `EvalError`, `LowerError`,
`Stats`, `write_op_counts`, ...), along with the IR types for constructing lowered
programs (`LoweredProgram`, `LoweredInstr`, `Operand`, `SymbolTable`, `SourceMap`,
and supporting types), so dead code is flagged by rustc. Logging (barrier
fires, deadlocks, launch stats) is behind the `logging` feature.

## Tests

Only inline unit tests of internals (e.g. `lower/tests.rs`). Every PTX-driven
test is end-to-end in `volta_pipeline/tests/`. Its `lowered_program_tests.rs`
also exercises the public IR execution API without parsing PTX.
