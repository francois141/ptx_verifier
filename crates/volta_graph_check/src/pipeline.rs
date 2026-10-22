//! **Implicit tensor-pipeline ordering** (§1.2, step 5): the typed relation `E_pipeline`.
//!
//! ```text
//! EligiblePipeline(x, y, a, b)  =>  (a, b) in E_pipeline
//! ```
//!
//! * Candidate pairs `(x, y)` of dynamic `tcgen05` operations are matched to the supported PTX
//!   rules by opcode and operand role; the matched rule's issue-order, warp, CTA-group,
//!   address, shape and instruction-specific preconditions are checked, and an edge joins each
//!   covered pair of effects `a ∈ Effects(x)`, `b ∈ Effects(y)`. An edge keeps its rule, its
//!   operand roles and the physical cells it covers. It orders operand accesses only: not
//!   whole-operation completion, not general memory visibility.
//! * Supported rules (PTX ISA 9.4, 9.7.18.6.2 "Pipelined tcgen05 Instructions"):
//!   - Accumulator chains ([`PipelineRule::MmaAccumulatorChain`]): `tcgen05.mma.cta_group::1`
//!     (Volta's only form) then another, issued by the same thread in that program order (so
//!     one warp, issue order), on the same accumulator: identical Tensor Memory `D`
//!     footprints, hence the same address and `M x N` shape. It covers their accumulator
//!     (`D`) effects; `A`/`B` reads are not covered. An MMA without an accumulator write has
//!     unknown preconditions and gets no edge.
//!   - Waited loads and stores ([`PipelineRule::WaitedLoadStore`]): `tcgen05.st` ->
//!     `tcgen05.ld`, `st` -> `st` or `ld` -> `st` (pairs 11-13), issued by one warp in that
//!     order, with the earlier operation's own `tcgen05.wait` (`::st` for a store, `::ld` for
//!     a load) between them: the wait's release of the later operation's issuer precedes its
//!     issue. It covers their Tensor Memory data effects. Instructions of different warps are
//!     never pipelined.
//! * Every edge joins two operations of one thread (Volta issues a warp's `tcgen05.ld`/`.st`
//!   from its first lane and rejects them once a lane exited), so all are constructed
//!   immediately; none needs a thread handoff's validation. No projection of
//!   [`crate::relation`] contains them.
//! * [`pipelinable`] is the same pairing without the one-thread and wait preconditions: a pair
//!   the ISA would pipeline once its warp's threads are synchronized, which Algorithm 6 may
//!   then order from the earlier operation's issue.

use std::collections::{BTreeMap, HashMap};

use volta_graph::{
    AccessMode, AsyncOp, AsyncOpId, AsyncOpKind, CollectiveSide, EventGraph, EventId, EventKind,
    ExecContext, Footprint, GenerationKind, OperandRole, Space, SyncObjectKind, ThreadIx,
};

const WARP_SIZE: u32 = 32;

/// A supported implicit-pipelining rule of the PTX ISA.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum PipelineRule {
    /// `tcgen05.mma` -> `tcgen05.mma` of one thread on one accumulator.
    MmaAccumulatorChain,
    /// `tcgen05.st` -> `.ld`, `.st` -> `.st` or `.ld` -> `.st` of one warp, the earlier one
    /// waited for in between.
    WaitedLoadStore,
}

/// One edge `(a, b)` of `E_pipeline`.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct PipelineEdge {
    pub rule: PipelineRule,
    pub from: EventId,
    pub to: EventId,
    pub roles: (OperandRole, OperandRole),
    /// The cells both effects touch.
    pub cells: Footprint,
}

/// `E_pipeline` of one graph: the accumulator chains and each warp's `tcgen05.ld`/`.st`, ops
/// in issue order.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct PipelineEdges {
    chains: Vec<Vec<AsyncOpId>>,
    position: HashMap<AsyncOpId, (usize, usize)>,
    loads_stores: BTreeMap<u32, Vec<AsyncOpId>>,
}

/// A Tensor Memory rectangle: first lane, lanes, first column, columns.
type Rectangle = (u8, u8, u16, u16);

/// The accumulator footprints an MMA writes, sorted: its `D`.
fn accumulator(graph: &EventGraph, op: AsyncOpId) -> Vec<Rectangle> {
    let mut d: Vec<Rectangle> = graph
        .async_op(op)
        .effects
        .iter()
        .map(|&a| graph.access(a))
        .filter(|a| {
            a.space == Space::Tensor
                && a.role == OperandRole::Accumulator
                && a.mode == AccessMode::Write
        })
        .filter_map(|a| match a.footprint {
            Footprint::Tensor {
                lane,
                lanes,
                col,
                cols,
            } => Some((lane, lanes, col, cols)),
            Footprint::Bytes { .. } => None,
        })
        .collect();
    d.sort_unstable();
    d
}

