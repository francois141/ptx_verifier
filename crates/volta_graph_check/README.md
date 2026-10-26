# volta_graph_check

The graph branch of the pipeline: ten checks over one `volta_graph::EventGraph`
that decide whether the recorded candidate execution is free of data races,
proxy and tensor-ordering hazards, and synchronization misuse. Seven are the
algorithms of the Volta v2 design's data-race freedom check (Algorithms 1-7);
three more enforce PTX ISA rules the design leaves out. The crate depends only
on `volta_graph`. It never runs symbolic execution or equivalence checking.

## High-level logic

```
EventGraph ──validate──► typed edge projections (G0, G_HB, D, E_pipeline)
                               │
                               ▼
     the ten checks, in prerequisite order, each returning
     Pass(evidence) | Fail(witnesses) | Unknown(unresolved)
                               │
                               ▼
     GraphReport::conclusion() = Verified | Rejected { failed, deadlock } | Unknown
```

The event graph stores raw, tentative facts: "this arrival joined generation
`g3`", "this TMA completion counted toward phase 2". A check may not trust a
tentative fact until an earlier check has validated it. So the checks form a
chain of **certificates**: a passing check returns a typed evidence value,
and only that value can build the stronger projection the next checks use.
The type system enforces the order. `ValidatedGraph` (`G_HB`) has no public
constructor except `from_certificates(named_epochs, mbarrier_epochs,
mbarrier_ordering)`. `assuming_epochs` exists for isolated tests.

## Building the ordering relation (`relation.rs`)

The graph's edges are grouped into typed sets and never used untyped:

```
E = E_PO ∪ E_causal ∪ E_sync ∪ E_pipeline
```

- **`E_PO`** program order: each thread's `program_order` sequence.
- **`E_causal`**: an async op's `Issue -> each effect -> Complete`. The
  issuer's program order continues from the issue, so nothing orders the
  effects before the issuer's *later* events.
- **`E_sync`**: each generation's joins (contribution -> completion) and
  releases (completion -> `Resume`).
- **`E_pipeline`** (`pipeline.rs`): implicitly pipelined `tcgen05` pairs (see
  below). No projection includes it; only the tensor-order check reads it.

Two **projections** select which `E_sync` joins count. `Admission::joins`
decides each contribution kind:

| contribution                                    | `G0` (execution order) | `G_HB` (memory order) |
|-------------------------------------------------|:----:|:----:|
| `Blocking`, `Arrival { Release }`               | yes  | yes  |
| `Arrival { AsyncTracked }` (`tcgen05.commit`, `cp.async.mbarrier.arrive`) | yes | no |
| `Exited` (Sync' only)                           | yes  | no   |
| `AsyncCompletion` into an mbarrier phase        | no (not yet validated) | yes |
| `AsyncCompletion` into a wait collective / wait-group | yes | yes |
| `CompleteTx`, `ExpectTx` (relaxed)              | no   | no   |
| members of an `ExecutionOnly` collective        | no   | no   |

- **`IndependentGraph` (`G0`)** is what the barrier-epoch and mbarrier-ordering
  checks run on. It holds every join this execution produced except the mbarrier
  phase completion joins, which those checks are still validating. In `G0` an
  async completion also carries what preceded its op's issue.
- **`ValidatedGraph` (`G_HB`)** adds the validated mbarrier completion joins
  and follows the PTX memory model for async ops: an async arrive-on or
  completion is ordered only with *that op's own* memory effects, not with the
  issuer's earlier accesses. So it joins nothing of the thread, and a completion
  carries only its op's effects. An exited thread is also not a barrier
  participant here. `G_HB` is also Algorithm 5's `D`;
  `ValidatedGraph::successors()` returns its explicit successor lists.

### Reachability by vector-clock sweep

Every edge runs forward in trace order (checked by `EventGraph::validate`), so
trace order is a topological order. `sweep(graph, admission, visit)` walks the
events once in trace order, keeping one vector clock per thread
(`clock[t] = index of the last event of t that reaches here`):

- a thread event increments its own entry;
- a joining `Contribute` merges its thread's clock into the generation's clock;
- a `GenerationComplete` merges the admitted exited threads and (in `G0`) the
  issue clocks of the async ops it tracks;
- a `Resume` merges the generation's clock into the thread's;
- an async event's clock is its op's issue clock.

At each event the callback gets an `HbView`. `thread_hb(ThreadPoint)` answers
"does thread event `(t, i)` reach here" as `clock[t] >= i`.
`effects_hb(op)` answers it for an async op's effects. Every path out of an
effect goes through the op's completion and then a release of a generation that
joins it, so the effects reach the visited event iff one of those **observers**
(`Resume` events) does.

## The checks

`suite::check_graph(&graph)` runs them in `Property::ALL` order. A check whose
prerequisites did not pass is `Unknown`. No check turns an unsupported case into
`Pass`.

| #  | `Property`             | Module                    | Runs on | Question it answers |
|----|------------------------|---------------------------|---------|---------------------|
| 1  | `NamedBarrierEpoch`    | `barrier_epoch.rs`        | `G0`    | Is generation `k` of each named barrier separated from `k+1`? Every synchronization of `k` must reach the program predecessor of every contribution of `k+1` (Weft's criterion). |
| 2  | `MbarrierEpoch`        | `barrier_epoch.rs`        | `G0`    | The same over mbarrier phases (pre-init = phase `-1`). A wait of phase `k+1` instead needs one release of `k` before it. |
| 3  | `MbarrierOrdering`     | `mbarrier_ordering.rs`    | `G0`    | Does each phase's arrival/transaction count balance (`D = n_k`, `T = 0`), and is every `expect_tx` announcement ordered after an arrival of its phase? |
| 4  | `MemoryConflict`       | `memory_conflict.rs`      | `G_HB`  | Is every overlapping pair of effects in domain `M` (global/shared) with a write ordered? A per-byte dominance forest reports each unordered pair once. |
| 5  | `ProxyOrder`           | `proxy_order.rs`          | `G_HB`  | Does every ordered generic/async cross-proxy pair have a covering fence (`fence.proxy.async`, or the implicit fence of an observed completion)? Does each tensor-map write reach a TMA's map read through a release/acquire pair? |
| 6  | `TensorOrder`          | `tensor_order.rs`, `sync_search.rs` | `D`, `E_pipeline` | Is every conflicting Tensor Memory pair of distinct ops pipelined, or connected by a `D` path through a source-thread `before_thread_sync` (or tracking commit) and a target-thread `after_thread_sync`? (Algorithm 6, a 3-state DFS.) |
| 7  | `ResourceLifetime`     | `resource_lifetime.rs`    | `G_HB`  | Is every TMEM use inside an allocation that is freed exactly once, with alloc -> use -> dealloc ordered? |
| 8  | `AllocationOrder`      | `allocation_order.rs`     | `G_HB`  | Are the `tcgen05.alloc`s totally ordered, with non-increasing column counts? |
| 9  | `AllocationPermit`     | `allocation_permit.rs`    | `G_HB`  | Does every allocation reach every `relinquish_alloc_permit`? |
| 10 | `MbarrierReleaseOrder` | `mbarrier_release_order.rs` | `G0`  | Do each mbarrier's waits observe its phases in sequence 0, 1, 2, ... (optionally from pre-init), with each phase's releases reaching the next phase's? |

Prerequisites (`Property::prerequisites`): 1, 2, 3 and 10 need nothing; 4 and
6-9 need 1, 2, 3 (to build `G_HB`); 5 also needs 4.

### Supporting modules

- `domain.rs`: the memory domains obligations are split by. `M` is ordinary
  global/shared effects, sync or async, including `tcgen05` shared-memory
  operands. `A` is Tensor Memory effects of `tcgen05` ops. Atomics are in
  neither; they are outside the contract.
- `pipeline.rs`: `E_pipeline`, the pairs the PTX ISA (9.7.18.6.2) pipelines
  without explicit sync. These are same-thread `tcgen05.mma` chains on one
  accumulator, and same-warp `st->ld`, `st->st`, `ld->st` pairs separated by
  the earlier op's own `tcgen05.wait`. Each edge keeps its rule, roles and
  covered cells. `pipelinable` is the same pairing without the one-thread and
  wait preconditions; `sync_search` uses it to choose where the search starts.
- `sync_search.rs`: Algorithm 6. A DFS over `D` from the source op's issue
  (pipelinable pairs) or completion (all others), with state
  `0 -before fence-> 1 -after fence-> 2`. It accepts only at the target's issue
  in state 2, and memoizes `(vertex, state)`.
- `result.rs`: `PropertyResult<E, V> = Pass(E) | Fail(Vec<V>) |
  Unknown(Vec<Unresolved>)`, `Property`, `Verdict`.
- `suite.rs`: `check_graph`, `GraphReport` (per-check results and summaries),
  `GraphConclusion`, `Deadlock` (from a `Terminal::Stuck`).

## Conclusion

- **`Verified`**: the trace completed and all ten checks passed. Nothing else
  is consulted.
- **`Rejected { failed, deadlock }`**: some check failed (with its typed
  witnesses), or the trace is stuck (a deadlock).
- **`Unknown`**: nothing failed, but some obligation is unresolved or the trace
  was aborted. The checks still run on a partial graph.

## Tests

`tests/` holds graph-level unit tests built with `GraphBuilder`. End-to-end PTX
tests for each check live in `volta_pipeline/tests/<check>_tests.rs` and assert on
the check's typed witness.