/// `E_pipeline` of `graph`.
pub fn pipeline_edges(graph: &EventGraph) -> PipelineEdges {
    let mut keys: HashMap<(ThreadIx, Vec<Rectangle>), usize> = HashMap::new();
    let mut edges = PipelineEdges::default();
    for (op, a) in graph.async_ops().iter() {
        if matches!(a.kind, AsyncOpKind::Tcgen05Ld | AsyncOpKind::Tcgen05St) {
            edges
                .loads_stores
                .entry(a.issuer.0 / WARP_SIZE)
                .or_default()
                .push(op);
        }
        if a.kind != AsyncOpKind::Tcgen05Mma {
            continue;
        }
        let d = accumulator(graph, op);
        if d.is_empty() {
            continue;
        }
        let next = keys.len();
        let chain = *keys.entry((a.issuer, d)).or_insert(next);
        if chain == edges.chains.len() {
            edges.chains.push(Vec::new());
        }
        edges
            .position
            .insert(op, (chain, edges.chains[chain].len()));
        edges.chains[chain].push(op);
    }
    edges
}

impl PipelineEdges {
    /// The edge `(a, b)`, if `EligiblePipeline` holds for `a`'s and `b`'s operations and
    /// effects under one of the rules, `a`'s operation first.
    pub fn edge(&self, graph: &EventGraph, a: EventId, b: EventId) -> Option<PipelineEdge> {
        self.accumulator_chain_edge(graph, a, b)
            .or_else(|| waited_load_store_edge(graph, a, b))
    }

    /// [`PipelineRule::MmaAccumulatorChain`]: `a` an accumulator effect of an MMA chained before
    /// `b`'s, sharing cells.
    fn accumulator_chain_edge(
        &self,
        graph: &EventGraph,
        a: EventId,
        b: EventId,
    ) -> Option<PipelineEdge> {
        let (x, ax) = accumulator_effect(graph, a)?;
        let (y, by) = accumulator_effect(graph, b)?;
        let (&(cx, px), &(cy, py)) = (self.position.get(&x)?, self.position.get(&y)?);
        if cx != cy || px >= py {
            return None;
        }
        let cells = shared_cells(ax, by)?;
        Some(PipelineEdge {
            rule: PipelineRule::MmaAccumulatorChain,
            from: a,
            to: b,
            roles: (OperandRole::Accumulator, OperandRole::Accumulator),
            cells,
        })
    }

    /// Every edge of `E_pipeline`, in issue order of their operations.
    pub fn edges(&self, graph: &EventGraph) -> Vec<PipelineEdge> {
        let effects = |op: AsyncOpId| -> Vec<EventId> {
            graph
                .events()
                .iter()
                .filter(|(_, ev)| {
                    ev.ctx == ExecContext::Async(op) && matches!(ev.kind, EventKind::Access(_))
                })
                .map(|(id, _)| id)
                .collect()
        };
        let mut out = Vec::new();
        for chain in self.chains.iter().chain(self.loads_stores.values()) {
            for (i, &x) in chain.iter().enumerate() {
                for &y in &chain[i + 1..] {
                    for a in effects(x) {
                        for b in effects(y) {
                            out.extend(self.edge(graph, a, b));
                        }
                    }
                }
            }
        }
        out
    }
}

/// `event`'s operation and footprint, if it is an MMA's accumulator effect.
fn accumulator_effect(graph: &EventGraph, event: EventId) -> Option<(AsyncOpId, Footprint)> {
    let ev = graph.event(event);
    let (ExecContext::Async(op), EventKind::Access(acc)) = (ev.ctx, ev.kind) else {
        return None;
    };
    let access = graph.access(acc);
    (graph.async_op(op).kind == AsyncOpKind::Tcgen05Mma
        && access.space == Space::Tensor
        && access.role == OperandRole::Accumulator)
        .then_some((op, access.footprint))
}

/// `event`'s operation and footprint, if it is a `tcgen05.ld`/`.st`'s Tensor Memory effect.
fn load_store_effect(graph: &EventGraph, event: EventId) -> Option<(AsyncOpId, Footprint)> {
    let ev = graph.event(event);
    let (ExecContext::Async(op), EventKind::Access(acc)) = (ev.ctx, ev.kind) else {
        return None;
    };
    let access = graph.access(acc);
    (matches!(
        graph.async_op(op).kind,
        AsyncOpKind::Tcgen05Ld | AsyncOpKind::Tcgen05St
    ) && access.space == Space::Tensor
        && access.role == OperandRole::TmemData)
        .then_some((op, access.footprint))
}

/// Whether the PTX ISA pipelines `a`'s operation before `b`'s on these effects once both are
/// issued by one warp (9.7.18.6.2): the accumulator effects of two MMAs on one accumulator, or
/// the data effects of a `st` -> `ld`, `st` -> `st` or `ld` -> `st` pair. The fence protocol
/// orders such a pair across the warp's threads (9.7.18.6.4.3); any other pair needs the
/// earlier operation's completion (9.7.18.6.4.4).
pub fn pipelinable(graph: &EventGraph, a: EventId, b: EventId) -> bool {
    let warp = |op: AsyncOpId| graph.async_op(op).issuer.0 / WARP_SIZE;
    if let (Some((x, _)), Some((y, _))) =
        (accumulator_effect(graph, a), accumulator_effect(graph, b))
    {
        let d = accumulator(graph, x);
        return warp(x) == warp(y) && !d.is_empty() && d == accumulator(graph, y);
    }
    match (load_store_effect(graph, a), load_store_effect(graph, b)) {
        (Some((x, _)), Some((y, _))) => {
            warp(x) == warp(y) && load_store_pair(graph.async_op(x), graph.async_op(y))
        }
        _ => false,
    }
}

/// Whether `earlier` -> `later` is one of the pipelined `tcgen05.ld`/`.st` pairs (11-13).
fn load_store_pair(earlier: &AsyncOp, later: &AsyncOp) -> bool {
    matches!(
        (earlier.kind, later.kind),
        (AsyncOpKind::Tcgen05St, AsyncOpKind::Tcgen05Ld)
            | (AsyncOpKind::Tcgen05St, AsyncOpKind::Tcgen05St)
            | (AsyncOpKind::Tcgen05Ld, AsyncOpKind::Tcgen05St)
    )
}

/// [`PipelineRule::WaitedLoadStore`]: `a` and `b` effects of a `st` -> `ld`, `st` -> `st` or
/// `ld` -> `st` pair of one warp, in issue order, the earlier one waited for in between.
fn waited_load_store_edge(graph: &EventGraph, a: EventId, b: EventId) -> Option<PipelineEdge> {
    let (x, ax) = load_store_effect(graph, a)?;
    let (y, by) = load_store_effect(graph, b)?;
    let (earlier, later) = (graph.async_op(x), graph.async_op(y));
    let warp = earlier.issuer.0 / WARP_SIZE;
    let ordered = load_store_pair(earlier, later)
        && warp == later.issuer.0 / WARP_SIZE
        && earlier.issue < later.issue
        && waited_before(graph, earlier, warp, later);
    if !ordered {
        return None;
    }
    Some(PipelineEdge {
        rule: PipelineRule::WaitedLoadStore,
        from: a,
        to: b,
        roles: (OperandRole::TmemData, OperandRole::TmemData),
        cells: shared_cells(ax, by)?,
    })
}

/// Whether a `tcgen05.wait` of `warp` completing `earlier` (a warp collective's exit tracking
/// it) releases `later`'s issuer before `later` is issued.
fn waited_before(graph: &EventGraph, earlier: &AsyncOp, warp: u32, later: &AsyncOp) -> bool {
    earlier.tracking.iter().any(|&g| {
        let generation = graph.generation(g);
        matches!(
            generation.kind,
            GenerationKind::Collective {
                side: CollectiveSide::Exit,
                ..
            }
        ) && graph.object(generation.object).kind == SyncObjectKind::WarpCollective { warp }
            && generation
                .releases
                .iter()
                .any(|&r| graph.thread_of(r) == Some(later.issuer) && r < later.issue)
    })
}

fn shared_cells(a: Footprint, b: Footprint) -> Option<Footprint> {
    let (
        Footprint::Tensor {
            lane: al,
            lanes: an,
            col: ac,
            cols: acn,
        },
        Footprint::Tensor {
            lane: bl,
            lanes: bn,
            col: bc,
            cols: bcn,
        },
    ) = (a, b)
    else {
        return None;
    };
    let lane = al.max(bl);
    let lane_end = (u32::from(al) + u32::from(an)).min(u32::from(bl) + u32::from(bn));
    let col = ac.max(bc);
    let col_end = (u32::from(ac) + u32::from(acn)).min(u32::from(bc) + u32::from(bcn));
    (u32::from(lane) < lane_end && u32::from(col) < col_end).then(|| Footprint::Tensor {
        lane,
        lanes: (lane_end - u32::from(lane)) as u8,
        col,
        cols: (col_end - u32::from(col)) as u16,
    })
}
